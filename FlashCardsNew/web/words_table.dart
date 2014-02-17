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
  
  @published String secondaryLang;
  
  @published String thirdLang;
  
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
      WordTableRow r = new WordTableRow(card, cssClass, dueIn, primaryLang, secondaryLang, thirdLang);
      //to prevent tree shaking
     // print(r.getValForLang("en"));
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
    }
  }
  
  
  String getLangName(String lang) {
    if (lang == "ko") {
      return "Korean";
    } else if (lang == "fi") {
      return "Finnish";      
    } else if (lang == "fr") {
      return "French";      
    } else if (lang == "hu") {
      return "Hungarian";      
    } else if (lang == "zh") {
      return "Chinese";      
    } else if (lang==null) {
      return "null";
    }
    return "unknown";
  }
  
  
  
  // This lets the Bootstrap CSS "bleed through" into the Shadow DOM
  // of this element.
  bool get applyAuthorStyles => true;
}


class WordTableRow extends Object with Observable {
  @observable Card card;
  
  @observable String first;
  @observable String second;
  @observable String third;
  
  
  @observable String cssClass;
  @observable String dueIn;
  
  WordTableRow(this.card, this.cssClass, this.dueIn, String primLang, String secLang, String thirdLang) {
    this.first = card.getValueForLang(primLang);
    this.second = card.getValueForLang(secLang);
    this.third = card.getValueForLang(thirdLang);
  } 
  
  //String getValForLang(lang) {
  //  return card.getValueForLang(lang);
  //}
  
  
}

