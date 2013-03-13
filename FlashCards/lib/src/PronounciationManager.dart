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
    fileCache.readBlobIfExists(lang, filename, readMp3BlobCallback, (e) => readMp3ErrorCallback(lang, word, item, e));
   // String url= item.pathogg;)(
    //var html='<audio autoplay="true"><source src="$url"></audio>';
    //query("#audioContainer").innerHtml = html;
  }
  
  void readMp3BlobCallback(FileEntry e) {    
    String url= e.toUrl();
    print('playing from disk ${url}');
    playMp3FromUrl(url);
  }
  
  void playBlobCallback(Blob b) {    
    String url=  Url.createObjectUrl(b);
    print('playing from blob ${url}');
    playMp3FromUrl(url);
  }
  
  void readMp3ErrorCallback(String lang, String word, ForvoItem item, FileError e) {
    var filename = '${word}_${item.username}.ogg';
    print("not found in cache $filename");
    Future<HttpRequest> mp3req = HttpRequest.request(item.pathogg, 
        responseType: 'blob');
    
    mp3req.then((xhr) {
      if (xhr.status == 200) {        
        var blob = xhr.response;
        fileCache.saveBlob(lang, filename, blob, (e) => playBlobCallback(blob));                        
      }
    });    
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
