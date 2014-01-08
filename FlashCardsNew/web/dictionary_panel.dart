import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:FlashCardsNew/flashcards_core.dart';

@CustomTag('dictionary-panel')
class DictionaryPanelElement extends PolymerElement {
     
  @observable String searchTerm;
  
  @published List<String> deckNames = toObservable([]);
  
  @published List<Card> allCards = toObservable([]);
  
  @published List<Card> matchingCards = toObservable([]);
    
  DictionaryPanelElement.created() : super.created() {
    //print('AAAAAAAAAAAAAAAAAA' + deckNames.toString()); 
  } 
  
  @override
  void enteredView() {
    super.enteredView();
    loadAllCards();
  }
  
  void loadAllCards() {    
    var cards = new List();  
    var engine = new Engine();
    Future.forEach(deckNames, 
        (wordfile) => engine.loadDeckFile('../wordfiles/$wordfile.json').then((deckCards) => cards.addAll(deckCards), onError: (e, st) => print('Cannot read $wordfile, $e, $st')))
      .then((_) => allCards = cards);        
  }
  
  void searchTermChanged() {
    print('onSearchTermChanged' + searchTerm);
    if (searchTerm.length < 2) {     
      matchingCards.clear();  
    } else {
      var filtered = allCards.where(isCardMatching);      
      matchingCards = toObservable(filtered.toList());
    }
  }
  
  bool isCardMatching(Card card) {
    return card.en.startsWith(searchTerm)
        || card.fi.startsWith(searchTerm)
        || card.ko.startsWith(searchTerm)
        || card.fr.startsWith(searchTerm);
  }
  
  
  
   
  bool get applyAuthorStyles => true;
  
  
}
