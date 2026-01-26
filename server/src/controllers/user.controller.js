const UserService = require("../services/user.service");

class UserController {
  static async getUserById(req, res) {
    try {
      const { id } = req.params;
      const user = await UserService.getUserById(id);

      res.status(200).json({
        success: true,
        user,
      });
    } catch (error) {
      console.error("Get user error:", error.message);

      if (error.message === "USER_NOT_FOUND") {
        return res.status(404).json({
          success: false,
          message: "Không tìm thấy người dùng",
        });
      }

      res.status(500).json({
        success: false,
        message: "Lỗi server",
      });
    }
  }
}

module.exports = UserController;
