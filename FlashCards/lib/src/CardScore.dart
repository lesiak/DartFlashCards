part of flashcards_core;

class CardScore {
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  String lastResult;
  int lastAnswerTime;
  
  CardScore(this.lastResult, this.lastAnswerTime);
  
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
  
  Duration getDateDifference(Date currentDate) {
    var lastAnswerDate = new Date.fromMillisecondsSinceEpoch(lastAnswerTime);
    var dateDifference = currentDate.difference(lastAnswerDate);
    return dateDifference;
  }
  
  String toJSON() {
    Map resultMap = {"lastResult" : lastResult, "time" : lastAnswerTime};
    return JSON.stringify(resultMap);
  }
  
  
}
