import 'package:polymer/polymer.dart';
import 'dart:html';


@CustomTag('deckname-td-item')
class DecknameTdItemElement extends TableCellElement with Polymer, Observable {
  @published String item;
  
  bool get applyAuthorStyles => true;
  
  DecknameTdItemElement.created() : super.created();    
  
  void wordFileClicked(Event e, var detail, Node target) {
    String deckName =  $['deckAnchor'].text;        
    dispatchEvent(new CustomEvent('decknameclicked', detail: deckName)); 
  }
}