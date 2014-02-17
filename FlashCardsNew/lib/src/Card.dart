part of flashcards_core;

// Waiting on bug https://code.google.com/p/dart/issues/detail?id=13849
//import 'package:polymer/polymer.dart'
//show ObservableMixin, observable, bindProperty, notifyProperty;

class Card extends Object with Observable {
  @observable String en;  
  @observable String fi;
  @observable String fr;
  @observable String hu;
  @observable String ko;
  @observable String zh;
  
  Card(this.en, this.fi, this.fr, this.hu, this.ko, this.zh);
  
  String getValueForLang(String lang) {
    switch (lang) {
      case "en": return en;      
      case "fi": return fi;
      case "fr": return fr;
      case "hu": return hu;
      case "ko": return ko;
      case "zh": return zh;
      default: return null;
    }
  }
  
  
}
