const express = require("express");
const router = express.Router();
const vocabularyController = require("../controllers/vocabulary.controller");

// Định nghĩa các route chuẩn RESTful
router.get("/", vocabularyController.getAll); // GET tất cả từ vựng hoặc theo lesson_id
router.get("/lesson/:lessonId", vocabularyController.getByLessonId); // GET từ vựng theo lesson
router.get("/:id", vocabularyController.getOne); // GET chi tiết từ vựng
router.post("/", vocabularyController.create); // POST tạo mới
router.post("/bulk", vocabularyController.createBulk); // POST tạo nhiều từ vựng
router.put("/:id", vocabularyController.update); // PUT cập nhật
router.delete("/:id", vocabularyController.delete); // DELETE xóa

module.exports = router;
