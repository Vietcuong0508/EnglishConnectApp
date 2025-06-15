class WordModel {
  int id;
  String word;
  String pronunciation;
  String meaning;
  String? image;

  WordModel({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    this.image,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
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
