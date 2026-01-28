const express = require("express");
const router = express.Router();
const learningProgressController = require("../controllers/learningProgress.controller");

// POST - Đánh dấu hoàn thành bài học
router.post("/complete", learningProgressController.completeLesson);

// GET - Lấy tiến độ của user
router.get("/user/:userId", learningProgressController.getUserProgress);

// GET - Kiểm tra bài học đã hoàn thành chưa
router.get("/check/:userId/:lessonId", learningProgressController.checkLessonCompleted);

// DELETE - Xóa tiến độ bài học
router.delete("/:userId/:lessonId", learningProgressController.removeProgress);

module.exports = router;
