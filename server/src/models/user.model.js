const db = require("../config/db.config");

class UserModel {
  static async findByEmail(email) {
    const [rows] = await db.query("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    return rows[0];
  }

  static async findById(id) {
    const [rows] = await db.query(
      "SELECT id, name, email, role, level FROM users WHERE id = ?",
      [id],
    );
    return rows[0];
  }

  static async create({
    email,
    password,
    name,
    role = "student",
    level = "beginner",
  }) {
    const [result] = await db.query(
      "INSERT INTO users (email, password, name, role, level) VALUES (?, ?, ?, ?, ?)",
      [email, password, name, role, level],
    );
    return result.insertId;
  }

  static async getAll() {
    const [rows] = await db.query(
      "SELECT id, name, email, role, level FROM users",
    );
    return rows;
  }
}

module.exports = UserModel;
