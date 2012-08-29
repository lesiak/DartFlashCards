#library('flashcards_core');

#import('dart:html');
#import("dart:json");

#import('Card.dart');

typedef void DataLoadedCallback();

class Engine {
  int currentWord = 0;
  
  List<Card> allElements;
  List<Card> data;
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  Engine() {
  //   new Dictionary().parse();
    
  }
  
  
  void loadData(String wordfilePath, DataLoadedCallback onDataReady) {
    var request = new XMLHttpRequest.get(wordfilePath, (req) {
      _initQuestions(req.responseText);
      onDataReady();
    });
  }
  
  void _initQuestions(String wordListJSON) {
    List rawData = JSON.parse(wordListJSON); // parse response text
    allElements = rawData.map((entry) => new Card(entry["en"], entry["ko"], entry["fi"], entry["fr"]));
    data = buildLearningList(allElements);
  }
  
  
  List<Card> buildLearningList(List<Card> allElements) {
    return allElements.filter(isInLearningList);
  }
  
  bool isInLearningList(Card card) {
    var inStoreJson = window.localStorage[card.en];    
    if (inStoreJson == null) {
      return true;
    }
    Map inStore = JSON.parse(inStoreJson);
    return (inStore["lastResult"] == POOR_ANSWER || inStore["lastResult"] == BAD_ANSWER);
  }
  
  Card currentCard() {
    Card card = data[currentWord];
    print("local storage ${card.en} : ${window.localStorage[card.en]}");
    return card;
   
  }
  
  void nextCard() {
    if (currentWord < data.length-1) {
      currentWord++;
    }
    
  }
  
  void goodAnswer() {    
    _processAnswer(GOOD_ANSWER);
  }
  
  void poorAnswer() {
    _processAnswer(POOR_ANSWER);    
  }
  
  void badAnswer() {
    _processAnswer(BAD_ANSWER);    
  }
  
  void _processAnswer(String answerResult) {
    Card currentCard = currentCard();
    
    var resultString = makeWordResultString(answerResult);
    window.localStorage[currentCard.en] = resultString;
  }
  
  String makeWordResultString(String answerResult) {
    var time = new Date.now().millisecondsSinceEpoch;    
    Map resultMap = {"time" : time, "lastResult" : answerResult};
    return JSON.stringify(resultMap);
  }
  
  
}


