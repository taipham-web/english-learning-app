import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary_model.dart';

class SavedVocabularyService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // GET - Lấy danh sách từ vựng đã lưu của user
  Future<Map<String, dynamic>> getSavedVocabularies(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/saved-vocabularies/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<SavedVocabularyItem> savedVocabularies =
            (data['data'] as List)
                .map((item) => SavedVocabularyItem.fromJson(item))
                .toList();

        return {'success': true, 'savedVocabularies': savedVocabularies};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Không thể tải danh sách từ vựng đã lưu',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy danh sách ID từ vựng đã lưu
  Future<Map<String, dynamic>> getSavedIds(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/saved-vocabularies/$userId/ids'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<int> savedIds = (data['data'] as List)
            .map((id) => id as int)
            .toList();
        return {'success': true, 'savedIds': savedIds};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách ID',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Kiểm tra từ vựng đã lưu chưa
  Future<Map<String, dynamic>> checkSaved(int userId, int vocabularyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/saved-vocabularies/$userId/check/$vocabularyId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'isSaved': data['data']['isSaved'] ?? false};
      } else {
        return {'success': false, 'isSaved': false};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Lưu từ vựng
  Future<Map<String, dynamic>> saveVocabulary(
    int userId,
    int vocabularyId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/saved-vocabularies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'vocabulary_id': vocabularyId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Đã lưu từ vựng!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể lưu từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Toggle lưu/bỏ lưu từ vựng
  Future<Map<String, dynamic>> toggleSave(int userId, int vocabularyId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/saved-vocabularies/toggle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'vocabulary_id': vocabularyId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final isSaved = data['data'] != null
            ? data['data']['isSaved'] ?? false
            : false;
        return {
          'success': true,
          'isSaved': isSaved,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể thực hiện',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // DELETE - Bỏ lưu từ vựng
  Future<Map<String, dynamic>> unsaveVocabulary(
    int userId,
    int vocabularyId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/saved-vocabularies/$userId/$vocabularyId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã bỏ lưu từ vựng!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể bỏ lưu từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}

// Model cho từ vựng đã lưu (bao gồm thông tin lesson)
class SavedVocabularyItem {
  final int id;
  final int userId;
  final int vocabularyId;
  final String word;
  final String meaning;
  final String? phonetic;
  final String? audioUrl;
  final int? lessonId;
  final String? lessonTitle;
  final DateTime createdAt;

  SavedVocabularyItem({
    required this.id,
    required this.userId,
    required this.vocabularyId,
    required this.word,
    required this.meaning,
    this.phonetic,
    this.audioUrl,
    this.lessonId,
    this.lessonTitle,
    required this.createdAt,
  });

  factory SavedVocabularyItem.fromJson(Map<String, dynamic> json) {
    return SavedVocabularyItem(
      id: json['id'],
      userId: json['user_id'],
      vocabularyId: json['vocabulary_id'],
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      phonetic: json['phonetic'],
      audioUrl: json['audio_url'],
      lessonId: json['lesson_id'],
      lessonTitle: json['lesson_title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to VocabularyModel để sử dụng trong flashcard
  VocabularyModel toVocabularyModel() {
    return VocabularyModel(
      id: vocabularyId,
      lessonId: lessonId ?? 0,
      word: word,
      meaning: meaning,
      phonetic: phonetic,
      audioUrl: audioUrl,
    );
  }
}
