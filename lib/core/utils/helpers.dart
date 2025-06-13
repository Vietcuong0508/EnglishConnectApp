String capitalize(String word) {
  return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
}