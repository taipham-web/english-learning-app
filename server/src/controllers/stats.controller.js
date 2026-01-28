const StatsModel = require("../models/stats.model");

// GET /api/v1/stats
exports.getStats = async (req, res) => {
  try {
    const stats = await StatsModel.getAllStats();
    res.status(200).json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/v1/stats/user/:userId
exports.getUserStats = async (req, res) => {
  try {
    const { userId } = req.params;
    const stats = await StatsModel.getUserStats(userId);
    res.status(200).json({ success: true, data: stats });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
