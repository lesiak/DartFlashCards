import 'package:polymer/polymer.dart';

import 'package:FlashCardsNew/flashcards_core.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('deck-summary')
class DeckSummary extends PolymerElement {
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @observable int completedSize;
  
  @observable int dueSize;
  
  @observable int progress;
   
  DeckSummary.created() : super.created() {
    print('created summary');
    
    new PathObserver(this, 'cards')
    ..changes.listen((record) {
      //print('lala' + record.toString());
      completedSize = _completed;
      dueSize = _dueSize;
      if (cards.length > 0) {
        progress = ((completedSize/cards.length) * 100).toInt();
      } else {
        progress = 0;
      }
      
    });   
  }  
  
  int get _completed => cards.where((card) =>Engine.isCardCompleted(card, "ko")).length;
 
  int get _dueSize => cards.where((card) => Engine.isCardInLearningList(card, "ko")).length; 
  
  bool get applyAuthorStyles => true;
}

