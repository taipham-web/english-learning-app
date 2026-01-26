const express = require("express");
const router = express.Router();
const UserController = require("../controllers/user.controller");

// GET /api/v1/users/:id - Get user by ID
router.get("/:id", UserController.getUserById);

module.exports = router;
