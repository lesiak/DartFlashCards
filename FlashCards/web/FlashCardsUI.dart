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
  
  PronounciationManager pronounciationManager;
  
  RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  FlashCardsUI(this.deckState, this.fileCache) {
    this.pronounciationManager = new PronounciationManager(fileCache, playMp3FromUrl);
  }
  
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
    query("#deckDetailsDiv").hidden=false;
  }
  
  String sanitizeWord(String word) {
    if (word.contains(',')) {
      word = word.split(',')[0];
    }
    if (word.startsWith("to ")) {
      word = word.substring(3);
    }
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    return word;
  }
  
  
  void getPronunciations(String lang, String word, String containerId, bool play) {    
    word = sanitizeWord(word);

    Element container = query(containerId);
    String cachedForvoResponse = window.localStorage[lang+"/"+word];
    if (cachedForvoResponse != null) {
      print('found $word pronounciation list in localstorage');
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, cachedForvoResponse);      
      displayPronounciations(r, container, play);
    } 
    else {
      // call the web server asynchronously
      pronounciationManager.getPronunciations(lang, 
          word, 
          (req) => onForvoSuccess(req, lang, word, container, play));
    }
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
      pronounciationManager.playPronounciation(r.lang, r.word, PronounciationManager.getPreferredPronunciation(r));
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
      button.onClick.listen((e)  => pronounciationManager.playPronounciation(r.lang, r.word, item));
      div.nodes.add(button);   
      ret.add(div);
    }
    return ret;
  }

  
  
 
  
  void playMp3FromUrl(String url) {
    var html='<audio autoplay="true"><source src="$url"></audio>';
    query("#audioContainer").innerHtml = html;
  }
  
 



}
