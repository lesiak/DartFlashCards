import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:FlashCardsNew/flashcards_core.dart';

@CustomTag('dictionary-panel')
class DictionaryPanelElement extends PolymerElement {
  
  @observable String searchTerm;
  
  @published String primaryLang; 
    
  @published String secondaryLang;
  
  @published String thirdLang;
         
  @published List<String> deckNames = toObservable([]);
  
  @published List<DictionaryTableRow> allCards = toObservable([]);
  
  @published List<DictionaryTableRow> matchingCards = toObservable([]);
  
  @published int dictionarySize;
    
  DictionaryPanelElement.created() : super.created() {        
    new PathObserver(this, 'primaryLang')
       ..changes.listen((_) {
          //here we know that primaryLang is loaded
          loadAllCards();
       });
  } 
  
  @override
  void enteredView() {
    super.enteredView();   
  }
  
  void loadAllCards() {    
    List<DictionaryTableRow> cards = new List();  
    var engine = new Engine();    
    Future.forEach(deckNames, 
        (wordfile) => engine.loadDeckFile('./wordfiles/$wordfile.json')
        .then((deckCards) {
          var cardRows = deckCards.map((card) => 
              new DictionaryTableRow(card, wordfile, primaryLang, secondaryLang, thirdLang));
          cards.addAll(cardRows);
        } , onError: (e, st) => print('Cannot read $wordfile, $e, $st')))
      .then((_) {
        allCards = cards;
        dictionarySize = allCards.length;
      });        
  }
  
  void searchTermChanged() {    
    if (searchTerm.contains("a:")) {
      searchTerm = searchTerm.replaceAll("a:", '\u00e4');
      return;
    } else if (searchTerm.contains("o:")) {
      searchTerm = searchTerm.replaceAll("o:", '\u00f6');
      return;
    }
    if (searchTerm.length < 2) {     
      matchingCards.clear();  
    } else {
      var filtered = allCards.where(isCardMatching);      
      matchingCards = toObservable(filtered.toList());
    }
  }
  
  bool isCardMatching(DictionaryTableRow row) {
    var searchRegex = new RegExp(searchTerm, caseSensitive: false);     
    return isCardMatchingLang(row.card, "en", searchRegex)
        || isCardMatchingLang(row.card, primaryLang, searchRegex)
        || isCardMatchingLang(row.card, secondaryLang, searchRegex)
        || isCardMatchingLang(row.card, thirdLang, searchRegex);
  }
  
  static bool isCardMatchingLang(Card card, String langName, RegExp searchRegex) {
    String cardValue = card.getValueForLang(langName);
    if (cardValue == null) {
      return false;
    } else {
      String sanitizedWord = sanitizeWordForMatching(cardValue, langName);      
      return sanitizedWord.startsWith(searchRegex);
    }    
  }
  
  static String sanitizeWordForMatching(String word, String langName) {
    if (langName == "en" && word.startsWith("to ")) {
      return word.substring(3);
    } else if (langName == "es" && (word.startsWith('(el) ') || word.startsWith('(la) '))) {
      return word.substring(5);            
    } else {
      return word;
    } 
  }
  
  
   
  bool get applyAuthorStyles => true;
  
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
      } else if (lang == "es") {
        return "Spanish";      
      } else if (lang==null) {
        return "null";
      }
      return "unknown";
    }
    
}

class DictionaryTableRow extends Object with Observable {
  @observable Card card;
  
  @observable String first;
  @observable String second;
  @observable String third;
  @observable String deckName;
  
  
  DictionaryTableRow(this.card, this.deckName, String primLang, String secLang, String thirdLang) {
    this.first = card.getValueForLang(primLang);    
    this.second = card.getValueForLang(secLang);
    this.third = card.getValueForLang(thirdLang);
  }
  
}
