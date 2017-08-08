import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('decks-table')
class DecksTableElement extends PolymerElement {
  
  @published List<String> items;
  
  @observable String selectedName;
  
  DecksTableElement.created() : super.created();

  RegExp _startingDigitsAndUnderScore = new RegExp(r'^\d+_');
  
  void wordFileClicked(Event e, var detail, Element target) {
    String deckName =  target.attributes['data-msg'];    
    selectedName = deckName;
    dispatchEvent(new CustomEvent('decknameclicked', detail: deckName)); 
  }

  String getBaseName(String wordfilePath) {
    String fileName = wordfilePath.split("/").last;
    return fileName.replaceFirst(_startingDigitsAndUnderScore, '');
  }
  
}