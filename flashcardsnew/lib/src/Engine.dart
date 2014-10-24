part of flashcards_core;

class Engine {
    
  List<Card> allCardsInDeck = [];
    
  Engine() {}  
  
  Future<List<Card>> loadData(String wordfilePath) {    
    return DeckLoader.loadDeckFile(wordfilePath).then((allCards) => this.allCardsInDeck = allCards);     
  }   
           
  void clearDeckResults(String lang) {    
    ResultStore.clearScores(allCardsInDeck, lang);    
  }    
  
}




