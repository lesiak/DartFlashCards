part of forvo_api;

class ForvoResponse {
   
  var attributes;
  List<ForvoItem> items;
  
  factory ForvoResponse.fromJsonString(String responseText) {
    Map forvoData = JSON.parse(responseText);
    return new ForvoResponse.fromMap(forvoData);
  }
  
  factory ForvoResponse.fromMap(Map jsonMap) {  
      return new ForvoResponse(jsonMap);
  }
  
  ForvoResponse(Map json) {
    attributes = json["attributes"];
    List itemObjects = json["items"];
    items = itemObjects.mappedBy((o) => ForvoItem.fromMap(o)).toList();
    
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
