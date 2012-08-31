#library('flashcards_core');

#import('dart:html');
#import("dart:json");

#import('Card.dart');
#import('CardScore.dart');

typedef void DataLoadedCallback();

class Engine {
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  int _currentWord = 0;
  
  Card _currentCard;
  CardScore _currentScore;
  
  List<Card> allCardsInDeck;
  List<Card> learningList;
   
  
  Engine() {}
  
  
  void loadData(String wordfilePath, DataLoadedCallback onDataReady) {
    var request = new XMLHttpRequest.get(wordfilePath, (req) {
      _initDeck(req.responseText);
      onDataReady();
    });
  }
  
  void _initDeck(String wordListJSON) {
    List rawData = JSON.parse(wordListJSON); // parse response text
    allCardsInDeck = rawData.map((entry) => new Card(entry["en"], entry["ko"], entry["fi"], entry["fr"]));
    _initLearningList();
  }
  
  void _initLearningList() {
    learningList = buildLearningList(allCardsInDeck);
    if (!learningList.isEmpty()) {
      _currentCard = learningList[_currentWord];
      _currentScore = getCardScoreFromStore(_currentCard);
    }
  }
  
  
  List<Card> buildLearningList(List<Card> allElements) {
    return allElements.filter(isInLearningList);
  }
  
  bool isInLearningList(Card card) {    
    CardScore inStore = getCardScoreFromStore(card);
    if (inStore == null) {
      return true;
    }
    return (inStore.lastResult == POOR_ANSWER || inStore.lastResult == BAD_ANSWER);
  }
  
  Card currentCard() {    
    return _currentCard;   
  }
  
  void nextCard() {
    if (_currentWord < learningList.length-1) {
      _currentWord++;
    }
    _currentCard = learningList[_currentWord];
    _currentScore = getCardScoreFromStore(_currentCard);
    
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
    Map resultMap = {"lastResult" : answerResult, "time" : time};
    return JSON.stringify(resultMap);
  }
  
  CardScore getCardScoreFromStore(Card card) {
    var inStoreJson = window.localStorage[card.en];    
    if (inStoreJson == null) {
      return null;
    }
    return new CardScore.fromJsonString(inStoreJson);    
  }
  
  void clearDeckResults() {
    for (Card card in allCardsInDeck) {
      window.localStorage.remove(card.en);
    }
    _initLearningList();
  } 
  
}




