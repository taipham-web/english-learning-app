class LessonModel {
  final int id;
  final int topicId;
  final String title;
  final String? content;
  final String? videoUrl;
  final String? topicName;
  final String level;
  final int difficultyScore;
  final DateTime? createdAt;

  LessonModel({
    required this.id,
    required this.topicId,
    required this.title,
    this.content,
    this.videoUrl,
    this.topicName,
    this.level = 'beginner',
    this.difficultyScore = 1,
    this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      topicId: json['topic_id'],
      title: json['title'] ?? '',
      content: json['content'],
      videoUrl: json['video_url'],
      topicName: json['topic_name'],
      level: json['level'] ?? 'beginner',
      difficultyScore: json['difficulty_score'] ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'content': content,
      'video_url': videoUrl,
      'level': level,
      'difficulty_score': difficultyScore,
    };
  }

  // Helper để lấy tên hiển thị của level
  String get levelDisplay {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
