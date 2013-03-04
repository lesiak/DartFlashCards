part of forvo_api;

class ForvoResponse {
  
  String lang;  
  String word; 
  var attributes;
  List<ForvoItem> items;
  
  factory ForvoResponse.fromJsonString(String lang, String word, String responseText) {
    Map forvoData = JSON.parse(responseText);
    return new ForvoResponse.fromMap(lang, word, forvoData);
  }
  
  factory ForvoResponse.fromMap(String lang, String word, Map jsonMap) {  
      return new ForvoResponse(lang, word, jsonMap);
  }
  
  ForvoResponse(this.lang, this.word, Map json) {
    attributes = json["attributes"];
    List itemObjects = json["items"];
    items = itemObjects.map((o) => ForvoItem.fromMap(o)).toList();    
  }
  
}

class ForvoItem {
  
  var id;
  var addtime;
  var hits;
  var username;
  var sex;
  var country;
  var code;
  var langname;
  var pathmp3;
  var pathogg;
  
  static ForvoItem fromMap(Map jsonMap) {
      return new ForvoItem(jsonMap);
  }
  
  ForvoItem(Map jsonMap) {
    id = jsonMap["id"];
    addtime = jsonMap["addtime"];
    hits = jsonMap["hits"];
    username = jsonMap["username"];
    sex = jsonMap["sex"];
    country = jsonMap["country"];
    code = jsonMap["code"];
    langname = jsonMap["langname"];
    pathmp3 = jsonMap["pathmp3"];
    pathogg = jsonMap["pathogg"];
      
  }
  
}
