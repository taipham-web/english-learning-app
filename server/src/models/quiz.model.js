const db = require("../../db"); // Import từ file db.js gốc

class QuizModel {
  // Tạo bài quiz mới
  static async create(lessonId, title, description) {
    const [result] = await db.query(
      "INSERT INTO quizzes (lesson_id, title, description) VALUES (?, ?, ?)",
      [lessonId, title, description],
    );
    return result.insertId;
  }

  // Thêm câu hỏi
  static async addQuestion(
    quizId,
    content,
    type = "multiple_choice",
    explanation = "",
  ) {
    const [result] = await db.query(
      "INSERT INTO questions (quiz_id, content, type, explanation) VALUES (?, ?, ?, ?)",
      [quizId, content, type, explanation],
    );
    return result.insertId;
  }

  // Thêm đáp án
  static async addOption(questionId, content, isCorrect) {
    const [result] = await db.query(
      "INSERT INTO question_options (question_id, content, is_correct) VALUES (?, ?, ?)",
      [questionId, content, isCorrect],
    );
    return result.insertId;
  }

  // Lấy quiz theo lesson_id
  static async getByLessonId(lessonId) {
    const [rows] = await db.query("SELECT * FROM quizzes WHERE lesson_id = ?", [
      lessonId,
    ]);
    return rows[0]; // Giả sử mỗi bài học có 1 bài quiz chính
  }

  // Lấy quiz theo id
  static async getById(quizId) {
    const [rows] = await db.query("SELECT * FROM quizzes WHERE id = ?", [
      quizId,
    ]);
    return rows[0];
  }

  // Lấy danh sách câu hỏi của 1 quiz
  static async getQuestionsByQuizId(quizId) {
    const [rows] = await db.query("SELECT * FROM questions WHERE quiz_id = ?", [
      quizId,
    ]);
    return rows;
  }

  // Lấy danh sách đáp án của 1 câu hỏi
  static async getOptionsByQuestionId(questionId) {
    const [rows] = await db.query(
      "SELECT id, question_id, content, is_correct FROM question_options WHERE question_id = ?",
      [questionId],
    );
    return rows;
  }

  // Xóa quiz
  static async delete(id) {
    await db.query("DELETE FROM quizzes WHERE id = ?", [id]);
  }

  // Cập nhật thông tin quiz
  static async update(quizId, title, description, passingScore, timeLimit) {
    await db.query(
      "UPDATE quizzes SET title = ?, description = ?, passing_score = ?, time_limit = ? WHERE id = ?",
      [title, description, passingScore, timeLimit, quizId],
    );
  }

  // Xóa tất cả câu hỏi của quiz
  static async deleteQuestionsByQuizId(quizId) {
    await db.query("DELETE FROM questions WHERE quiz_id = ?", [quizId]);
  }

  // Xóa tất cả đáp án của câu hỏi
  static async deleteOptionsByQuestionId(questionId) {
    await db.query("DELETE FROM question_options WHERE question_id = ?", [
      questionId,
    ]);
  }
}

module.exports = QuizModel;
