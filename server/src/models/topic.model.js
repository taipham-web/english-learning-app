const db = require("../config/db.config");

class TopicModel {
  static async getAll() {
    const [rows] = await db.query("SELECT * FROM topics");
    return rows;
  }

  static async getById(id) {
    const [rows] = await db.query("SELECT * FROM topics WHERE id = ?", [id]);
    return rows[0];
  }

  static async create({ name, description, image_url }) {
    const [result] = await db.query(
      "INSERT INTO topics (name, description, image_url) VALUES (?, ?, ?)",
      [name, description, image_url],
    );
    return result.insertId;
  }

  static async update(id, { name, description, image_url }) {
    const [result] = await db.query(
      "UPDATE topics SET name = ?, description = ?, image_url = ? WHERE id = ?",
      [name, description, image_url, id],
    );
    return result.affectedRows;
  }

  static async delete(id) {
    const [result] = await db.query("DELETE FROM topics WHERE id = ?", [id]);
    return result.affectedRows;
  }
}

module.exports = TopicModel;
