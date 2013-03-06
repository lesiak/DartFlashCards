library FlashCards;

import 'dart:html';
import 'dart:async';
import '../lib/forvo_api.dart';
import '../lib/flashcards_core.dart';
import '../lib/filecache_api.dart';


class FlashCardsUI {
  
  final String NBSP = "\u00A0";
  
  DeckState deckState;
  
  FileCache fileCache;
  
  RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  FlashCardsUI(this.deckState, this.fileCache);
  
  void showQuestion(Card card) {
    query("#en").text = card.en;    
    getPronunciations("en", card.en, "#enPro", true);  
    clearAnswerNodes();
    setAnswerButtonsDisabled(true);
    setQuestionButtonsDisabled(false);  
  }
  
  void showAnswer(Card card) { 
    query("#ko").text = card.ko;
    query("#fi").text = card.fi;
    query("#fr").text = card.fr;
    getPronunciations("ko", card.ko, "#koPro", true);
    getPronunciations("fi", card.fi, "#fiPro", false);
    getPronunciations("fr", card.fr, "#frPro", false);
    setAnswerButtonsDisabled(false);
    setQuestionButtonsDisabled(true);
  }

  
  void clearAnswerNodes() {
    query("#ko").text = NBSP;
    query("#fi").text = NBSP;
    query("#fr").text = NBSP;
    query("#koPro").nodes.clear();
    query("#fiPro").nodes.clear();
    query("#frPro").nodes.clear();
  }
  
  void setAnswerButtonsDisabled(bool disabled) {
    ButtonElement goodAnswerButton = query("#goodAnswerButton");
    goodAnswerButton.disabled = disabled;
    ButtonElement poorAnswerButton = query("#poorAnswerButton");
    poorAnswerButton.disabled = disabled;
    ButtonElement badAnswerButton = query("#badAnswerButton");
    badAnswerButton.disabled = disabled;
  }
  
  void setQuestionButtonsDisabled(bool disabled) {
    ButtonElement showAnswerButton = query("#showAnswerButton");
    showAnswerButton.disabled = disabled;    
  }
  
  void showLearningPanel() {
    query("#wordFilesDiv").hidden=true;
    query("#learningPanel").hidden=false;
  }

  void showHomePanel() {
    query("#wordFilesDiv").hidden=false;
    query("#learningPanel").hidden=true;
    query("#wordListDiv").hidden=false;
  }
  
  
  void getPronunciations(String lang, String word, String containerId, bool play) {    
    if (word.contains(',')) {
      word = word.split(',')[0];
    }
    if (word.startsWith("to ")) {
      word = word.substring(3);
    }
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    
    // call the web server asynchronously
    Element container = query(containerId);
    PronounciationManager.getPronunciations(lang, word, (req) => onForvoSuccess(req, lang, word, container, play));
 
  }


  void onForvoSuccess(HttpRequest req, String lang, String word, Element container, bool play) {  
    String responseText = req.responseText;
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
      displayPronounciations(r, container, play);
    }
    
  }

  void displayPronounciations(ForvoResponse r,  Element container, bool play) {      
   /* if (deckState.currentCard.en != r.requestWord) {
      return;
    }*/
    List<Element> pronounciationNodes = createAudioNodes(r);
    container.nodes.clear();
    container.nodes.addAll(pronounciationNodes);  
    if (play && !r.items.isEmpty) {
      playPronounciation(r.lang, r.word, PronounciationManager.getPreferredPronunciation(r));
    }
  }
  
 
  
  List<Element> createAudioNodes(ForvoResponse r) {
    List<Element> ret = [];
    for (ForvoItem item in r.items) {
      DivElement div = new DivElement(); 
      div.classes.add('btn-group');
      ButtonElement button = new ButtonElement();
      button.text = item.username;
      button.classes.add("btn");
      button.attributes['rel'] = 'tooltip';
      button.attributes['title'] = '${item.sex} ${item.country}';
      button.onClick.listen((e)  => playPronounciation(r.lang, r.word, item));
      div.nodes.add(button);   
      ret.add(div);
    }
    return ret;
  }

  void playPronounciation(String lang, String word, ForvoItem item) {
    var filename = '${word}_${item.username}.ogg';
    //print(filename);
    fileCache.readBlobIfExists(lang, filename, readBlobCallback, (e) => readErrorCallback(lang, word, item, e));
   // String url= item.pathogg;)(
    //var html='<audio autoplay="true"><source src="$url"></audio>';
    //query("#audioContainer").innerHtml = html;
  }
  
  void readBlobCallback(FileEntry e) {    
    String url= e.toUrl();
    print('playing from disk ${url}');
    var html='<audio autoplay="true"><source src="$url"></audio>';
    query("#audioContainer").innerHtml = html;
  }
  
  void playBlobCallback(Blob b) {    
    String url=  Url.createObjectUrl(b);
    print('playing from blob ${url}');
    var html='<audio autoplay="true"><source src="$url"></audio>';
    query("#audioContainer").innerHtml = html;
  }
  
  void readErrorCallback(String lang, String word, ForvoItem item, FileError e) {
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



}
