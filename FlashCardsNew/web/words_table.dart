import 'package:polymer/polymer.dart';


import 'package:observe/observe.dart';
import 'package:FlashCardsNew/flashcards_core.dart';
import 'package:FlashCardsNew/date_utils.dart';
import 'package:FlashCardsNew/locale_utils.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('words-table')
class WordsTable extends PolymerElement {
  
  @observable List<WordTableRow> wordRows = toObservable([]);
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @published String primaryLang;
  
  @published String secondaryLang;
  
  @published String thirdLang;
  
  WordsTable.created() : super.created() {
    new PathObserver(this, 'cards')
    ..changes.listen((_) {
      wordRows = mapToRowData(cards);
    });    
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
      WordTableRow r = new WordTableRow(card, cssClass, dueIn);
      ret.add(r);    
    }
    return ret;
    
  }
  

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
      return "danger";
    } else {
      //to pacify static analysis
      return "";
    }
  }
  
  String getLangName(String lang) => LangUtils.getLangName(lang);
      
  String getValueForLang(Card c, String lang) => c.getValueForLang(lang);
          
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

