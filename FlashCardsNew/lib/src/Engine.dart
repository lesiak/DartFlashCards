part of flashcards_core;

typedef void DataLoadedCallback();


class Engine {
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
   
  List<Card> allCardsInDeck;
    
  Engine() {}  
  
  void loadData(String wordfilePath, DataLoadedCallback onDataReady) {    
    DeckLoader.loadDeckFile(wordfilePath).then(
        (allCards) {
          this.allCardsInDeck = allCards;
          onDataReady();
        });
  }
    
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
           
  void clearDeckResults(String lang) {
    ResultStore.clearScores(allCardsInDeck, lang);    
  }
  
  static bool isCardCompleted(Card card, String lang) {
    CardScore inStore = ResultStore.getCardScoreFromStore(card, lang); 
    if (inStore == null) {
      return false;
    }
    return (inStore.lastResult == GOOD_ANSWER);
  }
  
}




