import 'dart:html';

import 'package:polymer/polymer.dart';

import 'package:FlashCardsNew/forvo_api.dart';
import 'package:FlashCardsNew/flashcards_core.dart';
import 'package:FlashCardsNew/filecache_api.dart';

@CustomTag('learning-panel')
class LearingPanelElement extends PolymerElement {
  
  PronounciationManager pronounciationManager;
  
  @published ObservableList<Card> cards = toObservable([]);
  
  @published String primaryLang; 
  
  @observable Card card = new Card("", "", "", "");
  
  @observable bool responsesVisible = false;
  
  DeckEngine deckEngine;
  
  LearingPanelElement.created() : super.created() {
    print('LearingPanelElement created');
    
    FileCache fileCache = new FileCache( (cache) {    
      this.pronounciationManager = new PronounciationManager(cache, playMp3FromUrl);                
    });
       
  } 
  
  @override
  void enteredView() {
    super.enteredView();
    print('LearingPanelElement entered view');    
  }
  
  void goodAnswer() {    
    deckEngine.goodAnswer();
    showNextQuestion();
  }
  
  void showAnswer() {
    responsesVisible = true;
    getPronunciations("ko", card.ko, "koPro", "ko"==primaryLang);
    getPronunciations("fi", card.fi, "fiPro", "fi"==primaryLang);
    getPronunciations("fr", card.fr, "frPro", false);   
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
    deckEngine = new DeckEngine(cards);
    showCurrentQuestion();
  }
  
  void showCurrentQuestion() {
    card = deckEngine.currentCard;
    responsesVisible = false;
    clearAnswerNodes();
    if (card != null) {
      getPronunciations("en", card.en, "enPro", true);  
    }
  }
  
  void clearAnswerNodes() {  
    $['koPro'].nodes.clear();
    $['fiPro'].nodes.clear();
    $['frPro'].nodes.clear();
  }
  
  String get answerPrimary { 
    if (primaryLang == "fi") 
      return card.fi; 
    else 
      return card.ko; 
  }

  String get answerSecondary {
    if (primaryLang == "fi") 
      return card.ko; 
    else 
      return card.fi;
  } 
    
  
  void getPronunciations(String lang, String word, String containerId, bool play) {    
    word = ForvoRequestUtils.sanitizeWord(lang, word);

    Element container = $[containerId];    
    String cachedForvoResponse = window.localStorage[lang+"/"+word];
    if (cachedForvoResponse != null) {
      print('found $word pronounciation list in localstorage');
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, cachedForvoResponse);      
      displayPronounciations(r, container, play);
    } 
    else {
      // call the web server asynchronously
      if (play) {
      print('EEEEEEEEEEEEEEEEEEEEEEEEE Playing sound: ' +word);
      }
     // String resp = '{"attributes":{"total":2},"items":[{"id":259850,"word":"\uae30\uacc4","addtime":"2009-07-28 02:40:01","hits":209,"username":"fairybel","sex":"f","country":"Korea, Republic of","code":"ko","langname":"Korean","pathmp3":"http:\/\/apifree.forvo.com\/audio\/1n3k3m3b2n22391j3o322q3e2d2h3c2h2c3c3i3l2f2a2p3k1m282f1o1l3l243c3e3q2a2e2o3i3e25363f3c1i3o1f1j282f28212d1m2d3e333m1b3k3a3i1n1b1g27273b1g1h362c3a2e3d383q233o2p2f2i3m283g2f371t1t_231g3j2o3f1m2d3k283h1k2p213n3k2i1m1h2e37322h1t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/3p3d1l3d3p393n3p282j3i3m3g1k3m2c1f2i352j3g2m31343h381l312f3c3b3q1h3a3k2n2n1j1i3p223g3p2f1h1o3p1n25233e3c1f1h1j1p3f1l3d2p242o3i3f321l1k3g3i3a2h25333o3i3e3d1f3k362f1m2i2q3g371t1t_362d2g3n24392i1k3h1n3o2q2d3c2k2a311p271b3k371t1t","rate":"0","num_votes":"0","num_positive_votes":0},{"id":1732756,"word":"\uae30\uacc4","addtime":"2012-09-15 05:48:49","hits":174,"username":"magicalcicada","sex":"m","country":"Korea, Republic of","code":"ko","langname":"Korean","pathmp3":"http:\/\/apifree.forvo.com\/audio\/1j39361m2i3k1p2e3f2m3g3m243c2a3c3h2l1j1p2q2j332o2k2g1i372e2q3k27352i2j3i2e3e323k2m371b3f1p33322l1m2o272l33241n2n212q261b212e3d252b2f3j2b1n1j2i24352c283i2b393c1h1n212o3p292h1t1t_3l243e23212j1h1i1m2p3e2i3l1i3j3a3f3d372o2l2h1t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/283h3d3h35341j3c23373b3d2l33222m3k253l2f2b293d3c2m1k3125341j1h2f2j2d3m3h26353h3k2b2k1k2p3j2m2c3l3o2m2i393i2q1h3h1f362f291o3d233d361n3l243o1n262i34363f2k3h1k323j2c2a3m2q2a2h1t1t_2p291k28243o2a2428372d353g2m34372j3p2l2d372h1t1t","rate":"0","num_votes":"0","num_positive_votes":0}]} ';
     // onForvoSuccessTest(resp, lang, word, container, play);
      pronounciationManager.getForvoPronunciations(lang, word)
      .then((req) => onForvoSuccess(req, lang, word, container, play), 
        onError: (asyncError) => print(asyncError));              
    }
  }
  
  /*void onForvoSuccessTest(String  responseText, String lang, String word, Element container, bool play) {  
    
    print(responseText);
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, responseText);
      displayPronounciations(r, container, play);
    }*/


  void onForvoSuccess(HttpRequest req, String lang, String word, Element container, bool play) {  
    String responseText = req.responseText;
  //  print(responseText);
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
    $['audioContainer'].setInnerHtml(html, treeSanitizer : new NullTreeSanitizer());
  }
  

  
  bool get applyAuthorStyles => true;
  
  
}


/**
 * Sanitizer which does nothing.
 */
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}
