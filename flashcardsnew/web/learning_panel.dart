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

  @observable Card card = new Card.empty();

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
  }

  String get answerPrimary {
    return card.getValueForLang(primaryLang);
  }

  void displayPronunciations(String lang, String word, String wordEn, String containerId, bool play) {
    if (word == null) {
      return;
    }
    word = CardUtils.sanitizeWordEntry(lang, word);
    Element container = $[containerId];
    //String cachedForvoResponse = window.localStorage[lang+"/"+word];
    pronounciationManager.getForvoResponseFromFileSystem(lang, word)
      .then((String cachedForvoResp) {
      print('found $word pronounciation list in fileSystem');
      try {
        ForvoResponse r = new ForvoResponse.fromJsonString(lang, word, cachedForvoResp);
        displayPronounciationsFromForvoResponse(r, container, play);
      } catch(e) {
        print("BBBBB ${e}");
        window.alert("Unexpected exception");
      }
    }, onError: (e) {
      print('Fetching sound: $word');
       //String resp = 'TEST_RESP';
       //onForvoSuccessTest(resp, lang, word, container, play);

       pronounciationManager.getForvoPronunciations(lang, word)
         .then((req) => onForvoSuccess(req, lang, word, wordEn, container, play))
         .catchError((e) {
           print("EEE Could not fetch pronunciation ${e}");
         });
    });
    /*else {
      // call the web server asynchronously
      print('Fetching sound: $word');
            
      
      // String resp = 'TEST_RESP';       
     // onForvoSuccessTest(resp, lang, word, container, play);
      
      pronounciationManager.getForvoPronunciations(lang, word)          
        .then((req) => onForvoSuccess(req, lang, word, wordEn, container, play))
        .catchError((e) {          
          print("EEE Could not fetch pronunciation ${e}");           
        });
              
    } */
  }

  void onForvoSuccessTest(String  responseText, String lang, String word, Element container, bool play) {
    print(responseText);
    if (!responseText.isEmpty) {
      ForvoResponse r = new ForvoResponse.fromJsonString(
          lang, word, responseText);
      displayPronounciationsFromForvoResponse(r, container, play);
    }
  }

  /*void showTestProno() {
    Element container = $['enPro'];
    ForvoItem testItem = new ForvoItem({});
    testItem.username = "sasa";
    
    $['enPro'].nodes.add(createAudioNode("la", "word", testItem));           
    $['primaryPro'].nodes.add(createAudioNode("la", "word", testItem));
   }
  
  void hideTestProno() {
    
    clearQuestionPronunciations();
    clearAnswerPronunciations();
   }*/

  void onForvoSuccess(HttpRequest req, String lang, String word, String wordEn, Element container, bool play) {
    String responseText = req.responseText;
    if (responseText.isEmpty) {
      return;
    }
    if (card.en != wordEn) {
      return;
    }
    //print("DDDDDD " + responseText);
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
      DivElement div = createAudioNode(r.lang, r.word, item);
      ret.add(div);
    }
    return ret;
  }

  DivElement createAudioNode(String lang, String word, ForvoItem item) {
    DivElement div = new DivElement();
    div.classes.add('btn-group');
    ButtonElement button = new ButtonElement();
    button.text = item.username;
    button.classes.addAll(["btn", "btn-default"]);
    button.attributes['rel'] = 'tooltip';
    button.attributes['title'] = '${item.sex} ${item.country}';
    button.onClick.listen((e)  => pronounciationManager.playPronounciation(lang, word, item));
    div.nodes.add(button);
    return div;
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
