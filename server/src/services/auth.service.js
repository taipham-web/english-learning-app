const UserModel = require("../models/user.model");
const bcrypt = require("bcrypt");

class AuthService {
  static async register({ email, password, name, level = "beginner" }) {
    // Validate input
    if (!email || !password || !name) {
      throw new Error("MISSING_FIELDS");
    }

    // Check email exists
    const existingUser = await UserModel.findByEmail(email);
    if (existingUser) {
      throw new Error("EMAIL_EXISTS");
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user
    const userId = await UserModel.create({
      email,
      password: hashedPassword,
      name,
      level,
    });

    return { id: userId, email, name, role: "student", level };
  }

  static async login({ email, password }) {
    // Validate input
    if (!email || !password) {
      throw new Error("MISSING_FIELDS");
    }

    // Find user
    const user = await UserModel.findByEmail(email);
    if (!user) {
      throw new Error("USER_NOT_FOUND");
    }

    // Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error("WRONG_PASSWORD");
    }

    // Return user info (without password)
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    };
  }
}

module.exports = AuthService;
