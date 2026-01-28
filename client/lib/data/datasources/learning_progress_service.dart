import 'dart:convert';
import 'package:http/http.dart' as http;

class LearningProgressService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // POST - Đánh dấu hoàn thành bài học
  Future<Map<String, dynamic>> completeLesson(int userId, int lessonId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/learning-progress/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'lessonId': lessonId}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể cập nhật tiến độ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy tiến độ của user
  Future<Map<String, dynamic>> getUserProgress(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning-progress/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải tiến độ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Kiểm tra bài học đã hoàn thành chưa
  Future<bool> isLessonCompleted(int userId, int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/learning-progress/check/$userId/$lessonId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data']['is_completed'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // DELETE - Xóa tiến độ bài học
  Future<bool> removeProgress(int userId, int lessonId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/learning-progress/$userId/$lessonId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
