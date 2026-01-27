const db = require("../../db");

class VocabularyModel {
  // Lấy tất cả từ vựng
  static async getAll() {
    const [rows] = await db.query(`
      SELECT v.*, l.title as lesson_title
      FROM vocabularies v
      LEFT JOIN lessons l ON v.lesson_id = l.id
      ORDER BY v.id DESC
    `);
    return rows;
  }

  // Lấy từ vựng theo lesson_id
  static async getByLessonId(lessonId) {
    const [rows] = await db.query(
      `
      SELECT * FROM vocabularies 
      WHERE lesson_id = ?
      ORDER BY id ASC
    `,
      [lessonId],
    );
    return rows;
  }

  // Lấy từ vựng theo id
  static async getById(id) {
    const [rows] = await db.query(
      `
      SELECT v.*, l.title as lesson_title
      FROM vocabularies v
      LEFT JOIN lessons l ON v.lesson_id = l.id
      WHERE v.id = ?
    `,
      [id],
    );
    return rows[0];
  }

  // Tạo từ vựng mới
  static async create(data) {
    const [result] = await db.query(
      `
      INSERT INTO vocabularies (lesson_id, word, meaning, phonetic, audio_url)
      VALUES (?, ?, ?, ?, ?)
    `,
      [data.lesson_id, data.word, data.meaning, data.phonetic, data.audio_url],
    );
    return result.insertId;
  }

  // Tạo nhiều từ vựng cùng lúc
  static async createBulk(lessonId, vocabularies) {
    const values = vocabularies.map((v) => [
      lessonId,
      v.word,
      v.meaning,
      v.phonetic || null,
      v.audio_url || null,
    ]);

    const placeholders = values.map(() => "(?, ?, ?, ?, ?)").join(", ");
    const flatValues = values.flat();

    const [result] = await db.query(
      `
      INSERT INTO vocabularies (lesson_id, word, meaning, phonetic, audio_url)
      VALUES ${placeholders}
    `,
      flatValues,
    );

    return result.affectedRows;
  }

  // Cập nhật từ vựng
  static async update(id, data) {
    const [result] = await db.query(
      `
      UPDATE vocabularies 
      SET lesson_id = ?, word = ?, meaning = ?, phonetic = ?, audio_url = ?
      WHERE id = ?
    `,
      [
        data.lesson_id,
        data.word,
        data.meaning,
        data.phonetic,
        data.audio_url,
        id,
      ],
    );
    return result.affectedRows > 0;
  }

  // Xóa từ vựng
  static async delete(id) {
    const [result] = await db.query("DELETE FROM vocabularies WHERE id = ?", [
      id,
    ]);
    return result.affectedRows > 0;
  }

  // Xóa tất cả từ vựng theo lesson_id
  static async deleteByLessonId(lessonId) {
    const [result] = await db.query(
      "DELETE FROM vocabularies WHERE lesson_id = ?",
      [lessonId],
    );
    return result.affectedRows;
  }

  // Đếm số từ vựng theo lesson_id
  static async countByLessonId(lessonId) {
    const [rows] = await db.query(
      "SELECT COUNT(*) as count FROM vocabularies WHERE lesson_id = ?",
      [lessonId],
    );
    return rows[0].count;
  }
}

module.exports = VocabularyModel;
