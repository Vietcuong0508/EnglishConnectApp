import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // Cần import http ở đây
import 'package:path_provider/path_provider.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';

final class TopicViewModel extends BaseViewModel {
  List<TopicModel> defaultTopics = [];
  List<TopicModel> localTopics = [];

  // Các biến trạng thái cho UI (nếu cần)
  bool isTranslating = false;
  String translatedText = "";

  // URL API
  final _translateBaseUrl = "https://api-e6gcmhxaeq-uc.a.run.app/translate";
  final _dictionaryUrl = "api.dictionaryapi.dev";

  List<TopicModel> get topics {
    final Map<String, TopicModel> topicMap = {};
    for (var topic in [...defaultTopics, ...localTopics]) {
      topicMap[topic.name.toLowerCase()] = topic;
    }
    return topicMap.values.toList();
  }

  TopicModel? selectedTopic;
  bool isLoading = true;

  String topicName = '';
  String topicDescription = '';

  void setTopicName(String value) {
    topicName = value;
    notifyListeners();
  }

  void setDescription(String value) {
    topicDescription = value;
    notifyListeners();
  }

  bool isValid() =>
      topicName.trim().isNotEmpty && topicDescription.trim().isNotEmpty;

  Future<void> loadTopics() async {
    isLoading = true;
    notifyListeners();

    try {
      // Load default topics from assets
      final assetJson = await rootBundle.loadString('lib/data/topics.json');
      final List<dynamic> assetList = jsonDecode(assetJson);
      defaultTopics =
          assetList.map((json) => TopicModel.fromJson(json)).toList();

      // Load local topics from file
      final directory = await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/topics.json');

      if (await localFile.exists()) {
        final localJson = await localFile.readAsString();
        final List<dynamic> localList = jsonDecode(localJson);
        localTopics =
            localList.map((json) => TopicModel.fromJson(json)).toList();
      } else {
        localTopics = [];
      }
    } catch (e) {
      debugPrint('Lỗi khi load topics: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<TopicModel> addTopic(String name, String description) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/topics.json');

    List<TopicModel> updatedLocalTopics = [];
    if (await file.exists()) {
      final localJson = await file.readAsString();
      final List<dynamic> localList = jsonDecode(localJson);
      updatedLocalTopics =
          localList.map((json) => TopicModel.fromJson(json)).toList();
    }

    final newTopic = TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      imageUrl: null,
      listWord: [],
    );
    debugPrint('👉 Created topic with ID: ${newTopic.id}');

    updatedLocalTopics.add(newTopic);

    final jsonString = jsonEncode(
      updatedLocalTopics.map((e) => e.toJson()).toList(),
    );
    await file.writeAsString(jsonString);

    localTopics = updatedLocalTopics;

    notifyListeners();
    return newTopic;
  }

  Future<void> addWordToTopic({
    required String topicId,
    required String word,
    required String pronunciation,
    required String meaning,
  }) async {
    final index = localTopics.indexWhere((t) => t.id == topicId);
    if (index == -1) {
      debugPrint("Topic not found in localTopics, cannot add word.");
      throw Exception("Topic not found");
    }

    localTopics[index].listWord ??= [];
    localTopics[index].listWord!.add(
      UserWordModel(
        id: DateTime.now().millisecondsSinceEpoch,
        word: word,
        pronunciation: pronunciation,
        meaning: meaning,
      ),
    );

    await saveTopicsToFile();
    notifyListeners();
  }

  Future<void> saveTopicsToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/topics.json');

    final jsonString = jsonEncode(localTopics.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  Future<void> deleteTopic(String id) async {
    localTopics.removeWhere((topic) => topic.id == id);
    await saveTopicsToFile();
    notifyListeners();
  }

  // --- HÀM MỚI: Lấy bản dịch (Trả về String?, không notify toàn app) ---
  Future<String?> fetchTranslation(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
        "$_translateBaseUrl?q=${Uri.encodeComponent(text)}",
      );
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data["result"] as String?)?.trim();
      }
    } catch (e) {
      debugPrint('❌ Translate Error: $e');
    }
    return null;
  }

  // --- HÀM MỚI: Lấy phiên âm (Trả về String?) ---
  Future<String?> fetchPronunciation(String word) async {
    final w = word.trim();
    if (w.isEmpty) return null;

    try {
      final uri = Uri.https(
        _dictionaryUrl,
        '/api/v2/entries/en/${Uri.encodeComponent(w)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return null;

      final List data = jsonDecode(res.body) as List;
      if (data.isEmpty) return null;

      final entry = data.first as Map<String, dynamic>;

      // Ưu tiên lấy text trong mảng phonetics
      if (entry['phonetics'] != null && entry['phonetics'] is List) {
        for (var p in (entry['phonetics'] as List)) {
          if (p is Map &&
              p['text'] != null &&
              (p['text'] as String).trim().isNotEmpty) {
            return (p['text'] as String).trim();
          }
        }
      }
      // Fallback
      if (entry['phonetic'] != null) {
        return (entry['phonetic'] as String).trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
