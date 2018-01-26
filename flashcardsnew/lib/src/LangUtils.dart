part of locale_utils;

class LangUtils {
  
  static String getLangName(String lang) {
    if (lang == "ko") {
      return "Korean";
    } else if (lang == "fi") {
      return "Finnish";      
    } else if (lang == "fr") {
      return "French";      
    } else if (lang == "hu") {
      return "Hungarian";      
    } else if (lang == "es") {
      return "Spanish";
    } else if (lang == "it") {
      return "Italian";
    } else if (lang == "cs") {
      return "Czech";              
    } else if (lang == "de") {
      return "German";
    } else if (lang == "dk") {
      return "Danish";
    } else if (lang == "ru") {
      return "Russian";
    }

    else if (lang==null) {
      return "null";
    }
    return "unknown";
  }
}