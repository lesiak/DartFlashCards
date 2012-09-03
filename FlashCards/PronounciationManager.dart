#library('forvo_api');
#import('dart:html');
#import('ForvoApi.dart');


typedef void ForvoResonseCallback(HttpRequest req);

class PronounciationManager {
  
  static final String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
  
  static void getPronunciations(String lang, String word, ForvoResonseCallback onSuccessfullyParsedResponse) {
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    
    // call the web server asynchronously
    var request = new HttpRequest.get(url, onSuccessfullyParsedResponse);
 
  }
  
  
  static ForvoItem getPreferredPronunciation(ForvoResponse r) {
    Set<String> favoriteUsers = new Set();
    favoriteUsers.addAll(['ssoonkimi', 'x_WoofyWoo_x', 'floridagirl']);
    for (ForvoItem item in r.items) {
      if (favoriteUsers.contains(item.username) ) {
        return item;
      }
    }
    return r.items[0];
  }
}
