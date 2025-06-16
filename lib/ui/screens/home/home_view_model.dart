import 'dart:async';
import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';

final class HomeViewModel extends BaseViewModel {
  final RandomWordService _wordService = RandomWordService();

  List<WordModel> selectedWords = [];
  bool isLoading = false;

  Future<void> loadRandomWords() async {
    isLoading = true;
    notifyListeners();

    selectedWords = await _wordService.getOneRandomWordFromEachFile();

    isLoading = false;
    notifyListeners();
  }
}
