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
  
  @published ObservableList<CardWithScore> cardsWithScore = toObservable([]);
  
  @published String primaryLang;
  
  @published String secondaryLang;
  
  @published String thirdLang;
  
  WordsTable.created() : super.created() {
    new PathObserver(this, 'cardsWithScore')
    ..open((_) {
      //wordRows = mapToRowData(cardsWithScore);
      replaceWordRows(mapToRowData(cardsWithScore));
    });    
  }
  
  void replaceWordRows(List<WordTableRow> newWords) {
     if (wordRows.length > newWords.length) {
       //(wordRows.removeRange(newWords.length, wordRows.length);
       for(int i = 0 ; i < wordRows.length; ++i) {
               wordRows[i].cssClass = "hidden";        
             }
       for(int i = 0 ; i < wordRows.length; ++i) {
         wordRows[i].copyFrom(newWords[i]);        
       }
     } else {
       for(int i = 0 ; i < wordRows.length; ++i) {
         wordRows[i].copyFrom(newWords[i]);        
       }
       int i = wordRows.length;
       List newItems = [];
       while (i < newWords.length) {
         newItems.add(newWords[i]);
         ++i;
       }
       if (newItems.isNotEmpty) {
         wordRows.addAll(newItems);
       }
     }
   }
  
 
  List<WordTableRow> mapToRowData(List<CardWithScore> cardsWithScore) {
    List<WordTableRow> ret = [];
    var currentDate = new DateTime.now();
    for (CardWithScore cardWithScore in cardsWithScore) {
      CardScore score = cardWithScore.score;
        
      String dueIn = "";
      String cssClass = getCssClassFromScore(score);      
      int knowledgeLevel = 0;
      if (score != null) {     
          dueIn = formatDuration(score.getDueInDuration(currentDate));
          knowledgeLevel = score.goodInARow;
      }
      WordTableRow r = new WordTableRow(cardWithScore.card, cssClass, dueIn, knowledgeLevel);
      ret.add(r);    
    }
    return ret;
    
  }
  

  String getCssClassFromScore(CardScore score) {   
    if (score == null) {
      return "notTested";
    }
    if (score.isGoodAnswer()) {
      return "succ";
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
  
  void copyFrom(WordTableRow from) {
       this.card = from.card;
       this.cssClass = from.cssClass;
       this.dueIn = from.dueIn;
       this.knowledgeLevel = from.knowledgeLevel;
     }
 
}

