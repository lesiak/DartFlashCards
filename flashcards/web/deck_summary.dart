import 'package:polymer/polymer.dart';

import 'package:flashcardsnew/flashcards_core.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('deck-summary')
class DeckSummary extends PolymerElement {
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @observable int completedSize;
  
  @observable int dueSize;
  
  @observable int progress;
  
  @published String primaryLang; 
   
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
    completedSize = _completed;
    dueSize = _dueSize;
    if (cards.length > 0) {
      var answeredAndNotDueSize = cards.length - dueSize; 
      progress = ((answeredAndNotDueSize/cards.length) * 100).toInt();
    } else {
      progress = 0;
    }
  }
  
  
  
  int get _completed => cards.where((card) =>CardScoresEngine.isCardCompleted(card, primaryLang)).length;
 
  int get _dueSize => cards.where((card) => CardScoresEngine.isCardInLearningList(card, primaryLang)).length; 
    
}

