part of flashcards_core;

typedef void DataLoadedCallback();


class Engine {
    
  List<Card> allCardsInDeck;
    
  Engine() {}  
  
  void loadData(String wordfilePath, DataLoadedCallback onDataReady) {    
    DeckLoader.loadDeckFile(wordfilePath).then(
        (allCards) {
          this.allCardsInDeck = allCards;
          onDataReady();
        });
  }   
           
  void clearDeckResults(String lang) {
    ResultStore.clearScores(allCardsInDeck, lang);    
  }    
  
}




