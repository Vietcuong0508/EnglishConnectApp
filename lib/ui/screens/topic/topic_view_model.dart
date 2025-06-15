import 'dart:convert';

import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/services.dart';

final class TopicViewModel extends BaseViewModel {
  List<TopicModel> topics = [];
  TopicModel? selectedTopic;
  bool isLoading = true;

  /// Load danh sách chủ đề từ file JSON
  Future<void> loadTopics() async {
    isLoading = true;
    notifyListeners();

    final jsonString = await rootBundle.loadString('lib/data/topics.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    topics = jsonList.map((json) => TopicModel.fromJson(json)).toList();

    isLoading = false;
    notifyListeners();
  }
}
