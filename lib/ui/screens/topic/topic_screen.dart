import 'package:english_connect/core/core.dart';
import 'package:english_connect/models/model.dart';
import 'package:english_connect/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopicScreen extends StatelessWidget {
  TopicScreen({super.key});

  final List<TopicModel> topics = [
    TopicModel(
      id: 1,
      name: 'Animal',
      description: 'Learn about animals',
      imageUrl: 'https://example.com/animal.jpg',
    ),
    TopicModel(
      id: 2,
      name: 'Fruit',
      description: 'Learn about fruits',
      imageUrl: 'https://example.com/fruit.jpg',
    ),
    TopicModel(
      id: 3,
      name: 'Vegetable',
      description: 'Learn about vegetables',
      imageUrl: 'https://example.com/vegetable.jpg',
    ),
    TopicModel(
      id: 4,
      name: 'Color',
      description: 'Learn about colors',
      imageUrl: 'https://example.com/color.jpg',
    ),
    TopicModel(
      id: 5,
      name: 'Number',
      description: 'Learn about numbers',
      imageUrl: 'https://example.com/number.jpg',
    ),
    TopicModel(
      id: 6,
      name: 'Weather',
      description: 'Learn about weather',
      imageUrl: 'https://example.com/weather.jpg',
    ),
    TopicModel(
      id: 7,
      name: 'Food',
      description: 'Learn about food',
      imageUrl: 'https://example.com/food.jpg',
    ),
    TopicModel(
      id: 8,
      name: 'Transportation',
      description: 'Learn about transportation',
      imageUrl: 'https://example.com/transportation.jpg',
    ),
    TopicModel(
      id: 9,
      name: 'Clothing',
      description: 'Learn about clothing',
      imageUrl: 'https://example.com/clothing.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

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
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return CustomButton(
                icon: Icons.topic,
                title: topics[index].name,
                description: topics[index].description,
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/topicDetail',
                    arguments: topics[index],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
