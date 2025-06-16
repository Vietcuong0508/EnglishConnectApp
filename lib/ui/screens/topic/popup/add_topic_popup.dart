import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';

class AddTopicPopup extends StatelessWidget {
  const AddTopicPopup({super.key, required this.onTopicAdded});
  final void Function(TopicModel newTopic) onTopicAdded;

  @override
  Widget build(BuildContext context) {
    return BaseView<TopicViewModel>(
      onViewModelReady: (viewModel) {},
      builder: (context, viewModel, _) {
        return AlertDialog(
          title: const Text('Thêm chủ đề mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Tên chủ đề'),
                onChanged: viewModel.setTopicName,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(labelText: 'Mô tả'),
                onChanged: viewModel.setDescription,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed:
                  viewModel.isValid()
                      ? () async {
                        final newTopic = await viewModel.addTopic(
                          viewModel.topicName,
                          viewModel.topicDescription,
                        );

                        Navigator.pop(context); // Đóng popup thêm chủ đề
                        onTopicAdded(newTopic); // Mở popup thêm từ
                      }
                      : null,
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }
}
