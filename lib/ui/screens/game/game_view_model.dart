import 'dart:convert';
import 'dart:io';

import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

final class GameViewModel extends BaseViewModel {
  final FlutterTts tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  List<WordModel> words = [];
  int currentLevel = 0;
  WordModel? get currentWord => words.isNotEmpty ? words[currentLevel] : null;

  List<String> letters = [];
  final List<Offset> points = [];
  final List<int> selectedIndexes = [];
  Offset? currentDragPosition;
  final Map<int, GlobalKey> keyMap = {};

  /// Load từ vựng từ file theo chủ đề
  Future<void> loadWords(String? topicName, List<WordModel>? randomWord) async {
    try {
      if (topicName != null && topicName.isNotEmpty) {
        try {
          // 🔹 Ưu tiên: Load từ file asset
          final jsonString = await rootBundle.loadString(
            'lib/data/${topicName.toLowerCase()}.json',
          );

          final List<dynamic> jsonList = jsonDecode(jsonString);
          words = jsonList.map((json) => WordModel.fromJson(json)).toList();
        } catch (e) {
          // 🔸 Nếu asset không có, load từ local topics.json
          debugPrint('⚠️ Không tìm thấy file asset: $e');
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/topics.json');

          if (await file.exists()) {
            final localJson = await file.readAsString();
            final List<dynamic> localList = jsonDecode(localJson);
            final topics =
                localList.map((e) => TopicModel.fromJson(e)).toList();

            final topic = topics.firstWhere(
              (t) =>
                  t.name.trim().toLowerCase() == topicName.trim().toLowerCase(),
              orElse:
                  () =>
                      throw Exception(
                        '❌ Topic "$topicName" not found in local.',
                      ),
            );

            if (topic.listWord == null || topic.listWord!.isEmpty) {
              debugPrint('🔍 Topic "$topicName" has no words.');
              return;
            }

            words =
                topic.listWord!
                    .map(
                      (w) => WordModel(
                        id: w.id,
                        word: w.word,
                        pronunciation: w.pronunciation,
                        meaning: w.meaning,
                        image: w.image,
                      ),
                    )
                    .toList();
          } else {
            debugPrint('❌ Không tìm thấy local topics.json');
            return;
          }
        }
      } else if (randomWord != null && randomWord.isNotEmpty) {
        // 🔹 Nếu truyền sẵn danh sách random
        words = randomWord;
      } else {
        debugPrint('❌ Không có dữ liệu để load.');
        return;
      }

      currentLevel = 0;
      initializeLevel();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Lỗi khi load từ chủ đề: $e');
    }
  }

  /// Khởi tạo chữ cái, key
  void initializeLevel() {
    if (currentWord == null) return;
    letters = currentWord!.word.split('')..shuffle();
    selectedIndexes.clear();
    points.clear();
    keyMap.clear();
    for (int i = 0; i < letters.length; i++) {
      keyMap[i] = GlobalKey();
    }
  }

  void resetLevel() {
    if (currentWord == null) return;
    letters = currentWord!.word.split('')..shuffle();
    selectedIndexes.clear();
    points.clear();
    notifyListeners();
  }

  void nextLevel() {
    if (currentLevel < words.length - 1) {
      currentLevel++;
      initializeLevel();
      notifyListeners();
    }
  }

  String getSelectedWord() {
    return selectedIndexes.map((i) => letters[i]).join();
  }

  bool isCorrectAnswer() {
    return currentWord != null &&
        getSelectedWord().toLowerCase() == currentWord!.word.toLowerCase();
  }

  Future<void> playSoundCorrect() async {
    await audioPlayer.setSource(AssetSource('sounds/correct.mp3'));
    await audioPlayer.resume();
    HapticFeedback.lightImpact();
  }

  Future<void> playSoundWrong() async {
    await audioPlayer.setSource(AssetSource('sounds/wrong.mp3'));
    await audioPlayer.resume();
    HapticFeedback.heavyImpact();
  }

  Future<void> speakWord() async {
    if (currentWord == null) return;
    await tts.setLanguage('en-US');
    await tts.setPitch(1.0);
    await tts.speak(currentWord!.word);
  }

  /// Reset toàn bộ trò chơi
  void resetGame() {
    currentLevel = 0;
    letters.clear();
    selectedIndexes.clear();
    points.clear();
    keyMap.clear();
    words.clear();
    notifyListeners();
  }
}
