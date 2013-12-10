import 'package:polymer/polymer.dart';


import 'package:observe/observe.dart';
import 'package:FlashCardsNew/flashcards_core.dart';
import 'package:FlashCardsNew/date_utils.dart';


/**
 * A Polymer click counter element.
 */
@CustomTag('words-table')
class WordsTable extends PolymerElement {
  
  @observable List<WordTableRow> wordRows = toObservable([]);
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @published String primaryLang; 
  
  WordsTable.created() : super.created() {
    new PathObserver(this, 'cards')
    ..changes.listen((_) {
      wordRows = mapToRowData(cards);
    });
    new PathObserver(this, 'primaryLang')
    ..changes.listen((_) {
      wordRows = mapToRowData(cards);
    });  
  }
  
 
  
  
 /* String getCssClass(Card card) {
    CardScore score = ResultStore.getCardScoreFromStore(card);
    String cssClass = getCssClassFromScore(score); 
    //return cssClass;
    return "succ";
  }*/
  /*
  String getDueIn(Card card) {
    CardScore score = ResultStore.getCardScoreFromStore(card);
    
    String dueIn = "";          
    if (score != null) {
      var currentDate = new DateTime.now();
      dueIn = formatDuration(score.getDueInDuration(currentDate));
    }
    return dueIn;
  }*/

  String getCssClassFromScore(CardScore score) {   
    if (score == null) {
      return "notTested";
    }
    if (score.isGoodAnswer() && !Engine.isInLearningList(score)) {
      return "succ";
    }
    else if (score.isGoodAnswer() && Engine.isInLearningList(score)) {
      return "succInList";
    }
    else if (score.isPoorAnswer()) {
      return "almost";
    }
    else if (score.isBadAnswer()) {
      return "error";
    }
  }
  
  List<WordTableRow> mapToRowData(List<Card> allCardsInDeck) {
    List<WordTableRow> ret = [];
    var currentDate = new DateTime.now();
    for (Card card in allCardsInDeck) {
      CardScore score = ResultStore.getCardScoreFromStore(card, primaryLang);
        
      String dueIn = "";
      String cssClass = getCssClassFromScore(score);      
     
      if (score != null) {     
          dueIn = formatDuration(score.getDueInDuration(currentDate));          
      }
      ret.add(new WordTableRow(card, cssClass, dueIn));    
    }
    return ret;
    
  }
  
  // This lets the Bootstrap CSS "bleed through" into the Shadow DOM
  // of this element.
  bool get applyAuthorStyles => true;
}


class WordTableRow extends Object with Observable {
  @observable Card card;
  @observable String cssClass;
  @observable String dueIn;
  
  WordTableRow(this.card, this.cssClass, this.dueIn);
  
}

