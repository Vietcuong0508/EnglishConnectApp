import 'package:english_connect/core/constants/colors.dart';
import 'package:english_connect/models/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.primaryColor,
            title: Text('Topics'),
          ),
          body: ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return Card(
                color: AppColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                shadowColor: AppColors.shadowColor,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    // Xử lý chọn chủ đề
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder,
                          color: AppColors.primaryColor,
                          size: 30,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topics[index].name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topics[index].description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
