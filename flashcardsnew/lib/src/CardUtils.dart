part of flashcards_core;


class CardUtils {
  
  static RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  static RegExp IN_BRACKETS = new RegExp("\\[.+?\\]");

  static String sanitizeWordEntry(String lang, String word) {
    if (word == null) {
      return null;
    }
    word = _removeCommentsInParentheses(word);
    if (word.contains(',')) {
      word = word.split(',')[0];
    } else if (word.contains(';')) {
      word = word.split(';')[0];
    }
    return _sanitizeSingleWord(lang, word);
  }

  static List<String> getAllSanitizedWords(String lang, String word) {
    if (word == null) {
      return null;
    }
    word = _removeCommentsInParentheses(word);
    List<String> words;
    if (word.contains(',')) {
      words = word.split(',');
    } else if (word.contains(';')) {
      words = word.split(';');
    } else {
      words = [word];
    }
    List<String> sanitizedWords = words.map((word) => _sanitizeSingleWord(lang, word)).toList();
    return sanitizedWords;
  }

  static String _removeCommentsInParentheses(String word) {
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    if (word.contains(IN_BRACKETS)) {
      word = word.replaceAll(IN_BRACKETS, "");
    }
    return word;
  }

  static String _sanitizeSingleWord(String lang, String word) {
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