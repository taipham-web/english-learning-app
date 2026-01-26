const express = require("express");
const router = express.Router();
const topicController = require("../controllers/topic.controller");

// Định nghĩa các route chuẩn RESTful
router.get("/", topicController.getAll); // GET danh sách
router.get("/:id", topicController.getOne); // GET chi tiết
router.post("/", topicController.create); // POST tạo mới
router.put("/:id", topicController.update); // PUT cập nhật
router.delete("/:id", topicController.delete); // DELETE xóa

module.exports = router;
