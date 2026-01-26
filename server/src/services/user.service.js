const UserModel = require("../models/user.model");

class UserService {
  static async getUserById(id) {
    const user = await UserModel.findById(id);

    if (!user) {
      throw new Error("USER_NOT_FOUND");
    }

    return user;
  }
}

module.exports = UserService;
