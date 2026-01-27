const VocabularyService = require("../services/vocabulary.service");

// GET /api/v1/vocabularies
// Query params: lesson_id
exports.getAll = async (req, res) => {
  try {
    const { lesson_id } = req.query;

    // Nếu có lesson_id, lọc theo lesson
    if (lesson_id) {
      const vocabularies =
        await VocabularyService.getVocabulariesByLessonId(lesson_id);
      return res.status(200).json({ success: true, data: vocabularies });
    }

    const vocabularies = await VocabularyService.getAllVocabularies();
    res.status(200).json({ success: true, data: vocabularies });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/vocabularies/lesson/:lessonId
exports.getByLessonId = async (req, res) => {
  try {
    const vocabularies = await VocabularyService.getVocabulariesByLessonId(
      req.params.lessonId,
    );
    res.status(200).json({ success: true, data: vocabularies });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/vocabularies/:id
exports.getOne = async (req, res) => {
  try {
    const vocabulary = await VocabularyService.getVocabularyById(req.params.id);
    res.status(200).json({ success: true, data: vocabulary });
  } catch (error) {
    if (error.message === "Vocabulary_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy từ vựng" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/vocabularies
exports.create = async (req, res) => {
  try {
    const newVocabulary = await VocabularyService.createVocabulary(req.body);
    res.status(201).json({
      success: true,
      message: "Tạo từ vựng thành công",
      data: newVocabulary,
    });
  } catch (error) {
    if (error.message === "Missing_Lesson_Id") {
      return res
        .status(400)
        .json({ success: false, message: "Bài học là bắt buộc" });
    }
    if (error.message === "Missing_Word") {
      return res
        .status(400)
        .json({ success: false, message: "Từ vựng là bắt buộc" });
    }
    if (error.message === "Missing_Meaning") {
      return res
        .status(400)
        .json({ success: false, message: "Nghĩa của từ là bắt buộc" });
    }
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/vocabularies/bulk
exports.createBulk = async (req, res) => {
  try {
    const { lesson_id, vocabularies } = req.body;

    if (!lesson_id) {
      return res
        .status(400)
        .json({ success: false, message: "Bài học là bắt buộc" });
    }

    if (
      !vocabularies ||
      !Array.isArray(vocabularies) ||
      vocabularies.length === 0
    ) {
      return res
        .status(400)
        .json({ success: false, message: "Danh sách từ vựng không được rỗng" });
    }

    const result = await VocabularyService.createMultipleVocabularies(
      lesson_id,
      vocabularies,
    );
    res.status(201).json({
      success: true,
      message: `Tạo ${result.count} từ vựng thành công`,
      data: result,
    });
  } catch (error) {
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    if (error.message === "Missing_Word") {
      return res
        .status(400)
        .json({ success: false, message: "Từ vựng là bắt buộc" });
    }
    if (error.message === "Missing_Meaning") {
      return res
        .status(400)
        .json({ success: false, message: "Nghĩa của từ là bắt buộc" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/v1/vocabularies/:id
exports.update = async (req, res) => {
  try {
    const updatedVocabulary = await VocabularyService.updateVocabulary(
      req.params.id,
      req.body,
    );
    res.status(200).json({
      success: true,
      message: "Cập nhật từ vựng thành công",
      data: updatedVocabulary,
    });
  } catch (error) {
    if (error.message === "Vocabulary_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy từ vựng để sửa" });
    }
    if (error.message === "Lesson_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy bài học" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/v1/vocabularies/:id
exports.delete = async (req, res) => {
  try {
    await VocabularyService.deleteVocabulary(req.params.id);
    res.status(200).json({ success: true, message: "Xóa từ vựng thành công" });
  } catch (error) {
    if (error.message === "Vocabulary_Not_Found") {
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy từ vựng để xóa" });
    }
    res.status(500).json({ success: false, message: error.message });
  }
};
