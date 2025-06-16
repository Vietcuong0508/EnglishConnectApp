import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';

final class TopicViewModel extends BaseViewModel {
  List<TopicModel> defaultTopics = [];
  List<TopicModel> localTopics = [];

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
    final newTopic = TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      imageUrl: null,
      listWord: [],
    );
    debugPrint('👉 Created topic with ID: ${newTopic.id}');

    // Thêm vào localTopics
    localTopics.add(newTopic);

    // Ghi đè file local
    await saveTopicsToFile();

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
}
