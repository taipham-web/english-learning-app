const QuizModel = require("../models/quiz.model");
const LessonModel = require("../models/lesson.model");
const QuizResultModel = require("../models/quizResult.model");

class QuizService {
  // Lấy bài quiz đầy đủ (bao gồm câu hỏi và đáp án) theo Lesson ID
  static async getQuizByLessonId(lessonId) {
    // 1. Kiểm tra lesson tồn tại
    const lesson = await LessonModel.getById(lessonId);
    if (!lesson) throw new Error("Lesson_Not_Found");

    // 2. Lấy thông tin quiz
    const quiz = await QuizModel.getByLessonId(lessonId);
    if (!quiz) return null; // Bài học này chưa có quiz

    // 3. Lấy danh sách câu hỏi
    const questions = await QuizModel.getQuestionsByQuizId(quiz.id);

    // 4. Lấy đáp án cho từng câu hỏi
    // Sử dụng Promise.all để chạy song song cho nhanh
    const questionsWithOptions = await Promise.all(
      questions.map(async (q) => {
        const options = await QuizModel.getOptionsByQuestionId(q.id);

        // Trộn ngẫu nhiên thứ tự đáp án để hiển thị trên client (nếu cần)
        // options.sort(() => Math.random() - 0.5);

        return {
          ...q,
          options: options,
        };
      }),
    );

    return {
      ...quiz,
      questions: questionsWithOptions,
    };
  }

  // Lấy quiz theo ID
  static async getQuizById(quizId) {
    const quiz = await QuizModel.getById(quizId);
    if (!quiz) throw new Error("Quiz_Not_Found");

    const questions = await QuizModel.getQuestionsByQuizId(quizId);
    const questionsWithOptions = await Promise.all(
      questions.map(async (q) => {
        const options = await QuizModel.getOptionsByQuestionId(q.id);
        return {
          ...q,
          options: options,
        };
      }),
    );

    return {
      ...quiz,
      questions: questionsWithOptions,
    };
  }

  // Tạo bài quiz mới kèm câu hỏi (Dùng cho Admin hoặc Seed data)
  static async createFullQuiz(data) {
    // data structure: { lesson_id, title, questions: [ { content, options: [ { content, is_correct } ] } ] }

    if (!data.lesson_id || !data.title) throw new Error("Missing_Info");

    // 1. Tạo Quiz
    const quizId = await QuizModel.create(
      data.lesson_id,
      data.title,
      data.description,
    );

    // 2. Tạo Questions và Options
    if (data.questions && data.questions.length > 0) {
      for (const q of data.questions) {
        const questionId = await QuizModel.addQuestion(
          quizId,
          q.content,
          q.type || "multiple_choice",
          q.explanation,
        );

        if (q.options && q.options.length > 0) {
          for (const opt of q.options) {
            await QuizModel.addOption(questionId, opt.content, opt.is_correct);
          }
        }
      }
    }

    return { quizId, message: "Quiz created successfully" };
  }

  // Cập nhật bài quiz (Admin)
  static async updateFullQuiz(quizId, data) {
    // data structure: { lesson_id, title, description, passing_score, time_limit, questions: [ { content, options: [ { content, is_correct } ] } ] }

    if (!data.lesson_id || !data.title) throw new Error("Missing_Info");

    // 1. Cập nhật thông tin Quiz
    await QuizModel.update(
      quizId,
      data.title,
      data.description,
      data.passing_score || 70,
      data.time_limit || 600,
    );

    // 2. Xóa tất cả câu hỏi cũ (cascade sẽ xóa options)
    await QuizModel.deleteQuestionsByQuizId(quizId);

    // 3. Tạo lại Questions và Options mới
    if (data.questions && data.questions.length > 0) {
      for (const q of data.questions) {
        const questionId = await QuizModel.addQuestion(
          quizId,
          q.content,
          q.type || "multiple_choice",
          q.explanation,
        );

        if (q.options && q.options.length > 0) {
          for (const opt of q.options) {
            await QuizModel.addOption(questionId, opt.content, opt.is_correct);
          }
        }
      }
    }

    return { quizId, message: "Quiz updated successfully" };
  }

  // Submit kết quả quiz
  static async submitQuizResult(userId, quizId, answers, timeSpent = null) {
    // answers: [{ question_id, selected_option_id }]
    
    // 1. Lấy quiz với đáp án đúng
    const quiz = await this.getQuizById(quizId);
    if (!quiz) throw new Error("Quiz_Not_Found");

    // 2. Tính điểm
    let correctCount = 0;
    const answerDetails = [];

    for (const answer of answers) {
      const question = quiz.questions.find(q => q.id === answer.question_id);
      if (!question) continue;

      const correctOption = question.options.find(opt => opt.is_correct === 1 || opt.is_correct === true);
      const isCorrect = correctOption && correctOption.id === answer.selected_option_id;

      if (isCorrect) correctCount++;

      answerDetails.push({
        question_id: answer.question_id,
        selected_option_id: answer.selected_option_id,
        is_correct: isCorrect,
      });
    }

    const totalQuestions = quiz.questions.length;
    const percentage = (correctCount / totalQuestions) * 100;

    // 3. Lưu kết quả
    const resultId = await QuizResultModel.create(
      userId,
      quizId,
      correctCount,
      totalQuestions,
      percentage,
      timeSpent
    );

    // 4. Lưu chi tiết câu trả lời
    for (const detail of answerDetails) {
      await QuizResultModel.saveAnswerDetail(
        resultId,
        detail.question_id,
        detail.selected_option_id,
        detail.is_correct
      );
    }

    return {
      result_id: resultId,
      score: correctCount,
      total_questions: totalQuestions,
      percentage: percentage.toFixed(2),
      passed: percentage >= 70,
    };
  }

  // Lấy lịch sử làm bài của user
  static async getUserQuizHistory(userId, quizId = null) {
    if (quizId) {
      return await QuizResultModel.getByUserAndQuiz(userId, quizId);
    }
    return await QuizResultModel.getAllByUser(userId);
  }

  // Lấy điểm cao nhất của user cho một quiz
  static async getUserBestScore(userId, quizId) {
    return await QuizResultModel.getBestScore(userId, quizId);
  }

  // Lấy thống kê quiz của user
  static async getUserQuizStats(userId) {
    return await QuizResultModel.getUserQuizStats(userId);
  }

  static async deleteQuiz(id) {
    await QuizModel.delete(id);
    return true;
  }
}

module.exports = QuizService;

