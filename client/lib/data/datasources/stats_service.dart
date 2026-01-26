import 'dart:convert';
import 'package:http/http.dart' as http;

class StatsService {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/v1';

  // GET - Lấy thống kê
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'stats': data['data']};
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
}
