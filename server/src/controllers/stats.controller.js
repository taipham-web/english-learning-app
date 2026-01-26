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
