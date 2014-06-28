part of flashcards_core;


class CardScoresEngine {
  
  static final String GOOD_ANSWER = 'GOOD';
  static final String POOR_ANSWER = 'POOR';
  static final String BAD_ANSWER = 'BAD';
         
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
               
  static bool isCardCompleted(Card card, String lang) {
    CardScore inStore = ResultStore.getCardScoreFromStore(card, lang); 
    if (inStore == null) {
      return false;
    }
    return (inStore.lastResult == GOOD_ANSWER);
  }
  
}




