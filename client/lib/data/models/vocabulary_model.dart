class VocabularyModel {
  final int? id;
  final int lessonId;
  final String word;
  final String meaning;
  final String? phonetic;
  final String? audioUrl;
  final DateTime? createdAt;

  VocabularyModel({
    this.id,
    required this.lessonId,
    required this.word,
    required this.meaning,
    this.phonetic,
    this.audioUrl,
    this.createdAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'],
      lessonId: json['lesson_id'],
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      phonetic: json['phonetic'],
      audioUrl: json['audio_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'word': word,
      'meaning': meaning,
      'phonetic': phonetic,
      'audio_url': audioUrl,
    };
  }

  VocabularyModel copyWith({
    int? id,
    int? lessonId,
    String? word,
    String? meaning,
    String? phonetic,
    String? audioUrl,
    DateTime? createdAt,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
