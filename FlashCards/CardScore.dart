#library('flashcards_core');

#import("dart:json");

class CardScore {
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  String lastResult;
  int time;
  
  CardScore(this.lastResult, this.time);
  
  factory CardScore.fromJsonString(String jsonString) {   
    Map map =  JSON.parse(jsonString);
    return new CardScore.fromMap(map);     
  }
  
  factory CardScore.fromMap(Map jsonMap) {
    return new CardScore(jsonMap["lastResult"], jsonMap["time"]);
  }
  
  bool isGoodAnswer() {
    return lastResult == GOOD_ANSWER;
  }
  
  bool isPoorAnswer() {
    return lastResult == POOR_ANSWER;
  }
  
  bool isBadAnswer() {
    return lastResult == BAD_ANSWER;
  }
  
}
