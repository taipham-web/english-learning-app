const db = require("../config/db.config");

class LessonModel {
  // Lấy tất cả bài học
  static async getAll() {
    const [rows] = await db.query(`
      SELECT l.*, t.name as topic_name 
      FROM lessons l 
      LEFT JOIN topics t ON l.topic_id = t.id 
      ORDER BY l.created_at DESC
    `);
    return rows;
  }

  // Lấy bài học theo topic_id
  static async getByTopicId(topicId) {
    const [rows] = await db.query(
      `SELECT * FROM lessons WHERE topic_id = ? ORDER BY difficulty_score ASC, created_at ASC`,
      [topicId],
    );
    return rows;
  }

  // Lấy bài học theo topic_id và level (lọc theo level user)
  static async getByTopicIdAndLevel(topicId, userLevel) {
    // Xác định các level được phép xem dựa trên level của user
    let allowedLevels = ["beginner"];
    if (userLevel === "intermediate") {
      allowedLevels = ["beginner", "intermediate"];
    } else if (userLevel === "advanced") {
      allowedLevels = ["beginner", "intermediate", "advanced"];
    }

    const placeholders = allowedLevels.map(() => "?").join(",");
    const [rows] = await db.query(
      `SELECT * FROM lessons WHERE topic_id = ? AND level IN (${placeholders}) ORDER BY difficulty_score ASC, created_at ASC`,
      [topicId, ...allowedLevels],
    );
    return rows;
  }

  // Lấy chi tiết một bài học
  static async getById(id) {
    const [rows] = await db.query(
      `SELECT l.*, t.name as topic_name 
       FROM lessons l 
       LEFT JOIN topics t ON l.topic_id = t.id 
       WHERE l.id = ?`,
      [id],
    );
    return rows[0];
  }

  // Tạo bài học mới
  static async create({
    topic_id,
    title,
    content,
    video_url,
    level,
    difficulty_score,
  }) {
    const [result] = await db.query(
      `INSERT INTO lessons (topic_id, title, content, video_url, level, difficulty_score) VALUES (?, ?, ?, ?, ?, ?)`,
      [
        topic_id,
        title,
        content,
        video_url,
        level || "beginner",
        difficulty_score || 1,
      ],
    );
    return result.insertId;
  }

  // Cập nhật bài học
  static async update(
    id,
    { topic_id, title, content, video_url, level, difficulty_score },
  ) {
    const [result] = await db.query(
      `UPDATE lessons SET topic_id = ?, title = ?, content = ?, video_url = ?, level = ?, difficulty_score = ? WHERE id = ?`,
      [topic_id, title, content, video_url, level, difficulty_score, id],
    );
    return result.affectedRows;
  }

  // Xóa bài học
  static async delete(id) {
    const [result] = await db.query("DELETE FROM lessons WHERE id = ?", [id]);
    return result.affectedRows;
  }

  // Đếm số bài học theo topic
  static async countByTopicId(topicId) {
    const [rows] = await db.query(
      "SELECT COUNT(*) as count FROM lessons WHERE topic_id = ?",
      [topicId],
    );
    return rows[0].count;
  }
}

module.exports = LessonModel;
