const savedVocabularyService = require("../services/savedVocabulary.service");

class SavedVocabularyController {
  // GET /saved-vocabularies/:userId
  async getSavedVocabularies(req, res) {
    const { userId } = req.params;
    const result = await savedVocabularyService.getSavedVocabularies(userId);

    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(500).json(result);
    }
  }

  // POST /saved-vocabularies
  async saveVocabulary(req, res) {
    const { user_id, vocabulary_id } = req.body;

    if (!user_id || !vocabulary_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu user_id hoặc vocabulary_id",
      });
    }

    const result = await savedVocabularyService.saveVocabulary(
      user_id,
      vocabulary_id,
    );
    res.status(result.success ? 201 : 400).json(result);
  }

  // DELETE /saved-vocabularies/:userId/:vocabularyId
  async unsaveVocabulary(req, res) {
    const { userId, vocabularyId } = req.params;
    const result = await savedVocabularyService.unsaveVocabulary(
      userId,
      vocabularyId,
    );
    res.status(result.success ? 200 : 404).json(result);
  }

  // POST /saved-vocabularies/toggle
  async toggleSave(req, res) {
    const { user_id, vocabulary_id } = req.body;

    if (!user_id || !vocabulary_id) {
      return res.status(400).json({
        success: false,
        message: "Thiếu user_id hoặc vocabulary_id",
      });
    }

    const result = await savedVocabularyService.toggleSave(
      user_id,
      vocabulary_id,
    );
    res.status(result.success ? 200 : 500).json(result);
  }

  // GET /saved-vocabularies/:userId/ids
  async getSavedIds(req, res) {
    const { userId } = req.params;
    const result = await savedVocabularyService.getSavedIds(userId);
    res.status(result.success ? 200 : 500).json(result);
  }

  // GET /saved-vocabularies/:userId/check/:vocabularyId
  async checkSaved(req, res) {
    const { userId, vocabularyId } = req.params;
    const result = await savedVocabularyService.checkSaved(
      userId,
      vocabularyId,
    );
    res.status(result.success ? 200 : 500).json(result);
  }
}

module.exports = new SavedVocabularyController();
