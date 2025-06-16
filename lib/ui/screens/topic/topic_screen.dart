import 'package:english_connect/core/core.dart';
import 'package:english_connect/ui/screens/topic/popup/topic_popup.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

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
                      title: "Add more topic",
                      onPressed:
                          () => showDialog(
                            context: context,
                            builder:
                                (_) => AddTopicPopup(
                                  onTopicAdded: (newTopic) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (_) => AddWordPopup(topic: newTopic),
                                    );
                                  },
                                ),
                          ),
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
