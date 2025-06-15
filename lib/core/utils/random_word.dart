import 'dart:convert';
import 'dart:math';
import 'package:english_connect/models/model.dart';
import 'package:flutter/services.dart';

class RandomWordService {
  final List<String> jsonFiles = [
    'lib/data/animals.json',
    'lib/data/colors.json',
    'lib/data/fruits.json',
    'lib/data/jobs.json',
    'lib/data/vehicles.json',
  ];

  final Random _random = Random();

  Future<List<WordModel>> getOneRandomWordFromEachFile() async {
    List<WordModel> result = [];

    for (String filePath in jsonFiles) {
      try {
        // Đọc file
        final jsonString = await rootBundle.loadString(filePath);
        final jsonData = json.decode(jsonString);

        // Parse danh sách từ
        if (jsonData is List && jsonData.isNotEmpty) {
          final words = jsonData.map((e) => WordModel.fromJson(e)).toList();
          final randomWord = words[_random.nextInt(words.length)];
          result.add(randomWord);
        }
      } catch (e) {
        print("Lỗi khi đọc file $filePath: $e");
      }
    }

    return result;
  }
}
