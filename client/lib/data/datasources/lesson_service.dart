import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_model.dart';

class LessonService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // GET - Lấy tất cả bài học
  Future<Map<String, dynamic>> getAllLessons() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lessons'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<LessonModel> lessons = (data['data'] as List)
            .map((item) => LessonModel.fromJson(item))
            .toList();

        return {'success': true, 'lessons': lessons};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy bài học theo topic (có thể lọc theo level)
  Future<Map<String, dynamic>> getLessonsByTopicId(
    int topicId, {
    String? userLevel,
  }) async {
    try {
      String url = '$_baseUrl/lessons?topic_id=$topicId';
      if (userLevel != null) {
        url += '&level=$userLevel';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<LessonModel> lessons = (data['data'] as List)
            .map((item) => LessonModel.fromJson(item))
            .toList();

        return {'success': true, 'lessons': lessons};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy chi tiết bài học
  Future<Map<String, dynamic>> getLessonById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/lessons/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'lesson': LessonModel.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không tìm thấy bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Tạo bài học mới
  Future<Map<String, dynamic>> createLesson({
    required int topicId,
    required String title,
    String? content,
    String? videoUrl,
    String level = 'beginner',
    int difficultyScore = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/lessons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic_id': topicId,
          'title': title,
          'content': content,
          'video_url': videoUrl,
          'level': level,
          'difficulty_score': difficultyScore,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Thêm bài học thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tạo bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // PUT - Cập nhật bài học
  Future<Map<String, dynamic>> updateLesson({
    required int id,
    required int topicId,
    required String title,
    String? content,
    String? videoUrl,
    String level = 'beginner',
    int difficultyScore = 1,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/lessons/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic_id': topicId,
          'title': title,
          'content': content,
          'video_url': videoUrl,
          'level': level,
          'difficulty_score': difficultyScore,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật bài học thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể cập nhật bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // DELETE - Xóa bài học
  Future<Map<String, dynamic>> deleteLesson(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/lessons/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Xóa bài học thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể xóa bài học',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
