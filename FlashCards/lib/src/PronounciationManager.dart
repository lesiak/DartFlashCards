part of forvo_api;

typedef void ForvoResonseCallback(HttpRequest req);

typedef void PlayMp3Method(String url);

class PronounciationManager {
  
  static final String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
  
  static Set<String> favoriteUsers = new Set.from(['ssoonkimi', 'x_WoofyWoo_x', 'floridagirl']);
  
  static Set<String> bannedUsers = new Set.from(['jcung']);
  
  FileCache fileCache;
  
  PlayMp3Method playMp3FromUrl;
  
  PronounciationManager(this.fileCache, this.playMp3FromUrl);
  
  
  
  void playPronounciation(String lang, String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    //print(filename);
    fileCache.readBlobIfExists(lang, filename, playMp3FromDisk, (e) => playMp3FromDiskErrorCallback(lang, word, item, e));
   // String url= item.pathogg;)(
    //var html='<audio autoplay="true"><source src="$url"></audio>';
    //query("#audioContainer").innerHtml = html;
  }
  
  void playMp3FromDisk(FileEntry e) {    
    String url= e.toUrl();
    print('playing from disk ${url}');
    playMp3FromUrl(url);
  }
  
  void playBlob(Blob b) {    
    String url=  Url.createObjectUrl(b);
    print('playing from blob ${url}');
    playMp3FromUrl(url);
  }
  
  void playMp3FromDiskErrorCallback(String lang, String word, ForvoItem item, FileError e) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    mp3req.then((xhr) => onMp3RequentFinishedSaveAndPlay(lang, filename, xhr));    
  }
  
  /*
  void fetchMp3ErrorCallback(String lang, String word, ForvoItem item, FileError e) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    mp3req.then((xhr) => onMp3RequentFinishedSave(lang, filename, xhr));    
  }
  */
  void fetchMp3(String lang, String word, ForvoItem item, FileError e) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    mp3req.then((xhr) => onMp3RequentFinishedSave(lang, filename, xhr));    
  }
  
  void onMp3RequentFinishedSave(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      fileCache.saveBlob(lang, filename, blob, (entry) {
        print("entry saved" + lang + " " + filename);
      });                        
    }
  }
  
  void onMp3RequentFinishedSaveAndPlay(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      fileCache.saveBlob(lang, filename, blob, (e) => playBlob(blob));                        
    }
  }
  
  
  
  
  void fetchPronunciations(String lang, String word) {
    print("fetching prono " + lang + " " + word);
    getPronunciations(lang, word, (req) => fetchPronunciationsSuccessCallback(req, lang, word));
  }
  
  void fetchPronunciationsSuccessCallback(HttpRequest req, String lang, String word) {
    String responseText = req.responseText;
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
      if (r.items.length == 1) {
        print('single prono $word');
        ForvoItem item = r.items[0];
        var filename = '${word}_${item.username}.ogg';
        fileCache.readBlobIfExists(lang, filename, (entry) {
          print('already exists ${filename}');
          item.pathogg = filename;
          window.localStorage[lang+"/"+word] = r.toJsonString();
          print('saved '+lang+"/"+word + "in localstorage");
        }, (error) => fetchMp3(lang, word, item, error));
      }
      else {
        print('longer than 1');
      }
    }
  }
  
  void getPronunciations(String lang, String word, ForvoResonseCallback onSuccessfullyParsedResponse) {
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    print(url);
    // call the web server asynchronously
    HttpRequest.request(url).then(onSuccessfullyParsedResponse, onError: (asyncError) => print(asyncError));
  }
  
  
  static ForvoItem getPreferredPronunciation(ForvoResponse r) {
    //is in favorites    
    for (ForvoItem item in r.items) {
      if (favoriteUsers.contains(item.username) ) {
        return item;
      }
    }
    for (ForvoItem item in r.items) {
      if (!bannedUsers.contains(item.username) ) {
        return item;
      }
    }
    
  }
}
