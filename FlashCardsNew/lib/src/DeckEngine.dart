part of flashcards_core;

abstract class DeckState {
  int get deckSize;
  Card get currentCard;
}

class DeckEngine implements DeckState {
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  int _currentWord = 0;  
  Card _currentCard;
  CardScore _currentScore;
  
  List<Card> allCardsInDeck;  
  List<Card> learningList;
  
  DeckEngine(this.allCardsInDeck) {
    initLearningList();    
  }
  
  void initLearningList() {
    learningList = buildLearningList(allCardsInDeck);
    if (!learningList.isEmpty) {
      _currentWord = 0;
      _currentCard = learningList[_currentWord];
      _currentScore = ResultStore.getCardScoreFromStore(_currentCard);      
    }
  }
    
  List<Card> buildLearningList(List<Card> allElements) {
    return allElements.where(isCardInLearningList).toList();
  }
  
  static bool isCardInLearningList(Card card) {
    CardScore lastCardScore = ResultStore.getCardScoreFromStore(card);
    return isInLearningList(lastCardScore);
  }
  
  static bool isInLearningList(CardScore lastCardScore) {
    if (lastCardScore == null) {
      return true;
    }
    var currentDate = new DateTime.now();
    var scheduledDate = lastCardScore.getNextScheduledTime();
    return currentDate.isAfter(scheduledDate);    
  }
  
  
  Card get currentCard {    
    return _currentCard;   
  }
  
  bool hasNextCard() {
    if (_currentWord < learningList.length-1) {
      return true;
    } else {
      return false;
    }
  }
  
  void nextCard() {
    if (_currentWord < learningList.length-1) {
      _currentWord++;
    }
    /*else {
      _currentWord = 0;
    }*/
    _currentCard = learningList[_currentWord];
    _currentScore = ResultStore.getCardScoreFromStore(_currentCard);
    
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
    var time = new DateTime.now().millisecondsSinceEpoch; 
    int previousGoodInARow = 0;
    
    if (_currentScore != null) {
     // previousGoodInARow = _currentScore.goodInARow;
      previousGoodInARow = _currentScore.goodInARow;
    }
    int goodInARow = 0;
    if (answerResult == CardScore.GOOD_ANSWER) {
      goodInARow = previousGoodInARow + 1;
    }
    CardScore newScore = new CardScore(answerResult, goodInARow, time);
    ResultStore.storeResult(currentCard, newScore);
  }
      
  void clearDeckResults() {
    ResultStore.clearScores(allCardsInDeck);    
    initLearningList();
  }
  
  static bool isCardCompleted(Card card) {
    CardScore inStore = ResultStore.getCardScoreFromStore(card); 
    if (inStore == null) {
      return false;
    }
    return (inStore.lastResult == GOOD_ANSWER);
  }
  
  int get deckSize => allCardsInDeck.length;
  int get completedSize => allCardsInDeck.where(isCardCompleted).length;
  int get dueSize => allCardsInDeck.where(isCardInLearningList).length;
 
}
 