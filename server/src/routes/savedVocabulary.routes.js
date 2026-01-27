const express = require("express");
const router = express.Router();
const savedVocabularyController = require("../controllers/savedVocabulary.controller");

// GET - Lấy danh sách từ vựng đã lưu của user
router.get("/:userId", savedVocabularyController.getSavedVocabularies);

// GET - Lấy danh sách ID từ vựng đã lưu
router.get("/:userId/ids", savedVocabularyController.getSavedIds);

// GET - Kiểm tra từ vựng đã lưu chưa
router.get(
  "/:userId/check/:vocabularyId",
  savedVocabularyController.checkSaved,
);

// POST - Lưu từ vựng
router.post("/", savedVocabularyController.saveVocabulary);

// POST - Toggle lưu/bỏ lưu
router.post("/toggle", savedVocabularyController.toggleSave);

// DELETE - Bỏ lưu từ vựng
router.delete(
  "/:userId/:vocabularyId",
  savedVocabularyController.unsaveVocabulary,
);

module.exports = router;
