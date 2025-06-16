class TopicModel {
  String id;
  String name;
  String description;
  String? imageUrl;
  List<UserWordModel>? listWord;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.listWord,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['imageUrl'] ?? json['image'],
    listWord:
        json['listWord'] != null
            ? List<UserWordModel>.from(
              json['listWord'].map((x) => UserWordModel.fromJson(x)),
            )
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'listWord': listWord?.map((x) => x.toJson()).toList(),
  };
}

class UserWordModel {
  int id;
  String word;
  String pronunciation;
  String meaning;
  String? image;

  UserWordModel({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    this.image,
  });

  factory UserWordModel.fromJson(Map<String, dynamic> json) => UserWordModel(
    id: json["id"],
    word: json["word"],
    pronunciation: json["pronunciation"],
    meaning: json["meaning"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "word": word,
    "pronunciation": pronunciation,
    "meaning": meaning,
    "image": image,
  };
}
