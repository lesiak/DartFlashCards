part of forvo_api;

typedef void ForvoResonseCallback(HttpRequest req);

typedef void PlayMp3Method(String url);

class PronounciationManager {
  
  static final String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
  
  static Set<String> favoriteUsers = new Set.from(['ssoonkimi', 'x_WoofyWoo_x', 'floridagirl']);
  
  static Set<String> bannedUsers = new Set.from(['jcung']);
  
  FileCache fileCache;
  
  Mp3Player mp3Player;
  
  PronounciationManager(this.fileCache, PlayMp3Method playMp3FromUrl) {
    this.mp3Player = new Mp3Player(playMp3FromUrl);
  }
  
  
  
  void playPronounciation(String lang, String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    //print(filename);
    fileCache.readBlobIfExists(lang, filename).then(mp3Player.playMp3FromDisk, 
        onError: (e) => fetchMp3AndPlay(lang, word, item));
  }
  /*
  Future<HttpRequest> fetchMp3Future(String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    return mp3req;
  } */
  
  
  
  void fetchMp3AndPlay(String lang, String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    //Stream<HttpRequest> mp3reqStream =  new Stream.fromFuture(mp3req);
    //mp3reqStream.transform(new StreamTransformer(handleData, handleError, handleDone))

    mp3req.then((xhr) => onMp3RequentFinishedSaveAndPlay(lang, filename, xhr));    
  }
  
  
    
  
  void fetchMp3(String lang, String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    Future a= mp3req.then((xhr) => onMp3RequentFinishedSave(lang, filename, xhr));    
  }
  
  void onMp3RequentFinishedSaveAndPlay(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      fileCache.saveBlob(lang, filename, blob, (e) => mp3Player.playBlob(blob));                        
    }
  }
  
  String onMp3RequentFinishedSave(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      fileCache.saveBlob(lang, filename, blob, (entry) {
        print("entry saved" + lang + " " + filename);
      });                        
    }
    return "1";
  }
  

  
  void fetchPronunciations(String lang, String word) {
    print("fetching prono " + lang + " " + word);
    getForvoPronunciations(lang, word)
    .then((req) => fetchPronunciationsSuccessCallback(req, lang, word),
      onError: (asyncError) =>print(asyncError) );
  }
  
  void fetchPronunciationsSuccessCallback(HttpRequest req, String lang, String word) {
    String responseText = req.responseText;
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
      if (r.items.length == 1) {
        print('single prono $word');
        ForvoItem item = r.items[0];
        var filename = '${word}_${item.username}.ogg';
        fileCache.readBlobIfExists(lang, filename).then((entry) {
          print('already exists ${filename}');
          item.pathogg = filename;
          window.localStorage[lang+"/"+word] = r.toJsonString();
          print('saved '+lang+"/"+word + "in localstorage");
        }, onError: (error) => fetchMp3(lang, word, item));
      }
      else {
        print('longer than 1');
      }
    }
  }
  
  Future<HttpRequest> getForvoPronunciations(String lang, String word) {
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    print(url);
    // call the web server asynchronously
    return HttpRequest.request(url);
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

class Mp3Player {
  PlayMp3Method playMp3FromUrl;
  
  Mp3Player(this.playMp3FromUrl) {}
  
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
}
