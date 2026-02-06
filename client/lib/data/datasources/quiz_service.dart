import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_model.dart';

class QuizService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // GET - Lấy quiz theo lesson ID
  Future<Map<String, dynamic>> getQuizByLessonId(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quizzes/lesson/$lessonId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'quiz': QuizModel.fromJson(data['data'])};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': data['message'] ?? 'Chưa có bài kiểm tra cho bài học này',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải bài kiểm tra',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy quiz theo ID
  Future<Map<String, dynamic>> getQuizById(int quizId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quizzes/$quizId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'quiz': QuizModel.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không tìm thấy bài kiểm tra',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Submit kết quả quiz
  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required QuizSubmission submission,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quizzes/$quizId/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(submission.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'result': QuizResult.fromJson(data['data']),
          'message': data['message'] ?? 'Đã nộp bài thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể nộp bài',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy lịch sử làm bài của user
  Future<Map<String, dynamic>> getUserQuizHistory({
    required int userId,
    int? quizId,
  }) async {
    try {
      String url = '$_baseUrl/quizzes/results/user/$userId';
      if (quizId != null) {
        url += '?quiz_id=$quizId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<QuizHistory> history = (data['data'] as List)
            .map((item) => QuizHistory.fromJson(item))
            .toList();

        return {'success': true, 'history': history};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải lịch sử',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy điểm cao nhất của user cho một quiz
  Future<Map<String, dynamic>> getUserBestScore({
    required int userId,
    required int quizId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quizzes/$quizId/best-score/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final bestScore = data['data'] != null
            ? QuizHistory.fromJson(data['data'])
            : null;

        return {'success': true, 'best_score': bestScore};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải điểm cao nhất',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy thống kê quiz của user
  Future<Map<String, dynamic>> getUserQuizStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quizzes/stats/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'stats': QuizStats.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải thống kê',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Tạo quiz mới (Admin)
  Future<Map<String, dynamic>> createQuiz({
    required int lessonId,
    required String title,
    String? description,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quizzes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lesson_id': lessonId,
          'title': title,
          'description': description,
          'questions': questions,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Tạo bài kiểm tra thành công!',
          'quiz_id': data['data']['quizId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tạo bài kiểm tra',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // PUT - Cập nhật quiz (Admin)
  Future<Map<String, dynamic>> updateQuiz({
    required int quizId,
    required int lessonId,
    required String title,
    String? description,
    required List<Map<String, dynamic>> questions,
    int? passingScore,
    int? timeLimit,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/quizzes/$quizId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lesson_id': lessonId,
          'title': title,
          'description': description,
          'questions': questions,
          if (passingScore != null) 'passing_score': passingScore,
          if (timeLimit != null) 'time_limit': timeLimit,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Cập nhật bài kiểm tra thành công!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể cập nhật bài kiểm tra',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // DELETE - Xóa quiz
  Future<Map<String, dynamic>> deleteQuiz(int quizId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/quizzes/$quizId'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Xóa bài kiểm tra thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể xóa bài kiểm tra',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
