class WordModel {
  final String word;
  final String pronunciation;
  final String meaning;
  final String? imageUrl;

  WordModel({
    required this.word,
    required this.pronunciation,
    required this.meaning,
    this.imageUrl,
  });
}
