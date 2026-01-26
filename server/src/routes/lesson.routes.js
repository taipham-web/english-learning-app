const express = require("express");
const router = express.Router();
const lessonController = require("../controllers/lesson.controller");

// Định nghĩa các route chuẩn RESTful
router.get("/", lessonController.getAll); // GET tất cả bài học
router.get("/topic/:topicId", lessonController.getByTopicId); // GET bài học theo topic
router.get("/:id", lessonController.getOne); // GET chi tiết bài học
router.post("/", lessonController.create); // POST tạo mới
router.put("/:id", lessonController.update); // PUT cập nhật
router.delete("/:id", lessonController.delete); // DELETE xóa

module.exports = router;
