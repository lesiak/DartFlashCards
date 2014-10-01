part of flashcards_core;

// Waiting on bug https://code.google.com/p/dart/issues/detail?id=13849
//import 'package:polymer/polymer.dart'
//show ObservableMixin, observable, bindProperty, notifyProperty;

class Card extends Object with Observable {
  @observable String en;
  @observable String es;
  @observable String fi;
  @observable String fr;
  @observable String da;
  @observable String hu;
  @observable String ko;
  
  factory Card.empty() {
    return new Card("", "", "", "", "", "", "");
  }
  
  Card(this.en, this.es, this.fi, this.fr, this.da, this.hu, this.ko);
  
  String getValueForLang(String lang) {    
    switch (lang) {
      case "en": return en;            
      case "fi": return fi;
      case "fr": return fr;
      case "es": return es;
      case "da": return da;
      case "hu": return hu;
      case "ko": return ko;      
      default: return null;
    }
  }
  
  
}
