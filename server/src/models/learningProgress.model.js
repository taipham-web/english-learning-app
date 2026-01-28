const db = require("../config/db.config");

class LearningProgressModel {
  // Đánh dấu bài học đã hoàn thành
  static async completeLesson(userId, lessonId) {
    const query = `
      INSERT INTO learning_progress (user_id, lesson_id, completed_at) 
      VALUES (?, ?, NOW())
      ON DUPLICATE KEY UPDATE completed_at = NOW()
    `;
    const [result] = await db.query(query, [userId, lessonId]);
    return result;
  }

  // Kiểm tra bài học đã hoàn thành chưa
  static async isLessonCompleted(userId, lessonId) {
    const query = `SELECT id FROM learning_progress WHERE user_id = ? AND lesson_id = ?`;
    const [rows] = await db.query(query, [userId, lessonId]);
    return rows.length > 0;
  }

  // Lấy danh sách bài học đã hoàn thành của user
  static async getCompletedLessons(userId) {
    const query = `
      SELECT lp.lesson_id, lp.completed_at, l.title as lesson_title, t.name as topic_name
      FROM learning_progress lp
      JOIN lessons l ON lp.lesson_id = l.id
      JOIN topics t ON l.topic_id = t.id
      WHERE lp.user_id = ?
      ORDER BY lp.completed_at DESC
    `;
    const [rows] = await db.query(query, [userId]);
    return rows;
  }

  // Đếm số bài học đã hoàn thành
  static async countCompletedLessons(userId) {
    const query = `SELECT COUNT(*) as count FROM learning_progress WHERE user_id = ?`;
    const [rows] = await db.query(query, [userId]);
    return rows[0].count;
  }

  // Đếm số bài học hoàn thành hôm nay
  static async countTodayCompletedLessons(userId) {
    const query = `
      SELECT COUNT(*) as count FROM learning_progress 
      WHERE user_id = ? AND DATE(completed_at) = CURDATE()
    `;
    const [rows] = await db.query(query, [userId]);
    return rows[0].count;
  }

  // Tính chuỗi học (streak) - số ngày liên tiếp có hoàn thành bài học
  static async calculateStreak(userId) {
    // Lấy danh sách các ngày unique mà user đã học (sắp xếp giảm dần)
    const query = `
      SELECT DISTINCT DATE(completed_at) as learn_date
      FROM learning_progress
      WHERE user_id = ?
      ORDER BY learn_date DESC
    `;
    const [rows] = await db.query(query, [userId]);

    if (rows.length === 0) return 0;

    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // Kiểm tra xem ngày đầu tiên (gần nhất) có phải hôm nay hoặc hôm qua không
    const firstLearnDate = new Date(rows[0].learn_date);
    firstLearnDate.setHours(0, 0, 0, 0);

    // Nếu ngày học gần nhất không phải hôm nay hoặc hôm qua, streak = 0
    if (firstLearnDate < yesterday) {
      return 0;
    }

    // Đếm số ngày liên tiếp
    let expectedDate = firstLearnDate;
    for (let i = 0; i < rows.length; i++) {
      const learnDate = new Date(rows[i].learn_date);
      learnDate.setHours(0, 0, 0, 0);

      if (learnDate.getTime() === expectedDate.getTime()) {
        streak++;
        expectedDate = new Date(expectedDate);
        expectedDate.setDate(expectedDate.getDate() - 1);
      } else {
        break;
      }
    }

    return streak;
  }

  // Lấy tiến độ học của user theo topic
  static async getProgressByTopic(userId, topicId) {
    const query = `
      SELECT 
        COUNT(DISTINCT lp.lesson_id) as completed_lessons,
        (SELECT COUNT(*) FROM lessons WHERE topic_id = ?) as total_lessons
      FROM learning_progress lp
      JOIN lessons l ON lp.lesson_id = l.id
      WHERE lp.user_id = ? AND l.topic_id = ?
    `;
    const [rows] = await db.query(query, [topicId, userId, topicId]);
    return rows[0];
  }

  // Xóa tiến độ của 1 bài học
  static async removeProgress(userId, lessonId) {
    const query = `DELETE FROM learning_progress WHERE user_id = ? AND lesson_id = ?`;
    const [result] = await db.query(query, [userId, lessonId]);
    return result.affectedRows > 0;
  }
}

module.exports = LearningProgressModel;
