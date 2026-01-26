const TopicModel = require("../models/topic.model");

class TopicService {
  static async getAllTopics() {
    return await TopicModel.getAll();
  }

  static async getTopicById(id) {
    const topic = await TopicModel.getById(id);
    if (!topic) throw new Error("Topic_Not_Found");
    return topic;
  }

  static async createTopic(data) {
    // Validate dữ liệu
    if (!data.name) throw new Error("Missing_Name");

    const newId = await TopicModel.create(data);
    return { id: newId, ...data };
  }

  static async updateTopic(id, data) {
    const existingTopic = await TopicModel.getById(id);
    if (!existingTopic) throw new Error("Topic_Not_Found");

    await TopicModel.update(id, data);
    return { id, ...data };
  }

  static async deleteTopic(id) {
    const existingTopic = await TopicModel.getById(id);
    if (!existingTopic) throw new Error("Topic_Not_Found");

    await TopicModel.delete(id);
    return true;
  }
}

module.exports = TopicService;
