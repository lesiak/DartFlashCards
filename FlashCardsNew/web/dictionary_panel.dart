import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:FlashCardsNew/flashcards_core.dart';

@CustomTag('dictionary-panel')
class DictionaryPanelElement extends PolymerElement {
     
  @observable String searchTerm;
  
  @published List<String> deckNames = toObservable([]);
  
  @published List<DictionaryTableRow> allCards = toObservable([]);
  
  @published List<DictionaryTableRow> matchingCards = toObservable([]);
  
  @published int dictionarySize;
    
  DictionaryPanelElement.created() : super.created() {
    //print('AAAAAAAAAAAAAAAAAA' + deckNames.toString()); 
  } 
  
  @override
  void enteredView() {
    super.enteredView();
    loadAllCards();
  }
  
  void loadAllCards() {    
    List<DictionaryTableRow> cards = new List();  
    var engine = new Engine();
    Future.forEach(deckNames, 
        (wordfile) => engine.loadDeckFile('../wordfiles/$wordfile.json')
        .then((deckCards) {
          var cardRows = deckCards.map((card) => new DictionaryTableRow(card, wordfile));
          cards.addAll(cardRows);
        } , onError: (e, st) => print('Cannot read $wordfile, $e, $st')))
      .then((_) {
        allCards = cards;
        dictionarySize = allCards.length;
      });        
  }
  
  void searchTermChanged() {    
    if (searchTerm.length < 2) {     
      matchingCards.clear();  
    } else {
      var filtered = allCards.where(isCardMatching);      
      matchingCards = toObservable(filtered.toList());
    }
  }
  
  bool isCardMatching(DictionaryTableRow row) {
    return row.card.en.startsWith(searchTerm)
        || row.card.fi.startsWith(searchTerm)
        || row.card.ko.startsWith(searchTerm)
        || row.card.fr.startsWith(searchTerm);
  }
  
  
  
   
  bool get applyAuthorStyles => true;
  
  
  
  
}

class DictionaryTableRow extends Object with Observable {
  @observable Card card;
  @observable String deckName;
  
  
  DictionaryTableRow(this.card, this.deckName);
  
}
