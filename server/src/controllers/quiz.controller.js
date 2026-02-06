const QuizService = require("../services/quiz.service");

// GET /api/v1/quizzes/lesson/:lessonId
exports.getQuizByLesson = async (req, res) => {
  try {
    const { lessonId } = req.params;
    const quiz = await QuizService.getQuizByLessonId(lessonId);

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: "Chưa có bài kiểm tra cho bài học này",
      });
    }

    res.status(200).json({
      success: true,
      data: quiz,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/quizzes/:id
exports.getQuizById = async (req, res) => {
  try {
    const { id } = req.params;
    const quiz = await QuizService.getQuizById(id);

    if (!quiz) {
      return res.status(404).json({
        success: false,
        message: "Không tìm thấy bài kiểm tra",
      });
    }

    res.status(200).json({
      success: true,
      data: quiz,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/quizzes
exports.createQuiz = async (req, res) => {
  try {
    const result = await QuizService.createFullQuiz(req.body);
    res.status(201).json({
      success: true,
      data: result,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/v1/quizzes/:id
exports.updateQuiz = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await QuizService.updateFullQuiz(id, req.body);
    res.status(200).json({
      success: true,
      data: result,
      message: "Cập nhật quiz thành công",
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/quizzes/:quizId/submit
exports.submitQuiz = async (req, res) => {
  try {
    const { quizId } = req.params;
    const { user_id, answers, time_spent } = req.body;

    if (!user_id || !answers || !Array.isArray(answers)) {
      return res.status(400).json({
        success: false,
        message: "Thiếu thông tin: user_id và answers là bắt buộc",
      });
    }

    const result = await QuizService.submitQuizResult(
      user_id,
      quizId,
      answers,
      time_spent
    );

    res.status(200).json({
      success: true,
      data: result,
      message: result.passed ? "Chúc mừng! Bạn đã đạt yêu cầu" : "Hãy cố gắng thêm nhé!",
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/quizzes/results/user/:userId
exports.getUserQuizHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { quiz_id } = req.query;

    const history = await QuizService.getUserQuizHistory(
      userId,
      quiz_id || null
    );

    res.status(200).json({
      success: true,
      data: history,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/quizzes/:quizId/best-score/:userId
exports.getUserBestScore = async (req, res) => {
  try {
    const { quizId, userId } = req.params;
    const bestScore = await QuizService.getUserBestScore(userId, quizId);

    res.status(200).json({
      success: true,
      data: bestScore,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/quizzes/stats/user/:userId
exports.getUserQuizStats = async (req, res) => {
  try {
    const { userId } = req.params;
    const stats = await QuizService.getUserQuizStats(userId);

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/v1/quizzes/:id
exports.deleteQuiz = async (req, res) => {
  try {
    await QuizService.deleteQuiz(req.params.id);
    res.status(200).json({ success: true, message: "Đã xóa bài kiểm tra" });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
