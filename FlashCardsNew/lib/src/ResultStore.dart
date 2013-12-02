part of flashcards_core;


class ResultStore {
  static CardScore getCardScoreFromStore(Card card) {
    var inStoreJson = window.localStorage[card.en];    
    if (inStoreJson == null) {
      return null;
    }
    return new CardScore.fromJsonString(inStoreJson);    
  }
  
  static void storeResult(Card card, CardScore score) {            
    var resultString = score.toJSON();
    window.localStorage[card.en] = resultString;
  }
  
  static void clearScores(List<Card> deck) {
    for (Card card in deck) {
      window.localStorage.remove(card.en);
    }
  }
}
