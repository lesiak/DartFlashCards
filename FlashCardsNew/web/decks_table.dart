import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('decks-table')
class DecksTableElement extends PolymerElement {
  
  @published List<String> items;
  
  @observable String selectedName;
  
  DecksTableElement.created() : super.created();
  
  void wordFileClicked(Event e, var detail, Element target) {
    String deckName =  target.attributes['data-msg'];    
    selectedName = deckName;
    dispatchEvent(new CustomEvent('decknameclicked', detail: deckName)); 
  }
  
  String getCss(String wordFile, String _selectedNameTrigger) {    
    if (wordFile == selectedName) {
      return "selectedTableRow";      
    } else {
      return "";
    }
  }
}