import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vocabulary_model.dart';

class VocabularyService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';
  static const String _dictionaryApiUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  // GET - Lấy từ vựng theo lesson_id
  Future<Map<String, dynamic>> getVocabulariesByLessonId(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vocabularies?lesson_id=$lessonId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<VocabularyModel> vocabularies = (data['data'] as List)
            .map((item) => VocabularyModel.fromJson(item))
            .toList();

        return {'success': true, 'vocabularies': vocabularies};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy chi tiết từ vựng theo id
  Future<Map<String, dynamic>> getVocabularyById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/vocabularies/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'vocabulary': VocabularyModel.fromJson(data['data']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không tìm thấy từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Tạo từ vựng mới
  Future<Map<String, dynamic>> createVocabulary({
    required int lessonId,
    required String word,
    required String meaning,
    String? phonetic,
    String? audioUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vocabularies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lesson_id': lessonId,
          'word': word,
          'meaning': meaning,
          'phonetic': phonetic,
          'audio_url': audioUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Thêm từ vựng thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể thêm từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Tạo nhiều từ vựng cùng lúc
  Future<Map<String, dynamic>> createMultipleVocabularies({
    required int lessonId,
    required List<VocabularyModel> vocabularies,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/vocabularies/bulk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lesson_id': lessonId,
          'vocabularies': vocabularies
              .map(
                (v) => {
                  'word': v.word,
                  'meaning': v.meaning,
                  'phonetic': v.phonetic,
                  'audio_url': v.audioUrl,
                },
              )
              .toList(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Thêm ${vocabularies.length} từ vựng thành công!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể thêm từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // PUT - Cập nhật từ vựng
  Future<Map<String, dynamic>> updateVocabulary({
    required int id,
    required int lessonId,
    required String word,
    required String meaning,
    String? phonetic,
    String? audioUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/vocabularies/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lesson_id': lessonId,
          'word': word,
          'meaning': meaning,
          'phonetic': phonetic,
          'audio_url': audioUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật từ vựng thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể cập nhật từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // DELETE - Xóa từ vựng
  Future<Map<String, dynamic>> deleteVocabulary(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/vocabularies/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Xóa từ vựng thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể xóa từ vựng',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Tra cứu từ điển từ Dictionary API
  Future<Map<String, dynamic>> lookupWord(String word) async {
    try {
      final response = await http.get(
        Uri.parse('$_dictionaryApiUrl/$word'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final entry = data[0];
          String? phonetic;
          String? audioUrl;

          // Lấy phonetic
          if (entry['phonetic'] != null) {
            phonetic = entry['phonetic'];
          } else if (entry['phonetics'] != null &&
              (entry['phonetics'] as List).isNotEmpty) {
            for (var p in entry['phonetics']) {
              if (p['text'] != null && p['text'].toString().isNotEmpty) {
                phonetic = p['text'];
                break;
              }
            }
          }

          // Lấy audio URL (ưu tiên US pronunciation)
          if (entry['phonetics'] != null) {
            for (var p in entry['phonetics']) {
              if (p['audio'] != null && p['audio'].toString().isNotEmpty) {
                audioUrl = p['audio'];
                // Ưu tiên US pronunciation
                if (audioUrl!.contains('-us') || audioUrl.contains('_us')) {
                  break;
                }
              }
            }
          }

          // Lấy các định nghĩa
          List<String> definitions = [];
          if (entry['meanings'] != null) {
            for (var meaning in entry['meanings']) {
              String partOfSpeech = meaning['partOfSpeech'] ?? '';
              if (meaning['definitions'] != null) {
                for (var def in meaning['definitions']) {
                  if (def['definition'] != null) {
                    definitions.add('($partOfSpeech) ${def['definition']}');
                    if (definitions.length >= 3) break;
                  }
                }
              }
              if (definitions.length >= 3) break;
            }
          }

          return {
            'success': true,
            'word': entry['word'],
            'phonetic': phonetic,
            'audioUrl': audioUrl,
            'definitions': definitions,
          };
        }
      }
      return {
        'success': false,
        'message': 'Không tìm thấy từ "$word" trong từ điển',
      };
    } catch (e) {
      return {'success': false, 'message': 'Lỗi tra cứu từ điển: $e'};
    }
  }
}
