const db = require("../config/db.config");
const LearningProgressModel = require("./learningProgress.model");

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

  // Lấy tất cả thống kê (admin dashboard)
  static async getAllStats() {
    const [users] = await db.query("SELECT COUNT(*) as count FROM users");
    const [topics] = await db.query("SELECT COUNT(*) as count FROM topics");
    const [lessons] = await db.query("SELECT COUNT(*) as count FROM lessons");
    const [vocabularies] = await db.query("SELECT COUNT(*) as count FROM vocabularies");

    return {
      users: users[0].count,
      topics: topics[0].count,
      lessons: lessons[0].count,
      vocabularies: vocabularies[0].count,
      quizzes: 0, // Chưa có bảng quizzes
    };
  }

  // Lấy thống kê học tập của user
  static async getUserStats(userId) {
    // Đếm số từ vựng đã lưu
    const [savedVocabs] = await db.query(
      "SELECT COUNT(*) as count FROM saved_vocabularies WHERE user_id = ?",
      [userId]
    );

    // Đếm tổng số topics
    const [totalTopics] = await db.query("SELECT COUNT(*) as count FROM topics");

    // Đếm tổng số lessons
    const [totalLessons] = await db.query("SELECT COUNT(*) as count FROM lessons");

    // Đếm tổng số vocabularies
    const [totalVocabularies] = await db.query("SELECT COUNT(*) as count FROM vocabularies");

    // Lấy streak và tiến độ thực từ learning_progress
    let learningStreak = 0;
    let dailyCompleted = 0;
    let completedLessonsCount = 0;

    try {
      learningStreak = await LearningProgressModel.calculateStreak(userId);
      dailyCompleted = await LearningProgressModel.countTodayCompletedLessons(userId);
      completedLessonsCount = await LearningProgressModel.countCompletedLessons(userId);
    } catch (err) {
      // Nếu bảng chưa tồn tại, trả về 0
      console.log("Learning progress table may not exist yet:", err.message);
    }

    // Lấy danh sách topics với số lessons và tiến độ
    const [topicsWithProgress] = await db.query(`
      SELECT t.id, t.name, t.image_url,
             COUNT(l.id) as total_lessons
      FROM topics t
      LEFT JOIN lessons l ON l.topic_id = t.id
      GROUP BY t.id
      ORDER BY t.id
      LIMIT 5
    `);

    // Lấy danh sách lessons gần đây
    const [recentLessons] = await db.query(`
      SELECT l.id, l.title, l.level, l.difficulty_score, 
             t.name as topic_name, t.id as topic_id,
             (SELECT COUNT(*) FROM vocabularies WHERE lesson_id = l.id) as vocabulary_count
      FROM lessons l
      JOIN topics t ON l.topic_id = t.id
      ORDER BY l.created_at DESC
      LIMIT 5
    `);

    return {
      saved_vocabularies: savedVocabs[0].count,
      total_topics: totalTopics[0].count,
      total_lessons: totalLessons[0].count,
      total_vocabularies: totalVocabularies[0].count,
      completed_lessons: completedLessonsCount,
      topics: topicsWithProgress,
      recent_lessons: recentLessons,
      learning_streak: learningStreak,
      daily_goal: 5,
      daily_completed: dailyCompleted,
    };
  }
}

module.exports = StatsModel;

