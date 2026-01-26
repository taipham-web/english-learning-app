const TopicService = require("../services/topic.service");

// GET /api/v1/topics
exports.getAll = async (req, res) => {
  try {
    const topics = await TopicService.getAllTopics();
    res.status(200).json({ success: true, data: topics });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/topics/:id
exports.getOne = async (req, res) => {
  try {
    const topic = await TopicService.getTopicById(req.params.id);
    res.status(200).json({ success: true, data: topic });
  } catch (error) {
    if (error.message === "Topic_Not_Found")
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề" });
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/v1/topics
exports.create = async (req, res) => {
  try {
    const newTopic = await TopicService.createTopic(req.body);
    // Chuẩn REST: Tạo mới thành công trả về 201
    res.status(201).json({
      success: true,
      message: "Tạo chủ đề thành công",
      data: newTopic,
    });
  } catch (error) {
    if (error.message === "Missing_Name")
      return res
        .status(400)
        .json({ success: false, message: "Tên chủ đề là bắt buộc" });
    res.status(500).json({ success: false, message: error.message });
  }
};

// PUT /api/v1/topics/:id
exports.update = async (req, res) => {
  try {
    const updatedTopic = await TopicService.updateTopic(
      req.params.id,
      req.body,
    );
    res.status(200).json({
      success: true,
      message: "Cập nhật thành công",
      data: updatedTopic,
    });
  } catch (error) {
    if (error.message === "Topic_Not_Found")
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề để sửa" });
    res.status(500).json({ success: false, message: error.message });
  }
};

// DELETE /api/v1/topics/:id
exports.delete = async (req, res) => {
  try {
    await TopicService.deleteTopic(req.params.id);
    res.status(200).json({ success: true, message: "Xóa thành công" });
  } catch (error) {
    if (error.message === "Topic_Not_Found")
      return res
        .status(404)
        .json({ success: false, message: "Không tìm thấy chủ đề để xóa" });
    res.status(500).json({ success: false, message: error.message });
  }
};
