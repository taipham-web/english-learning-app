const db = require("../../db");

class SavedVocabularyModel {
  // Lấy danh sách từ vựng đã lưu của user
  static async getByUserId(userId) {
    const query = `
      SELECT sv.id, sv.user_id, sv.vocabulary_id, sv.created_at,
             v.word, v.meaning, v.phonetic, v.audio_url, v.lesson_id,
             l.title as lesson_title
      FROM saved_vocabularies sv
      JOIN vocabularies v ON sv.vocabulary_id = v.id
      LEFT JOIN lessons l ON v.lesson_id = l.id
      WHERE sv.user_id = ?
      ORDER BY sv.created_at DESC
    `;
    const [rows] = await db.query(query, [userId]);
    return rows;
  }

  // Kiểm tra từ vựng đã được lưu chưa
  static async checkSaved(userId, vocabularyId) {
    const query = `SELECT id FROM saved_vocabularies WHERE user_id = ? AND vocabulary_id = ?`;
    const [rows] = await db.query(query, [userId, vocabularyId]);
    return rows.length > 0;
  }

  // Lưu từ vựng
  static async save(userId, vocabularyId) {
    const query = `INSERT INTO saved_vocabularies (user_id, vocabulary_id) VALUES (?, ?)`;
    const [result] = await db.query(query, [userId, vocabularyId]);
    return result.insertId;
  }

  // Bỏ lưu từ vựng
  static async unsave(userId, vocabularyId) {
    const query = `DELETE FROM saved_vocabularies WHERE user_id = ? AND vocabulary_id = ?`;
    const [result] = await db.query(query, [userId, vocabularyId]);
    return result.affectedRows > 0;
  }

  // Lấy danh sách vocabulary_id đã lưu của user
  static async getSavedIds(userId) {
    const query = `SELECT vocabulary_id FROM saved_vocabularies WHERE user_id = ?`;
    const [rows] = await db.query(query, [userId]);
    return rows.map((row) => row.vocabulary_id);
  }
}

module.exports = SavedVocabularyModel;
