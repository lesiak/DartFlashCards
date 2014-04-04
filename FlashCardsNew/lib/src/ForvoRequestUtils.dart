part of forvo_api;


class ForvoRequestUtils {
  
  static RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  static String sanitizeWord(String lang, String word) {
    if (word == null) {
      return null;
    }
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    if (word.contains(',')) {
      word = word.split(',')[0];
    }
    if (lang == "en") {
      if (word.startsWith("to ")) {
        word = word.substring(3);
      }
      else if (word.startsWith("a ")) {
        word = word.substring(2);
      }
    }
    return word.trim();
  }
}