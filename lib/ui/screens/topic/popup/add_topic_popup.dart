import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTopicPopup extends StatefulWidget {
  const AddTopicPopup({super.key, required this.onTopicAdded});
  final void Function(TopicModel newTopic) onTopicAdded;

  @override
  State<AddTopicPopup> createState() => _AddTopicPopupState();
}

class _AddTopicPopupState extends State<AddTopicPopup> {
  late TextEditingController nameController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller để quản lý text
    nameController = TextEditingController();
    descController = TextEditingController();

    // Reset dữ liệu cũ trong ViewModel (nếu có) khi mở popup
    // Dùng addPostFrameCallback để gọi sau khi widget build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TopicViewModel>();
      vm.setTopicName("");
      vm.setDescription("");
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    // ✅ SỬA LỖI: Thay BaseView bằng Consumer
    // Vì ViewModel đã được truyền từ TopicScreen vào rồi
    return Consumer<TopicViewModel>(
      builder: (context, viewModel, _) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: theme.cardColor,
          title: Text(Strings.addNewTopic),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: Strings.topicName),
                // Vẫn gọi hàm này để ViewModel cập nhật biến isValid()
                onChanged: viewModel.setTopicName,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: Strings.topicDescription,
                ),
                onChanged: viewModel.setDescription,
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.buttonColor,
                side: BorderSide(color: theme.buttonColor, width: 1.5),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(Strings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.buttonColor,
                foregroundColor: Colors.white,
              ),
              // Nút Add sẽ enable/disable dựa trên isValid() của ViewModel
              onPressed:
                  viewModel.isValid()
                      ? () async {
                        // Lấy giá trị trực tiếp từ controller cho chính xác
                        final name = nameController.text.trim();
                        final desc = descController.text.trim();

                        final newTopic = await viewModel.addTopic(name, desc);

                        if (context.mounted) {
                          Navigator.pop(context, true); // Đóng popup Add Topic
                          // Gọi callback để mở tiếp popup Add Word
                          widget.onTopicAdded(newTopic);
                        }
                      }
                      : null,
              child: Text(Strings.add),
            ),
          ],
        );
      },
    );
  }
}
