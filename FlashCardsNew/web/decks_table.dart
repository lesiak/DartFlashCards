import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('decks-table')
class DecksTableElement extends PolymerElement {
  @published List<String> items;
  
  DecksTableElement.created() : super.created();
  
  void wordFileClicked(Event e, var detail, Element target) {
    String deckName =  target.attributes['data-msg'];
    //message = target.attributes['data-msg'];
    print(deckName);
    dispatchEvent(new CustomEvent('decknameclicked', detail: deckName)); 
  }
  
  /*void increment(Event e, var detail, Node target) {
    count += 1;
  }*/
  
  bool get applyAuthorStyles => true;
}