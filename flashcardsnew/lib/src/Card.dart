part of flashcards_core;

class Card {
  String en;
  String es;
  String fi;
  String fr;
  String da;
  String hu;
  String ko;
  
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
