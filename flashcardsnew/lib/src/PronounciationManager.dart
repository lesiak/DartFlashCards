part of forvo_api;

typedef void ForvoResonseCallback(HttpRequest req);

typedef void PlayMp3Method(String url);

typedef void FetchProgressStepMethod(bool success);

class PronounciationManager {
  
  static final String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
  
  static Set<String> favoriteUsers = new Set.from(['ssoonkimi', 
                                                   'x_WoofyWoo_x', 
                                                   'floridagirl',
                                                   'guijaran2']);
  
  static Set<String> bannedUsers = new Set.from(['jcung', 'MytoonKitty56']);
  
  FileCache fileCache;
  
  Mp3Player mp3Player;
  
  PronounciationManager(this.fileCache, PlayMp3Method playMp3FromUrl) {
    this.mp3Player = new Mp3Player(playMp3FromUrl);
  }
  
  void fetchMissingPronunciations(String lang, String word, FetchProgressStepMethod fetchProgressStepMethod) {
    if (word == null) {
      fetchProgressStepMethod(false);
      return;
    }
    hasForvoResponseInFileSystem(lang,word).then((bool hasItem) {
      if (hasItem) {
        print ('found pronounciation list for ${lang}/${word} in fileSystem');
          fetchProgressStepMethod(true);
        } else {
          fetchPronunciations(lang, word, fetchProgressStepMethod);
        }  
      }
    );      
  }         
  
  void fetchPronunciations(String lang, String word, FetchProgressStepMethod fetchProgressStepMethod) {
    print("fetching prono " + lang + " " + word);
    getForvoPronunciations(lang, word)
      .then((req) => _fetchPronunciationsSuccessCallback(req, lang, word, fetchProgressStepMethod),
        onError: (asyncError) {
          fetchProgressStepMethod(false);
          print(asyncError);
        });
  }
  
  void _fetchPronunciationsSuccessCallback(HttpRequest req, String lang, String word, FetchProgressStepMethod fetchProgressStepMethod) {
    String responseText = req.responseText;
    if (responseText.isEmpty) {
      print('empty response');
      fetchProgressStepMethod(false);
      return;      
    }
    ForvoResponse r;
    try {
     r = new ForvoResponse.fromJsonString(lang, word, responseText);
    } catch(e) {
      //fileCache.saveText('PronoMetadata', "dupa.txt",  "dupa").then((val) => print('saved in filesystem'));
      fetchProgressStepMethod(false);
      print(e);
      return;
    }
    if (r.items.length > 0) {        
      Future.forEach(r.items, (item) {
        var filename = _makeitemFileName(word, item);
        Future ret = fileCache.readEntry(lang, filename)
        .then( (entry) {
          print('already exists ${filename}, at: ${entry.fullPath}');
          return entry;
        })
        .catchError((error) => _fetchMp3(lang, word, item))
        .then((Entry entry) {             
          item.pathogg = entry.fullPath;                                    
        });
        return ret;
      }).then((val) {
        saveForvoResponseToLocalStorage(lang, word, r);
        fetchProgressStepMethod(true);
      }).catchError((error) {         
        fetchProgressStepMethod(false);
        print(error);
      });
    }
    else {
      print('no items in response');
      fetchProgressStepMethod(false);
    }   
  }
  
  void saveForvoResponseToLocalStorage(String lang, String word, ForvoResponse r) {    
    var key = '${lang}_${word}.txt';
    //window.localStorage[key] = r.toJsonString();
    fileCache.saveText('PronoMetadata', key,  r.toPrettyJsonString()).then((val) => print('saved ${key} in filesystem'));
    
  }
  
  Future<bool> hasForvoResponseInFileSystem(String lang, String word) {    
    var key = '${lang}_${word}.txt';
    //return window.localStorage[key] != null;
    return fileCache.fileExistsinDir('PronoMetadata', key);
  }
  
  Future<String> getForvoResponseFromFileSystem(String lang, String word) {
    var key = '${lang}_${word}.txt';
    return fileCache.readFileAsText('PronoMetadata', key);
  }
  
  
  Future<HttpRequest> getForvoPronunciations(String lang, String word) {
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    print(url);
    // call the web server asynchronously
    return HttpRequest.request(url);
  }
  
  
  void playPronounciation(String lang, String word, ForvoItem item) {
    var filename = _makeitemFileName(word, item);  
    fileCache.readEntry(lang, filename)
      .then(mp3Player.playMp3FromDisk, 
        onError: (e) => _fetchMp3AndPlay(lang, word, item));
  }
  
  void _fetchMp3AndPlay(String lang, String word, ForvoItem item) {
    var filename = _makeitemFileName(word, item);
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, responseType: 'blob');
    
    //Stream<HttpRequest> mp3reqStream =  new Stream.fromFuture(mp3req);
    //mp3reqStream.transform(new StreamTransformer(handleData, handleError, handleDone))

    mp3req.then((xhr) => _onMp3RequentFinishedSaveAndPlay(lang, filename, xhr));    
  }
  
  
    
  
  Future<FileEntry> _fetchMp3(String lang, String word, ForvoItem item) {
    var filename = _makeitemFileName(word, item);
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    Future<FileEntry> writtenFileFuture = mp3req
        .then((xhr) => _onMp3RequentFinishedSave(lang, filename, xhr));
    
    return writtenFileFuture; 
  }
  
  String _makeitemFileName(String word, ForvoItem item) => '${word}_${item.username}.ogg';
  
  void _onMp3RequentFinishedSaveAndPlay(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      fileCache.saveBlob(lang, filename, blob)
        .then((entry) => mp3Player.playBlob(blob))
        .catchError((e) => print (e));                        
    }
  }
  
  Future<FileEntry> _onMp3RequentFinishedSave(String lang, String filename, HttpRequest xhr) {
    if (xhr.status == 200) {        
      var blob = xhr.response;
      return fileCache.saveBlob(lang, filename, blob)
        .then((entry) {
          print("_onMp3RequentFinishedSave entry saved " + lang + " " + filename);
          return entry;
        });
    }
    throw new Exception('Did not receive audio file, xhr status: ${xhr.status}');
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
    return null;
    
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
