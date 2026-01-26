const LessonModel = require("../models/lesson.model");
const TopicModel = require("../models/topic.model");

class LessonService {
  // Lấy tất cả bài học
  static async getAllLessons() {
    return await LessonModel.getAll();
  }

  // Lấy bài học theo topic
  static async getLessonsByTopicId(topicId, userLevel = null) {
    // Kiểm tra topic có tồn tại không
    const topic = await TopicModel.getById(topicId);
    if (!topic) throw new Error("Topic_Not_Found");

    // Nếu có level, lọc theo level
    if (userLevel) {
      return await LessonModel.getByTopicIdAndLevel(topicId, userLevel);
    }
    return await LessonModel.getByTopicId(topicId);
  }

  // Lấy chi tiết bài học
  static async getLessonById(id) {
    const lesson = await LessonModel.getById(id);
    if (!lesson) throw new Error("Lesson_Not_Found");
    return lesson;
  }

  // Tạo bài học mới
  static async createLesson(data) {
    // Validate dữ liệu
    if (!data.topic_id) throw new Error("Missing_Topic_Id");
    if (!data.title) throw new Error("Missing_Title");

    // Kiểm tra topic có tồn tại không
    const topic = await TopicModel.getById(data.topic_id);
    if (!topic) throw new Error("Topic_Not_Found");

    const newId = await LessonModel.create(data);
    return { id: newId, ...data };
  }

  // Cập nhật bài học
  static async updateLesson(id, data) {
    const existingLesson = await LessonModel.getById(id);
    if (!existingLesson) throw new Error("Lesson_Not_Found");

    // Nếu có cập nhật topic_id, kiểm tra topic mới có tồn tại không
    if (data.topic_id) {
      const topic = await TopicModel.getById(data.topic_id);
      if (!topic) throw new Error("Topic_Not_Found");
    }

    await LessonModel.update(id, {
      topic_id: data.topic_id || existingLesson.topic_id,
      title: data.title || existingLesson.title,
      content:
        data.content !== undefined ? data.content : existingLesson.content,
      video_url:
        data.video_url !== undefined
          ? data.video_url
          : existingLesson.video_url,
      level: data.level || existingLesson.level || "beginner",
      difficulty_score:
        data.difficulty_score !== undefined
          ? data.difficulty_score
          : existingLesson.difficulty_score || 1,
    });

    return { id, ...data };
  }

  // Xóa bài học
  static async deleteLesson(id) {
    const existingLesson = await LessonModel.getById(id);
    if (!existingLesson) throw new Error("Lesson_Not_Found");

    await LessonModel.delete(id);
    return true;
  }

  // Đếm số bài học trong topic
  static async countLessonsByTopic(topicId) {
    return await LessonModel.countByTopicId(topicId);
  }
}

module.exports = LessonService;
