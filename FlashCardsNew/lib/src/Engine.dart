part of flashcards_core;

typedef void DataLoadedCallback();


class Engine {
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
  
  
 /* int _currentWord = 0;  
  Card _currentCard;
  CardScore _currentScore;
  */
  List<Card> allCardsInDeck;
  //List<Card> learningList;
     
  Engine() {}  
  
  void loadData(String wordfilePath, DataLoadedCallback onDataReady) {
    HttpRequest.getString(wordfilePath).then((responseText) {
      _initDeck(responseText);
      onDataReady();
    });
  }
  
  Future<List<Card>> loadDeckFile(String wordfilePath) {
    Future<List<Card>> allCardsFut = HttpRequest.getString(wordfilePath).then(_buildDeckFromJson);
    return allCardsFut;
  }
  
  void _initDeck(String wordListJSON) {
    List rawData = JSON.parse(wordListJSON); // parse response text
    allCardsInDeck = rawData.map((entry) => new Card(entry["en"], entry["ko"], entry["fi"], entry["fr"])).toList();
    //initLearningList();    
  }
  
  List<Card> _buildDeckFromJson(String wordListJSON) {
    List rawData = JSON.parse(wordListJSON); // parse response text
    List<Card> allCards = rawData.map((entry) => new Card(entry["en"], entry["ko"], entry["fi"], entry["fr"])).toList();
    return allCards;    
  }
  
  /*void initLearningList() {
    learningList = buildLearningList(allCardsInDeck);
    if (!learningList.isEmpty) {
      _currentWord = 0;
      _currentCard = learningList[_currentWord];
      _currentScore = ResultStore.getCardScoreFromStore(_currentCard);      
    }
  }*/
    
  /*List<Card> buildLearningList(List<Card> allElements) {
    return allElements.where(isCardInLearningList).toList();
  }*/
  
  static bool isCardInLearningList(Card card, String lang) {    
    CardScore lastCardScore = ResultStore.getCardScoreFromStore(card, lang);
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
  
  
  /*-Card get currentCard {    
    return _currentCard;   
  }
  */
    
      
  void clearDeckResults(String lang) {
    ResultStore.clearScores(allCardsInDeck, lang);    
    //initLearningList();
  }
  
  static bool isCardCompleted(Card card, String lang) {
    CardScore inStore = ResultStore.getCardScoreFromStore(card, lang); 
    if (inStore == null) {
      return false;
    }
    return (inStore.lastResult == GOOD_ANSWER);
  }
  
}




