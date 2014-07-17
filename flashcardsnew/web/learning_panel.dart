import 'dart:html';

import 'package:polymer/polymer.dart';

import 'package:flashcardsnew/forvo_api.dart';
import 'package:flashcardsnew/flashcards_core.dart';
import 'package:flashcardsnew/filecache_api.dart';

@CustomTag('learning-panel')
class LearingPanelElement extends PolymerElement {
  
  PronounciationManager pronounciationManager;
  
  @published FileCache fileCache;
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @published String primaryLang; 
  
  @published String secondaryLang;
  
  @published String thirdLang;  
  
  @observable Card card = new Card("", "", "", "", "", "");
  
  @observable bool responsesVisible = false;
  
  DeckEngine deckEngine;
  
  LearingPanelElement.created() : super.created() {
    print('LearingPanelElement created');        
    /*FileCache fileCache = new FileCache( (cache) {    
      this.pronounciationManager = new PronounciationManager(cache, playMp3FromUrl);                
    });*/
    new PathObserver(this, 'fileCache')
        ..open((changeRecords) {          
          this.pronounciationManager = new PronounciationManager(fileCache, playMp3FromUrl);          
        });
       
  } 
  
  @override
  void attached() {    
    print('LearingPanelElement entered view');        
  }
  
  void goodAnswer() {    
    deckEngine.goodAnswer();
    showNextQuestion();
  }
  
  void showAnswer() {
    responsesVisible = true;  
    displayPronunciations(primaryLang, card.getValueForLang(primaryLang), card.en, "primaryPro", true);
    displayPronunciations(secondaryLang, card.getValueForLang(secondaryLang), card.en, "secondaryPro", false);
    displayPronunciations(thirdLang, card.getValueForLang(thirdLang), card.en, "thirdPro", false);   
  }
   
  void poorAnswer() {
    deckEngine.poorAnswer();
    showNextQuestion();
  }


  void badAnswer() {
    deckEngine.badAnswer();    
    showNextQuestion();
  }
  
  
  void showNextQuestion() {
    if (deckEngine.hasNextCard()) {
      deckEngine.nextCard();
      showCurrentQuestion();      
    }
    else {   
      dispatchEvent(new CustomEvent('deck-finished')); 
    }
  }
  
  void startPanel() {
    deckEngine = new DeckEngine(cards, primaryLang);
    showCurrentQuestion();
  }
  
  void showCurrentQuestion() {
    card = deckEngine.currentCard;
    responsesVisible = false;
    clearQuestionPronunciations();
    clearAnswerPronunciations();
    if (card != null) {
      displayPronunciations("en", card.en, card.en, "enPro", true);  
    }
  }
  
  void clearQuestionPronunciations() {  
      $['enPro'].nodes.clear();      
    }
  
  void clearAnswerPronunciations() {  
    $['primaryPro'].nodes.clear();
    $['secondaryPro'].nodes.clear();
    $['thirdPro'].nodes.clear();
  }
  
  String get answerPrimary {
    return card.getValueForLang(primaryLang);     
  }

  String get answerSecondary {
    return card.getValueForLang(secondaryLang);    
  }
  
  String get answerThird {
    return card.getValueForLang(thirdLang);    
  } 

    
  
  void displayPronunciations(String lang, String word, String wordEn, String containerId, bool play) {
    if (word == null) {
      return;
    }
    word = CardUtils.sanitizeWord(lang, word);
    Element container = $[containerId];        
    String cachedForvoResponse = window.localStorage[lang+"/"+word];
       
    if (cachedForvoResponse != null) {
      print('found $word pronounciation list in localstorage');
      try {
        ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, cachedForvoResponse);      
        displayPronounciationsFromForvoResponse(r, container, play);
      } catch(e) {
        print("BBBBB ${e}");
        window.alert("Unexpecrted excepttion");          
      }
    } 
    else {
      // call the web server asynchronously
      print('Fetching sound: $word');
            
      
      // String resp = 'TEST_RESP';       
     // onForvoSuccessTest(resp, lang, word, container, play);
      
      pronounciationManager.getForvoPronunciations(lang, word)          
        .then((req) => onForvoSuccess(req, lang, word, wordEn, container, play))
        .catchError((e) {          
          print("EEE Could not fetch pronunciation ${e}");           
        });
              
    }        
  }
  
  /*void onForvoSuccessTest(String  responseText, String lang, String word, Element container, bool play) {  
    
    print(responseText);
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
      displayPronounciations(r, container, play);
    }*/


  void onForvoSuccess(HttpRequest req, String lang, String word, String wordEn, Element container, bool play) {  
    String responseText = req.responseText;
    if (responseText.isEmpty) {
      return;
    }
    if (card.en != wordEn) {
      return;
    }
    ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
    displayPronounciationsFromForvoResponse(r, container, play);
        
  }

  void displayPronounciationsFromForvoResponse(ForvoResponse r,  Element container, bool play) {      
   /* if (deckState.currentCard.en != r.requestWord) {
      return;
    }*/    
    List<Element> pronounciationNodes = createAudioNodes(r);    
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
      button.classes.add("btn btn-default");
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
    $['audioContainer'].setInnerHtml(html, treeSanitizer : new NullTreeSanitizer());
  }
   
}


/**
 * Sanitizer which does nothing.
 */
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}