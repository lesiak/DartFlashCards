library WordsTableLib;

import 'dart:html';
import 'package:observe/observe.dart';
import 'package:FlashCards/flashcards_core.dart';
import 'package:FlashCards/date_utils.dart';



class WordsTable {
  
  List<WordTableRow> wordRows = toObservable([]);

  void fillWordsTable(List<Card> allCardsInDeck) {    
    wordRows.clear();
    wordRows.addAll(mapToRowData(allCardsInDeck));
  }

  List<WordTableRow> mapToRowData(List<Card> allCardsInDeck) {
    List<WordTableRow> ret = [];
    var currentDate = new DateTime.now();
    for (Card card in allCardsInDeck) {
      CardScore score = ResultStore.getCardScoreFromStore(card);
        
      String dueIn = "";
      String cssClass = getCssClass(score);      
     
      if (score != null) {     
          dueIn = formatDuration(score.getDueInDuration(currentDate));
      }
      ret.add(new WordTableRow(card, cssClass, dueIn));    
    }
    print(allCardsInDeck.length);
    print(ret.length);
    return ret;
    
  }

  String getCssClass(CardScore score) {
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
  
  WordsTable() {
    query('#wordsTableTemplate').model = wordRows;         
  }
  
}

class WordTableRow {
  Card card;
  String cssClass;
  String dueIn;
  
  WordTableRow(this.card, this.cssClass, this.dueIn);
  
}