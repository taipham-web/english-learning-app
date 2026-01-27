const VocabularyModel = require("../models/vocabulary.model");
const LessonModel = require("../models/lesson.model");

class VocabularyService {
  // Lấy tất cả từ vựng
  static async getAllVocabularies() {
    return await VocabularyModel.getAll();
  }

  // Lấy từ vựng theo lesson
  static async getVocabulariesByLessonId(lessonId) {
    // Kiểm tra lesson có tồn tại không
    const lesson = await LessonModel.getById(lessonId);
    if (!lesson) throw new Error("Lesson_Not_Found");

    return await VocabularyModel.getByLessonId(lessonId);
  }

  // Lấy chi tiết từ vựng
  static async getVocabularyById(id) {
    const vocabulary = await VocabularyModel.getById(id);
    if (!vocabulary) throw new Error("Vocabulary_Not_Found");
    return vocabulary;
  }

  // Tạo từ vựng mới
  static async createVocabulary(data) {
    // Validate dữ liệu
    if (!data.lesson_id) throw new Error("Missing_Lesson_Id");
    if (!data.word) throw new Error("Missing_Word");
    if (!data.meaning) throw new Error("Missing_Meaning");

    // Kiểm tra lesson có tồn tại không
    const lesson = await LessonModel.getById(data.lesson_id);
    if (!lesson) throw new Error("Lesson_Not_Found");

    const newId = await VocabularyModel.create(data);
    return { id: newId, ...data };
  }

  // Tạo nhiều từ vựng cùng lúc
  static async createMultipleVocabularies(lessonId, vocabularies) {
    // Kiểm tra lesson có tồn tại không
    const lesson = await LessonModel.getById(lessonId);
    if (!lesson) throw new Error("Lesson_Not_Found");

    // Validate từng từ vựng
    for (const vocab of vocabularies) {
      if (!vocab.word) throw new Error("Missing_Word");
      if (!vocab.meaning) throw new Error("Missing_Meaning");
    }

    const count = await VocabularyModel.createBulk(lessonId, vocabularies);
    return { count };
  }

  // Cập nhật từ vựng
  static async updateVocabulary(id, data) {
    const existingVocabulary = await VocabularyModel.getById(id);
    if (!existingVocabulary) throw new Error("Vocabulary_Not_Found");

    // Nếu có cập nhật lesson_id, kiểm tra lesson mới có tồn tại không
    if (data.lesson_id) {
      const lesson = await LessonModel.getById(data.lesson_id);
      if (!lesson) throw new Error("Lesson_Not_Found");
    }

    await VocabularyModel.update(id, {
      lesson_id: data.lesson_id || existingVocabulary.lesson_id,
      word: data.word || existingVocabulary.word,
      meaning: data.meaning || existingVocabulary.meaning,
      phonetic:
        data.phonetic !== undefined
          ? data.phonetic
          : existingVocabulary.phonetic,
      audio_url:
        data.audio_url !== undefined
          ? data.audio_url
          : existingVocabulary.audio_url,
    });

    return { id, ...data };
  }

  // Xóa từ vựng
  static async deleteVocabulary(id) {
    const existingVocabulary = await VocabularyModel.getById(id);
    if (!existingVocabulary) throw new Error("Vocabulary_Not_Found");

    await VocabularyModel.delete(id);
    return true;
  }

  // Đếm số từ vựng trong lesson
  static async countVocabulariesByLesson(lessonId) {
    return await VocabularyModel.countByLessonId(lessonId);
  }
}

module.exports = VocabularyService;
