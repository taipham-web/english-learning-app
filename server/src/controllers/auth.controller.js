const AuthService = require("../services/auth.service");

// POST /api/v1/auth/register
exports.register = async (req, res) => {
  try {
    const user = await AuthService.register(req.body);
    res.status(201).json({
      success: true,
      message: "Đăng ký thành công!",
      data: user,
    });
  } catch (error) {
    if (error.message === "MISSING_FIELDS") {
      return res.status(400).json({
        success: false,
        message: "Vui lòng điền đầy đủ thông tin!",
      });
    }
    if (error.message === "EMAIL_EXISTS") {
      return res.status(409).json({
        success: false,
        message: "Email này đã được sử dụng!",
      });
    }
    console.error("Register Error:", error);
    res.status(500).json({ success: false, message: "Lỗi hệ thống" });
  }
};

// POST /api/v1/auth/login
exports.login = async (req, res) => {
  try {
    const user = await AuthService.login(req.body);
    res.status(200).json({
      success: true,
      message: "Đăng nhập thành công!",
      data: { user },
    });
  } catch (error) {
    if (error.message === "MISSING_FIELDS") {
      return res.status(400).json({
        success: false,
        message: "Vui lòng điền email và mật khẩu!",
      });
    }
    if (error.message === "USER_NOT_FOUND") {
      return res.status(401).json({
        success: false,
        message: "Email chưa đăng ký!",
      });
    }
    if (error.message === "WRONG_PASSWORD") {
      return res.status(401).json({
        success: false,
        message: "Mật khẩu không đúng!",
      });
    }
    console.error("Login Error:", error);
    res.status(500).json({ success: false, message: "Lỗi hệ thống" });
  }
};
