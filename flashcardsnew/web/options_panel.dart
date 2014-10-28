import 'package:polymer/polymer.dart';
import 'dart:html';


@CustomTag('options-panel')
class OptionsPanel extends PolymerElement {
  
  @published String selectedOption = "optionsRadiosFiDaEs"; 
  
  OptionsPanel.created() : super.created() {       
  }
  
  void onOkClicked() {
    //print('ok');
    dispatchEvent(new CustomEvent('okclicked')); 
  }          
  
  void onCancelClicked() {
      //print('Cancel');
    dispatchEvent(new CustomEvent('cancelclicked')); 
    }
}


