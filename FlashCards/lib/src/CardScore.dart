part of flashcards_core;

class CardScore {
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  String lastResult;
  int goodInARow;
  int lastAnswerTime;
  
  CardScore(this.lastResult, this.goodInARow, this.lastAnswerTime);
  
  factory CardScore.fromJsonString(String jsonString) {   
    Map map =  JSON.parse(jsonString);
    return new CardScore.fromMap(map);     
  }
  
  factory CardScore.fromMap(Map jsonMap) {
    return new CardScore(jsonMap["lastResult"], jsonMap["goodInARow"], jsonMap["time"]);
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
  
  Duration getDateDifferenceSinceLast(DateTime currentDate) {
    var lastAnswerDate = new DateTime.fromMillisecondsSinceEpoch(lastAnswerTime);
    var dateDifference = currentDate.difference(lastAnswerDate);
    return dateDifference;
  }
  
  Duration getDueInDuration(DateTime currentDate) {
    var scheduledDate = getNextScheduledTime();
    var dateDifference = scheduledDate.difference(currentDate);
    return dateDifference;
    
  }
  
  DateTime getNextScheduledTime() {
    var lastAnswerDate = new DateTime.fromMillisecondsSinceEpoch(lastAnswerTime);
    if (lastResult == BAD_ANSWER) {
      return lastAnswerDate;
    } 
    else if (lastResult == POOR_ANSWER) {      
      return lastAnswerDate.add(new Duration(hours: 1));     
    }
    else {
      print("goodInARow $goodInARow");
      return lastAnswerDate.add(new Duration(days: fib(goodInARow+1)));
    }
  }
  
  /**
   * 0 -> 1
   * 1 -> 1
   * 2 -> 2
   */
  int fib(int num) {
    var a = 0;
    var b = 1;
    var c = 1;
    for (int i = 0; i < num; ++i) {
      c = a+b;
      a = b; 
      b = c; 
    }
    print("fib $num: $c");
    return c;
  }
  
  String toJSON() {
    Map resultMap = {"lastResult" : lastResult,
                     "goodInARow" : goodInARow,
                     "time" : lastAnswerTime};
    return JSON.stringify(resultMap);
  }
  
  
}
