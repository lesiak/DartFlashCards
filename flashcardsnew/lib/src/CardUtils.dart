part of flashcards_core;


class CardUtils {
  
  static RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  static RegExp IN_BRACKETS = new RegExp("\\[.+?\\]");
  
  static String sanitizeWord(String lang, String word) {
    if (word == null) {
      return null;
    }
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    if (word.contains(IN_BRACKETS)) {
          word = word.replaceAll(IN_BRACKETS, "");
        }
    if (word.contains(',')) {
      word = word.split(',')[0];
    }
    if (word.contains(';')) {
          word = word.split(';')[0];
    }
    if (lang == "en") {
      if (word.startsWith("to ")) {
        word = word.substring(3);
      } else if (word.startsWith("a ")) {
        word = word.substring(2);
      } else if (word.startsWith("an ")) {
        word = word.substring(3);
      }
    }
    return word.trim();
  }
}