const express = require("express");
const router = express.Router();
const statsController = require("../controllers/stats.controller");

router.get("/", statsController.getStats);
router.get("/user/:userId", statsController.getUserStats);

module.exports = router;

