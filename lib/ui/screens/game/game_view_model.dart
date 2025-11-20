import 'dart:convert';
import 'dart:io';

import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

final class GameViewModel extends BaseViewModel {
  final FlutterTts tts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  final RandomWordService _randomService = RandomWordService();

  List<WordModel> words = [];
  int currentLevel = 0;

  WordModel? get currentWord =>
      words.isNotEmpty && currentLevel < words.length
          ? words[currentLevel]
          : null;

  List<String> letters = [];
  final List<Offset> points = [];
  final List<int> selectedIndexes = [];
  Offset? currentDragPosition;
  final Map<int, GlobalKey> keyMap = {};

  /// Hàm khởi tạo chính cho màn chơi
  Future<void> initGame(String? topicName) async {
    // 1. Reset toàn bộ dữ liệu cũ
    resetGameData();

    // 2. Load dữ liệu mới
    await _loadWords(topicName);

    // 3. Chuẩn bị level đầu tiên
    initializeLevel();
    notifyListeners();
  }

  void resetGameData() {
    words.clear();
    currentLevel = 0;
    letters.clear();
    selectedIndexes.clear();
    points.clear();
    keyMap.clear();
    currentDragPosition = null;
  }

  Future<void> _loadWords(String? topicName) async {
    List<WordModel> loadedWords = [];

    try {
      if (topicName != null && topicName.isNotEmpty) {
        // --- CASE A: CHƠI THEO CHỦ ĐỀ ---
        loadedWords = await _loadFromTopic(topicName);
      } else {
        // --- CASE B: CHƠI RANDOM ---
        // Gọi service lấy từ hỗn hợp
        loadedWords = await _randomService.getMixedWords();
      }

      if (loadedWords.isEmpty) return;

      // --- LOGIC GIỚI HẠN SỐ TỪ ---
      // Xáo trộn lần nữa cho chắc chắn
      loadedWords.shuffle();
      // Chỉ lấy tối đa 15 từ
      words = loadedWords.take(15).toList();
    } catch (e) {
      debugPrint('❌ Lỗi load game: $e');
    }
  }

  Future<List<WordModel>> _loadFromTopic(String topicName) async {
    try {
      // Thử load từ Asset trước
      final jsonString = await rootBundle.loadString(
        'lib/data/${topicName.toLowerCase()}.json',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WordModel.fromJson(json)).toList();
    } catch (_) {
      // Nếu không có asset, thử load từ local storage
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/topics.json');
        if (await file.exists()) {
          final localJson = await file.readAsString();
          final List<dynamic> localList = jsonDecode(localJson);
          final topics = localList.map((e) => TopicModel.fromJson(e)).toList();

          final topic = topics.firstWhere(
            (t) =>
                t.name.trim().toLowerCase() == topicName.trim().toLowerCase(),
          );
          return topic.listWord
                  ?.map(
                    (w) => WordModel(
                      id: w.id,
                      word: w.word,
                      pronunciation: w.pronunciation,
                      meaning: w.meaning,
                    ),
                  )
                  .toList() ??
              [];
        }
      } catch (e) {
        debugPrint("Topic not found: $e");
      }
    }
    return [];
  }

  void initializeLevel() {
    if (currentWord == null) return;

    letters = currentWord!.word.split('')..shuffle();
    selectedIndexes.clear();
    points.clear();
    keyMap.clear();
    currentDragPosition = null;

    for (int i = 0; i < letters.length; i++) {
      keyMap[i] = GlobalKey();
    }
  }

  void resetLevel() {
    if (currentWord == null) return;
    // Xáo trộn lại chữ cái khi chơi lại level này
    letters = currentWord!.word.split('')..shuffle();
    selectedIndexes.clear();
    points.clear();
    currentDragPosition = null;
    notifyListeners();
  }

  void nextLevel() {
    if (currentLevel < words.length - 1) {
      currentLevel++;
      initializeLevel();
      notifyListeners();
    }
  }

  void previousLevel() {
    if (currentLevel > 0) {
      currentLevel--;
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
}
