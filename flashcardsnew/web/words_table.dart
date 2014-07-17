import 'package:polymer/polymer.dart';


import 'package:observe/observe.dart';
import 'package:flashcardsnew/flashcards_core.dart';
import 'package:flashcardsnew/date_utils.dart';
import 'package:flashcardsnew/locale_utils.dart';

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
    ..open((_) {
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
      int knowledgeLevel = 0;
      if (score != null) {     
          dueIn = formatDuration(score.getDueInDuration(currentDate));
          knowledgeLevel = score.goodInARow;
      }
      WordTableRow r = new WordTableRow(card, cssClass, dueIn, knowledgeLevel);
      ret.add(r);    
    }
    return ret;
    
  }
  

  String getCssClassFromScore(CardScore score) {   
    if (score == null) {
      return "notTested";
    }
    if (score.isGoodAnswer() && !CardScoresEngine.isInLearningList(score)) {
      return "succ";
    }
    else if (score.isGoodAnswer() && CardScoresEngine.isInLearningList(score)) {
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
            
}


class WordTableRow extends Object with Observable {
  
  @observable Card card; 
  @observable String cssClass;
  @observable String dueIn;
  @observable int knowledgeLevel;
  
  WordTableRow(this.card, this.cssClass, this.dueIn, this.knowledgeLevel);
 
}
