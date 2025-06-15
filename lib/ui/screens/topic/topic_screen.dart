import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
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
                itemCount: viewModel.topics.length,
                itemBuilder: (context, index) {
                  return CustomButton(
                    icon: Icons.topic,
                    title: viewModel.topics[index].name,
                    description: viewModel.topics[index].description,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {"topicName": viewModel.topics[index].name},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
