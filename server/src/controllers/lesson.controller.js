const LessonService = require("../services/lesson.service");

// GET /api/v1/lessons
// Query params: topic_id, level
exports.getAll = async (req, res) => {
  try {
    const { topic_id, level } = req.query;

    // Nếu có topic_id, lọc theo topic và level
    if (topic_id) {
      const lessons = await LessonService.getLessonsByTopicId(topic_id, level);
      return res.status(200).json({ success: true, data: lessons });
    }

    const lessons = await LessonService.getAllLessons();
    res.status(200).json({ success: true, data: lessons });
  } catch (error) {
    if (error.message === "Topic_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/lessons/topic/:topicId
exports.getByTopicId = async (req, res) => {
  try {
    const lessons = await LessonService.getLessonsByTopicId(req.params.topicId);
    res.status(200).json({ success: true, data: lessons });
  } catch (error) {
    if (error.message === "Topic_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/lessons/:id
exports.getOne = async (req, res) => {
  try {
    const lesson = await LessonService.getLessonById(req.params.id);
    res.status(200).json({ success: true, data: lesson });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/lessons
exports.create = async (req, res) => {
  try {
    const newLesson = await LessonService.createLesson(req.body);
    res.status(201).json({
      success: true,
      message: "Tạo bài học thành công",
      data: newLesson,
    });
  } catch (error) {
    if (error.message === "Missing_Topic_Id") {
      return res
        .status(400)
        .json({ success: false, message: "Chủ đề là bắt buộc" });
    }
    if (error.message === "Missing_Title") {
      return res
        .status(400)
        .json({ success: false, message: "Tiêu đề bài học là bắt buộc" });
    }
    if (error.message === "Topic_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/v1/lessons/:id
exports.update = async (req, res) => {
  try {
    const updatedLesson = await LessonService.updateLesson(
      req.params.id,
      req.body,
    );
    res.status(200).json({
      success: true,
      message: "Cập nhật bài học thành công",
      data: updatedLesson,
    });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học để sửa" });
    }
    if (error.message === "Topic_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/v1/lessons/:id
exports.delete = async (req, res) => {
  try {
    await LessonService.deleteLesson(req.params.id);
    res.status(200).json({ success: true, message: "Xóa bài học thành công" });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học để xóa" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};
