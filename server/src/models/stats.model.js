const db = require("../config/db.config");

class StatsModel {
  // Đếm số users
  static async countUsers() {
    const [rows] = await db.query("SELECT COUNT(*) as count FROM users");
    return rows[0].count;
  }

  // Đếm số topics
  static async countTopics() {
    const [rows] = await db.query("SELECT COUNT(*) as count FROM topics");
    return rows[0].count;
  }

  // Đếm số lessons
  static async countLessons() {
    const [rows] = await db.query("SELECT COUNT(*) as count FROM lessons");
    return rows[0].count;
  }

  // Lấy tất cả thống kê
  static async getAllStats() {
    const [users] = await db.query("SELECT COUNT(*) as count FROM users");
    const [topics] = await db.query("SELECT COUNT(*) as count FROM topics");
    const [lessons] = await db.query("SELECT COUNT(*) as count FROM lessons");

    return {
      users: users[0].count,
      topics: topics[0].count,
      lessons: lessons[0].count,
      quizzes: 0, // Chưa có bảng quizzes
    };
  }
}

module.exports = StatsModel;
