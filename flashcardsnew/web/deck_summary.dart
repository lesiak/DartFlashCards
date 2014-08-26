import 'package:polymer/polymer.dart';

import 'package:flashcardsnew/flashcards_core.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('deck-summary')
class DeckSummary extends PolymerElement {
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @published String primaryLang; 
  
  @observable int completedSize;
  
  @observable int dueSize;
  
  @observable int progress;
    
   
  DeckSummary.created() : super.created() {
    print('created summary');
    
    new PathObserver(this, 'cards')
    ..open((record) {
      recomputeStats();       
    });
    new PathObserver(this, 'primaryLang')
    ..open((_) {
      recomputeStats();
    });    
  } 
  
  void recomputeStats() {
    completedSize = computeCompleted(cards);
    dueSize = computeDueSize(cards);
    progress = computeProgress(cards, dueSize);    
  }
      
  int computeCompleted(List<Card> cards) => cards.where((card) =>CardScoresEngine.isCardCompleted(card, primaryLang)).length;
 
  int computeDueSize(List<Card> cards) => cards.where((card) => CardScoresEngine.isCardInLearningList(card, primaryLang)).length;
  
  int computeProgress(List<Card> cards, int dueSize) {    
    if (cards.length > 0) {
      var answeredAndNotDueSize = cards.length - dueSize; 
      return ((answeredAndNotDueSize/cards.length) * 100).toInt();
    } else {
      return 0;
    }
  }
    
}

