import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/topic_model.dart';

class TopicService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // GET - Lấy danh sách topics
  Future<Map<String, dynamic>> getAllTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/topics'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<TopicModel> topics = (data['data'] as List)
            .map((item) => TopicModel.fromJson(item))
            .toList();

        return {'success': true, 'topics': topics};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tải danh sách chủ đề',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // GET - Lấy chi tiết topic
  Future<Map<String, dynamic>> getTopicById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/topics/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'topic': TopicModel.fromJson(data['data'])};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không tìm thấy chủ đề',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // POST - Tạo topic mới
  Future<Map<String, dynamic>> createTopic({
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/topics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'image_url': imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Thêm chủ đề thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể tạo chủ đề',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // PUT - Cập nhật topic
  Future<Map<String, dynamic>> updateTopic({
    required int id,
    required String name,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/topics/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'image_url': imageUrl,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật chủ đề thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể cập nhật chủ đề',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // DELETE - Xóa topic
  Future<Map<String, dynamic>> deleteTopic(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/topics/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Xóa chủ đề thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể xóa chủ đề',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
