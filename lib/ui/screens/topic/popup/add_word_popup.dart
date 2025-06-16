import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    wordController.dispose();
    pronunciationController.dispose();
    meaningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<TopicViewModel>(
      onViewModelReady: (viewModel) {
        viewModel.loadTopics();
      },
      builder: (context, viewModel, _) {
        return AlertDialog(
          title: const Text('Thêm từ vựng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(labelText: 'Từ vựng'),
                ),
                TextField(
                  controller: pronunciationController,
                  decoration: const InputDecoration(labelText: 'Phát âm'),
                ),
                TextField(
                  controller: meaningController,
                  decoration: const InputDecoration(labelText: 'Nghĩa'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                final word = wordController.text.trim();
                final pronunciation = pronunciationController.text.trim();
                final meaning = meaningController.text.trim();

                if (word.isEmpty || pronunciation.isEmpty || meaning.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập đầy đủ thông tin.'),
                    ),
                  );
                  return;
                }
                debugPrint('📝 Adding word to topic ID: ${widget.topic.id}');
                await viewModel.addWordToTopic(
                  topicId: widget.topic.id,
                  word: word,
                  pronunciation: pronunciation,
                  meaning: meaning,
                );

                wordController.clear();
                pronunciationController.clear();
                meaningController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm từ thành công.')),
                );
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
}
