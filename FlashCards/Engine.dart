#library('flashcards_core');

#import('dart:html');
#import("dart:json");

#import('Card.dart');

typedef void DataLoadedCallback();

class Engine {
  int currentWord = 0;
  
  List<Card> allElements;
  List<Card> data;
  
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
    var inStore = window.localStorage[card.en];    
    return (inStore == null || inStore == 'Poor' || inStore == 'Bad');
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
    Card currentCard = currentCard();     
    window.localStorage[currentCard.en] = 'Good';
    
  }
  
  void poorAnswer() {
    Card currentCard = currentCard(); 
    window.localStorage[currentCard.en] = 'Poor';
  }
  
  void badAnswer() {
    Card currentCard = currentCard(); 
    window.localStorage[currentCard.en] = 'Bad';
  }
}
