const db = require("../../db");

class QuizResultModel {
  // Lưu kết quả quiz của user
  static async create(userId, quizId, score, totalQuestions, percentage, timeSpent = null) {
    const [result] = await db.query(
      `INSERT INTO quiz_results (user_id, quiz_id, score, total_questions, percentage, time_spent) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [userId, quizId, score, totalQuestions, percentage, timeSpent]
    );
    return result.insertId;
  }

  // Lưu chi tiết câu trả lời
  static async saveAnswerDetail(quizResultId, questionId, selectedOptionId, isCorrect) {
    const [result] = await db.query(
      `INSERT INTO quiz_answer_details (quiz_result_id, question_id, selected_option_id, is_correct) 
       VALUES (?, ?, ?, ?)`,
      [quizResultId, questionId, selectedOptionId, isCorrect]
    );
    return result.insertId;
  }

  // Lấy lịch sử làm bài của user theo quiz
  static async getByUserAndQuiz(userId, quizId) {
    const [rows] = await db.query(
      `SELECT * FROM quiz_results 
       WHERE user_id = ? AND quiz_id = ? 
       ORDER BY completed_at DESC`,
      [userId, quizId]
    );
    return rows;
  }

  // Lấy tất cả lịch sử làm bài của user
  static async getAllByUser(userId, limit = 50) {
    const [rows] = await db.query(
      `SELECT 
        qr.*,
        q.title as quiz_title,
        q.lesson_id,
        l.title as lesson_title
       FROM quiz_results qr
       JOIN quizzes q ON qr.quiz_id = q.id
       LEFT JOIN lessons l ON q.lesson_id = l.id
       WHERE qr.user_id = ?
       ORDER BY qr.completed_at DESC
       LIMIT ?`,
      [userId, limit]
    );
    return rows;
  }

  // Lấy kết quả tốt nhất của user cho một quiz
  static async getBestScore(userId, quizId) {
    const [rows] = await db.query(
      `SELECT * FROM quiz_results 
       WHERE user_id = ? AND quiz_id = ? 
       ORDER BY percentage DESC, completed_at DESC 
       LIMIT 1`,
      [userId, quizId]
    );
    return rows[0] || null;
  }

  // Lấy chi tiết câu trả lời của một lần làm bài
  static async getAnswerDetails(quizResultId) {
    const [rows] = await db.query(
      `SELECT 
        qad.*,
        q.content as question_content,
        q.type as question_type,
        qo.content as selected_answer
       FROM quiz_answer_details qad
       JOIN questions q ON qad.question_id = q.id
       LEFT JOIN question_options qo ON qad.selected_option_id = qo.id
       WHERE qad.quiz_result_id = ?
       ORDER BY qad.id`,
      [quizResultId]
    );
    return rows;
  }

  // Lấy thống kê quiz của user
  static async getUserQuizStats(userId) {
    const [rows] = await db.query(
      `SELECT 
        COUNT(*) as total_attempts,
        AVG(percentage) as average_score,
        MAX(percentage) as best_score,
        COUNT(CASE WHEN percentage >= 70 THEN 1 END) as passed_count
       FROM quiz_results 
       WHERE user_id = ?`,
      [userId]
    );
    return rows[0];
  }

  // Xóa kết quả quiz
  static async delete(id) {
    await db.query("DELETE FROM quiz_results WHERE id = ?", [id]);
  }
}

module.exports = QuizResultModel;
