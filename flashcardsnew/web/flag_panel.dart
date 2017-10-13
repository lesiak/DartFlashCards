import 'package:polymer/polymer.dart';

@CustomTag('flag-panel')
class FlagPanel extends PolymerElement {
  
  static Map<String, String> flagsPaths = {
    "ko": "resources/svgFlags/Flag_of_Republic_of_Korea.svg", 
    "fi": "resources/svgFlags/Flag_of_Finland_1920-1978_(State).svg",
    "hu": "resources/svgFlags/Civil_Ensign_of_Hungary.svg",
    "fr": "resources/svgFlags/Flag_of_France.svg",
    "es": "resources/svgFlags/Flag_of_Spain_(Civil).svg",
    "it": "resources/svgFlags/Flag_of_Italy.svg",
    "cs": "resources/svgFlags/Flag_of_the_Czech_Republic.svg",
    "de": "resources/svgFlags/Flag_of_Germany.svg",
    "ru": "resources/svgFlags/Flag_of_Russia.svg"
  };
      
  @published String primaryLang;
  
  @observable String flagPath;    
  
  FlagPanel.created() : super.created();
  
  void primaryLangChanged() {
    //primaryLang = "ko";
    flagPath = flagsPaths[primaryLang];
  } 
 
}