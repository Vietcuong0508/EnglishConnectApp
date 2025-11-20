import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple Datamuse service for suggestions (no API key required)
class DatamuseService {
  static const _base = 'api.datamuse.com';

  /// Gợi ý theo prefix (autocomplete-like)
  /// Trả về list từ (strings)
  static Future<List<String>> suggestByPrefix(
    String prefix, {
    int max = 10,
  }) async {
    final q = prefix.trim();
    if (q.isEmpty) return [];

    // MẸO: Vì chúng ta sẽ lọc bỏ các từ có dấu cách,
    // nên ta cần yêu cầu API trả về nhiều hơn số lượng cần thiết (ví dụ gấp đôi)
    // để sau khi lọc đi vẫn còn đủ số lượng hiển thị.
    final fetchLimit = max * 2;

    final uri = Uri.https(_base, '/sug', {'s': q, 'max': '$fetchLimit'});

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return [];

      final List data = json.decode(res.body) as List;

      return data
          .map<String>((e) => (e['word'] as String))
          .where((word) {
            // --- BỘ LỌC TỪ ĐƠN ---
            final w = word.trim();
            // 1. Phải có dữ liệu
            if (w.isEmpty) return false;
            // 2. Không được chứa dấu cách (loại bỏ cụm từ)
            if (w.contains(' ')) return false;
            // 3. (Tùy chọn) Chỉ lấy từ chứa chữ cái (bỏ số, ký tự lạ)
            // if (RegExp(r'[^a-zA-Z]').hasMatch(w)) return false;

            return true;
          })
          .take(max) // Cắt đúng số lượng yêu cầu sau khi lọc
          .toList();
    } catch (_) {
      return [];
    }
  }
}
