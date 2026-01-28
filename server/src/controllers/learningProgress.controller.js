const LearningProgressModel = require("../models/learningProgress.model");

// POST /api/v1/learning-progress/complete - Đánh dấu hoàn thành bài học
exports.completeLesson = async (req, res) => {
  try {
    const { userId, lessonId } = req.body;

    if (!userId || !lessonId) {
      return res.status(400).json({
        success: false,
        message: "userId và lessonId là bắt buộc",
      });
    }

    await LearningProgressModel.completeLesson(userId, lessonId);

    // Tính lại streak sau khi hoàn thành
    const streak = await LearningProgressModel.calculateStreak(userId);
    const todayCompleted = await LearningProgressModel.countTodayCompletedLessons(userId);
    const totalCompleted = await LearningProgressModel.countCompletedLessons(userId);

    res.status(200).json({
      success: true,
      message: "Đã đánh dấu hoàn thành bài học",
      data: {
        streak,
        today_completed: todayCompleted,
        total_completed: totalCompleted,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/learning-progress/user/:userId - Lấy tiến độ của user
exports.getUserProgress = async (req, res) => {
  try {
    const { userId } = req.params;

    const streak = await LearningProgressModel.calculateStreak(userId);
    const todayCompleted = await LearningProgressModel.countTodayCompletedLessons(userId);
    const totalCompleted = await LearningProgressModel.countCompletedLessons(userId);
    const completedLessons = await LearningProgressModel.getCompletedLessons(userId);

    res.status(200).json({
      success: true,
      data: {
        streak,
        today_completed: todayCompleted,
        total_completed: totalCompleted,
        completed_lessons: completedLessons,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/learning-progress/check/:userId/:lessonId - Kiểm tra bài học đã hoàn thành chưa
exports.checkLessonCompleted = async (req, res) => {
  try {
    const { userId, lessonId } = req.params;

    const isCompleted = await LearningProgressModel.isLessonCompleted(
      userId,
      lessonId
    );

    res.status(200).json({
      success: true,
      data: { is_completed: isCompleted },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/v1/learning-progress/:userId/:lessonId - Xóa tiến độ bài học
exports.removeProgress = async (req, res) => {
  try {
    const { userId, lessonId } = req.params;

    const removed = await LearningProgressModel.removeProgress(userId, lessonId);

    if (removed) {
      res.status(200).json({
        success: true,
        message: "Đã xóa tiến độ bài học",
      });
    } else {
      res.status(404).json({
        success: false,
        message: "Không tìm thấy tiến độ",
      });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
