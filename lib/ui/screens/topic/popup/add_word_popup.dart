import 'dart:async';
// Đã xóa import http và dart:convert

import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddWordPopup extends StatefulWidget {
  final TopicModel topic;

  const AddWordPopup({super.key, required this.topic});

  @override
  State<AddWordPopup> createState() => _AddWordPopupState();
}

class _AddWordPopupState extends State<AddWordPopup> {
  final wordController = TextEditingController();
  final pronunciationController = TextEditingController();
  final meaningController = TextEditingController();

  // Cờ kiểm soát để không tự động ghi đè nếu user đã sửa
  bool _userEditedMeaning = false;
  bool _userEditedPronunciation = false;

  // Cờ để biết code đang tự điền, tránh trigger listener
  bool _isAutoFillingMeaning = false;
  bool _isAutoFillingPronunciation = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Lắng nghe khi người dùng gõ từ vựng
    wordController.addListener(() {
      _onWordChangedDebounced(wordController.text);
    });

    // Lắng nghe khi người dùng sửa tay phần Nghĩa
    meaningController.addListener(() {
      if (!_isAutoFillingMeaning) {
        _userEditedMeaning = true;
      }
    });

    // Lắng nghe khi người dùng sửa tay phần Phiên âm
    pronunciationController.addListener(() {
      if (!_isAutoFillingPronunciation) {
        _userEditedPronunciation = true;
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    wordController.dispose();
    pronunciationController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  void _onWordChangedDebounced(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      final text = value.trim();
      if (text.isEmpty) return;

      // Gọi song song cả 2 logic nếu chưa bị sửa tay
      if (!_userEditedMeaning) _fillShortMeaning(text);
      if (!_userEditedPronunciation) _fillPronunciation(text);
    });
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- GỌI LOGIC TỪ VIEWMODEL ---

  Future<void> _fillShortMeaning(String word) async {
    if (!mounted) return;
    // Gọi hàm từ ViewModel bằng context.read
    final vn = await context.read<TopicViewModel>().fetchTranslation(word);

    if (!mounted) return;

    if (vn != null && vn.isNotEmpty) {
      if (!_userEditedMeaning) {
        _isAutoFillingMeaning = true;
        meaningController.text = vn;
        _isAutoFillingMeaning = false;
      }
    } else {
      _showMsg("Không tìm thấy bản dịch cho '$word'");
    }
  }

  Future<void> _fillPronunciation(String word) async {
    if (!mounted) return;
    // Gọi hàm từ ViewModel bằng context.read
    final p = await context.read<TopicViewModel>().fetchPronunciation(word);

    if (!mounted) return;

    if (p != null && p.isNotEmpty) {
      if (!_userEditedPronunciation) {
        _isAutoFillingPronunciation = true;
        pronunciationController.text = p;
        _isAutoFillingPronunciation = false;
      }
    } else {
      _showMsg("Không tìm thấy phiên âm cho '$word'");
    }
  }

  Future<void> _onSelectedSuggestion(String selected) async {
    wordController.text = selected;
    wordController.selection = TextSelection.fromPosition(
      TextPosition(offset: selected.length),
    );

    _userEditedMeaning = false;
    _userEditedPronunciation = false;

    await _fillShortMeaning(selected);
    await _fillPronunciation(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return BaseView<TopicViewModel>(
      // ViewModel đã được init ở màn hình cha hoặc load ở đây
      onViewModelReady: (vm) => vm.loadTopics(),
      builder: (context, viewModel, _) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: theme.cardColor,
          title: Text(Strings.addVocabulary),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ô nhập từ vựng
                WordSuggestField(
                  controller: wordController,
                  hintText: Strings.vocabulary,
                  onSelected: (s) => _onSelectedSuggestion(s),
                ),

                const SizedBox(height: 12),

                // Ô nhập phiên âm
                TextField(
                  controller: pronunciationController,
                  decoration: InputDecoration(labelText: Strings.pronunciation),
                  onChanged: (_) => _userEditedPronunciation = true,
                ),

                const SizedBox(height: 12),

                // Ô nhập nghĩa
                TextField(
                  controller: meaningController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: Strings.meaning),
                  onChanged: (_) => _userEditedMeaning = true,
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(Strings.done),
            ),
            ElevatedButton(
              onPressed: () async {
                final word = wordController.text.trim();
                final pronunciation = pronunciationController.text.trim();
                final meaning = meaningController.text.trim();

                if (word.isEmpty || meaning.isEmpty) {
                  _showMsg(Strings.pleaseEnterFullInformation);
                  return;
                }

                // Gọi hàm thêm từ (viewModel lấy từ BaseView builder)
                await viewModel.addWordToTopic(
                  topicId: widget.topic.id,
                  word: word,
                  pronunciation: pronunciation,
                  meaning: meaning,
                );

                wordController.clear();
                pronunciationController.clear();
                meaningController.clear();

                _userEditedMeaning = false;
                _userEditedPronunciation = false;

                if (context.mounted) {
                  _showMsg(Strings.addVocabularySuccess);
                }
              },
              child: Text(
                Strings.add,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
