class TopicModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
