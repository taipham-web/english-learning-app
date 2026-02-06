const express = require("express");
const router = express.Router();
const quizController = require("../controllers/quiz.controller");

// Lấy bài quiz theo lesson ID
router.get("/lesson/:lessonId", quizController.getQuizByLesson);

// Lấy bài quiz theo ID
router.get("/:id", quizController.getQuizById);

// Submit kết quả quiz
router.post("/:quizId/submit", quizController.submitQuiz);

// Lấy lịch sử làm bài của user
router.get("/results/user/:userId", quizController.getUserQuizHistory);

// Lấy điểm cao nhất của user cho một quiz
router.get("/:quizId/best-score/:userId", quizController.getUserBestScore);

// Lấy thống kê quiz của user
router.get("/stats/user/:userId", quizController.getUserQuizStats);

// Tạo bài quiz mới (Admin)
router.post("/", quizController.createQuiz);

// Cập nhật bài quiz (Admin)
router.put("/:id", quizController.updateQuiz);

// Xóa bài quiz
router.delete("/:id", quizController.deleteQuiz);

module.exports = router;
