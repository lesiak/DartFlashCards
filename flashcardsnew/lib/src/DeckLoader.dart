part of flashcards_core;

class DeckLoader {
           
  static Future<List<Card>> loadDeckFile(String wordfilePath) {
    Future<List<Card>> allCardsFut = HttpRequest.getString(wordfilePath).then(_buildDeckFromJson);
    return allCardsFut;
  }
    
  static List<Card> _buildDeckFromJson(String wordListJSON) {
    List rawData = JSON.decode(wordListJSON); // parse response text
    List<Card> allCards = rawData.map(_entryToCard).toList();
    return allCards;    
  }
  
  static Card _entryToCard(var entry) {
    return new Card(entry["en"], entry["es"], entry["fi"], entry["fr"], entry["it"], entry["cs"], entry["hu"], entry["ko"]);
  }
    
}




