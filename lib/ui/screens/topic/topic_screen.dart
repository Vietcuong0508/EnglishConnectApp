import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/screens/topic/popup/topic_popup.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return BaseView<TopicViewModel>(
      onViewModelReady: (viewModel) async {
        await viewModel.loadTopics();
      },
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: theme.backgroundGradient),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: Text(Strings.topic),
              ),
              body: ListView.builder(
                itemCount: viewModel.topics.length + 1,
                itemBuilder: (context, index) {
                  if (index < viewModel.topics.length) {
                    final topic = viewModel.topics[index];
                    final isLocal = viewModel.localTopics.any(
                      (t) => t.id == topic.id,
                    );

                    return isLocal
                        ? Dismissible(
                          key: Key(topic.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text('Xác nhận xoá'),
                                  content: Text(
                                    'Bạn có chắc muốn xoá chủ đề "${topic.name}" không?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Huỷ'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Xoá',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                            return confirm == true;
                          },
                          onDismissed: (_) {
                            viewModel.deleteTopic(topic.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã xoá chủ đề: ${topic.name}'),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              // --- SỬA LỖI 1: Truyền ViewModel vào Dialog ---
                              showDialog(
                                context: context,
                                builder:
                                    (_) => ChangeNotifierProvider.value(
                                      value:
                                          viewModel, // <--- Truyền instance hiện tại vào đây
                                      child: AddWordPopup(topic: topic),
                                    ),
                              );
                            },
                            child: CustomButton(
                              icon: Icons.topic,
                              title: topic.name,
                              description: topic.description,
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/game',
                                  arguments: {"topicName": topic.name},
                                );
                              },
                            ),
                          ),
                        )
                        : CustomButton(
                          icon: Icons.topic,
                          title: topic.name,
                          description: topic.description,
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/game',
                              arguments: {"topicName": topic.name},
                            );
                          },
                        );
                  } else {
                    // Nút thêm chủ đề
                    return CustomButton(
                      icon: Icons.add,
                      title: Strings.addTopic,
                      onPressed: () async {
                        // Mở popup thêm Topic
                        final result = await showDialog<bool>(
                          context: context,
                          // Lưu ý: AddTopicPopup cũng cần Provider nếu nó gọi logic addTopic
                          // Ở đây tôi cũng bọc luôn cho chắc chắn
                          builder:
                              (_) => ChangeNotifierProvider.value(
                                value: viewModel,
                                child: AddTopicPopup(
                                  onTopicAdded: (newTopic) {
                                    // Khi topic được thêm xong, mở popup AddWord
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        // --- SỬA LỖI 2: Truyền ViewModel vào Dialog ---
                                        return ChangeNotifierProvider.value(
                                          value:
                                              viewModel, // <--- Truyền instance hiện tại vào đây
                                          child: AddWordPopup(topic: newTopic),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                        );

                        if (result == true) {
                          await viewModel.loadTopics();
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
