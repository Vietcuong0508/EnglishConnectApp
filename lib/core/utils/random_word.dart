import 'dart:convert';
import 'dart:math';
import 'package:english_connect/models/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RandomWordService {
  final List<String> jsonFiles = [
    'lib/data/animals.json',
    'lib/data/colors.json',
    'lib/data/fruits.json',
    'lib/data/jobs.json',
    'lib/data/vehicles.json',
  ];

  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  /// Lấy danh sách từ hỗn hợp từ tất cả các file
  Future<List<WordModel>> getMixedWords() async {
    List<WordModel> result = [];

    for (String filePath in jsonFiles) {
      try {
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = json.decode(jsonString);

        if (jsonData is List && jsonData.isNotEmpty) {
          final words = jsonData.map((e) => WordModel.fromJson(e)).toList();
          // Xáo trộn và lấy 1 từ ngẫu nhiên từ file này
          words.shuffle(_random);
          result.add(words.first);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Lỗi đọc file $filePath: $e");
        }
      }
    }

    // Xáo trộn kết quả cuối cùng
    result.shuffle(_random);
    return result;
  }
}
