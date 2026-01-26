const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");

// POST /api/v1/auth/register - Đăng ký
router.post("/register", authController.register);

// POST /api/v1/auth/login - Đăng nhập
router.post("/login", authController.login);

module.exports = router;
