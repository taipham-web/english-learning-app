const SavedVocabularyModel = require("../models/savedVocabulary.model");

class SavedVocabularyService {
  async getSavedVocabularies(userId) {
    try {
      const vocabularies = await SavedVocabularyModel.getByUserId(userId);
      return { success: true, data: vocabularies };
    } catch (error) {
      console.error("Error getting saved vocabularies:", error);
      return {
        success: false,
        message: "Lỗi khi lấy danh sách từ vựng đã lưu",
      };
    }
  }

  async saveVocabulary(userId, vocabularyId) {
    try {
      // Kiểm tra đã lưu chưa
      const isSaved = await SavedVocabularyModel.checkSaved(
        userId,
        vocabularyId,
      );
      if (isSaved) {
        return { success: false, message: "Từ vựng đã được lưu trước đó" };
      }

      await SavedVocabularyModel.save(userId, vocabularyId);
      return { success: true, message: "Đã lưu từ vựng" };
    } catch (error) {
      console.error("Error saving vocabulary:", error);
      return { success: false, message: "Lỗi khi lưu từ vựng" };
    }
  }

  async unsaveVocabulary(userId, vocabularyId) {
    try {
      const result = await SavedVocabularyModel.unsave(userId, vocabularyId);
      if (result) {
        return { success: true, message: "Đã bỏ lưu từ vựng" };
      }
      return { success: false, message: "Không tìm thấy từ vựng đã lưu" };
    } catch (error) {
      console.error("Error unsaving vocabulary:", error);
      return { success: false, message: "Lỗi khi bỏ lưu từ vựng" };
    }
  }

  async toggleSave(userId, vocabularyId) {
    try {
      const isSaved = await SavedVocabularyModel.checkSaved(
        userId,
        vocabularyId,
      );
      if (isSaved) {
        await SavedVocabularyModel.unsave(userId, vocabularyId);
        return {
          success: true,
          data: { isSaved: false },
          message: "Đã bỏ lưu từ vựng",
        };
      } else {
        await SavedVocabularyModel.save(userId, vocabularyId);
        return {
          success: true,
          data: { isSaved: true },
          message: "Đã lưu từ vựng",
        };
      }
    } catch (error) {
      console.error("Error toggling save:", error);
      return { success: false, message: "Lỗi khi thay đổi trạng thái lưu" };
    }
  }

  async getSavedIds(userId) {
    try {
      const ids = await SavedVocabularyModel.getSavedIds(userId);
      return { success: true, data: ids };
    } catch (error) {
      console.error("Error getting saved ids:", error);
      return { success: false, message: "Lỗi khi lấy danh sách ID" };
    }
  }

  async checkSaved(userId, vocabularyId) {
    try {
      const isSaved = await SavedVocabularyModel.checkSaved(
        userId,
        vocabularyId,
      );
      return { success: true, saved: isSaved };
    } catch (error) {
      console.error("Error checking saved:", error);
      return { success: false, message: "Lỗi khi kiểm tra trạng thái" };
    }
  }
}

module.exports = new SavedVocabularyService();
