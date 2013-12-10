part of flashcards_core;


class ResultStore {
  static CardScore getCardScoreFromStore(Card card, String lang) {
    var inStoreJson = window.localStorage[makeKey(card, lang)];    
    if (inStoreJson == null) {
      return null;
    }
    return new CardScore.fromJsonString(inStoreJson);    
  }
  
  static void storeResult(Card card, String lang, CardScore score) {            
    var resultString = score.toJSON();
    window.localStorage[makeKey(card, lang)] = resultString;
  }
  
  static void clearScores(List<Card> deck, String lang) {
    for (Card card in deck) {
      window.localStorage.remove(makeKey(card, lang));
    }
  }
  
  static String makeKey(Card card, String lang) {
    return card.en + "-" + lang;
  }
}
