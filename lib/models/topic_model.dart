class TopicModel {
  String id;
  String name;
  String description;
  String? imageUrl;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'],
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
