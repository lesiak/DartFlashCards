import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:flashcardsnew/flashcards_core.dart';
import 'package:flashcardsnew/locale_utils.dart';

@CustomTag('dictionary-panel')
class DictionaryPanelElement extends PolymerElement {
  
  @observable String searchTerm;
  
  @published String primaryLang; 
    
  @published String secondaryLang;
  
  @published String thirdLang;
         
  @published List<String> deckNames = toObservable([]);
  
  @observable List<DictionaryTableRow> allCards = toObservable([]);
  
  @observable List<DictionaryTableRow> matchingCards = toObservable([]);
  
  @observable int dictionarySize;
  
  @observable int dictionaryInPrimaryLangSize;
    
  DictionaryPanelElement.created() : super.created() {        
    new PathObserver(this, 'primaryLang')
       ..open((_) {          
         dictionaryInPrimaryLangSize = calculateNonEmptyInPrimLang();
       });
  } 
  
  @override
  void attached() {    
    loadAllCards();
  }
  
  void loadAllCards() {    
    List<DictionaryTableRow> cards = new List();      
    loadCardsFromDecksIgnoringErrors(deckNames)
      .then((cards) {
        allCards = cards;
        dictionarySize = allCards.length;
        dictionaryInPrimaryLangSize = calculateNonEmptyInPrimLang();        
      });        
  }
  
  Future<List<DictionaryTableRow>> loadCardsFromDecksIgnoringErrors(List<String> deckNames) {
    List<DictionaryTableRow> dictRows = new List<DictionaryTableRow>();  
        
    return Future.forEach(deckNames, 
        (wordfile) => DeckLoader.loadDeckFile('./wordfiles/$wordfile.json')
        .then((deckCards) {
          var cardRows = deckCards.map((card) => new DictionaryTableRow(card, wordfile));
          dictRows.addAll(cardRows);
        } , onError: (e, st) => print('Cannot read $wordfile, $e, $st')))
        .then((_) {
          return dictRows;                   
        });
  }
  
  int calculateNonEmptyInPrimLang() {
    return allCards.where((r) => isCardNonEmptyForLang(r,primaryLang)).length;
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
  
  
  
  bool isCardNonEmptyForLang(DictionaryTableRow row, String langName) {
    String cardValue = row.card.getValueForLang(langName); 
    if (cardValue == null) {
          return false;
     } else {
       return cardValue.trim().isNotEmpty;
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
      String sanitizedWord = CardUtils.sanitizeWord(langName, cardValue);      
      return sanitizedWord.startsWith(searchRegex);
    }    
  }
  
  String getLangName(String lang) => LangUtils.getLangName(lang);
    
  String getValueForLang(Card c, String lang) => c.getValueForLang(lang);
  
}

class DictionaryTableRow extends Object with Observable {
  
  @observable Card card;  
  
  @observable String deckName;
 
  DictionaryTableRow(this.card, this.deckName);
  
}
