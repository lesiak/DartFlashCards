import 'package:polymer/polymer.dart';

import 'dart:html';

import 'package:FlashCardsNew/filecache_api.dart';
import 'package:FlashCardsNew/flashcards_core.dart';
import 'package:FlashCardsNew/forvo_api.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('flashcards-app')
class FlashCardsApp extends PolymerElement {
    
  Engine engine;
  
  @observable List<Card> cards = toObservable([]);
  
  List<String> level1Files = ['Begginer1',
                     'Begginer2',
                     'Begginer3',
                     'Begginer4',
                     'Begginer5',
                     'Begginer6',
                     'Sport',
                     'Home',
                     'City',
                     'Travel',
                     'Holiday',
                     'Clothes',
                     'Food',
                     'Animals',
                     'People',
                     'Body',
                     'Emotions',
                     'Health',
                     'Colors'];
  
  List<String> level2Files = ['Work',
                              'School',
                              'Computers',
                              'Begginer7',
                              'Begginer8',
                              'Begginer9',
                              'Mythology',
                              'Professions',
                              'Military',
                              'Countries',
                              'Plants',
                              'Calendar',
                              'Tools',
                              'MoneyInter',
                              'Sentences1',
                              'TopikInter1']; 
  
  static List<String> langs = ["ko", "fi"];
  
  static Map<String, String> flagsPaths = {"ko": "assets/svgFlags/Flag_of_Republic_of_Korea.svg", 
                                      "fi": "assets/svgFlags/Flag_of_Finland_1920-1978_(State).svg"};
  
  @observable List<String> items;
  
  @observable String primaryLang;
  
  @observable String flagPath;
  
  @observable int total;
  
  @observable int currentSucc;
  
  @observable int currentFail;
  
  @observable bool showProgress = false;
  
  PronounciationManager pronounciationManager;
  
  FlashCardsApp.created() : super.created() {
    print('created app');
    items = level1Files;
    this.engine = new Engine();
    
    FileCache fileCache = new FileCache( (cache) {
      //FlashCardsApp app = new FlashCardsApp(cache);
      //app.startApplication();
      this.pronounciationManager = new PronounciationManager(cache, null);
    });
    var langInStore =window.localStorage['primaryLang'];
    primaryLang = langInStore != null ? langInStore : 'ko';

  }
  
  @override
  void enteredView() {
    super.enteredView();

    print('enteredView app');
//    loadWordTable( "Begginer1.json");     
   // fillQuestionDecksTable(level1Files);
    //onVisibilityChan
  }
  
  
 
 
  
  void deckNameChanged1(Event e, var deckName, Node target) { 
    loadWordTable(deckName+".json");
  }
  
  void loadWordTable(String wordfile) {
    print('loading $wordfile');
    $["deckDetailsDiv"].hidden=false;
    engine.loadData('../wordfiles/$wordfile', () {
      print('data loaded');
      
     // query("#deckDetailsDiv").hidden=false;
      showDeckData();
    }  
    );
  }
  
  void showDeckData() {
    //cards = toObservable(engine.allCardsInDeck);
    print("AAAAAAAAAAAAAAAAAAAAAAAAA");
   // cards.replaceRange(0, cards.length, engine.allCardsInDeck);
    cards = toObservable(engine.allCardsInDeck);
   // wordsTable.fillWordsTable(engine.allCardsInDeck);
   // fillSummary();
  }
  
  void clearDeckResults() {
    engine.clearDeckResults(primaryLang);
    showDeckData();
  }
  
  void startPanel() {
    //ui.showLearningPanel();
    //showCurrentQuestion();
        
    showLearningPanel();    
   // showCurrentQuestion();
  }
  
  void showLearningPanel() {
    $['wordFilesDiv'].hidden = true;    
    var learningPanel = $['learningPanel'];    
    learningPanel.hidden = false;
    learningPanel.startPanel(); 
  }

  void showHomePanel() {
    $['wordFilesDiv'].hidden = false;
    $['learningPanel'].hidden = true;
    $['dictionaryPanel'].hidden = true;
  //  showLearningPanel1 = false;
    //query("#wordFilesDiv").hidden=false;
   // query("#learningPanel").hidden=true;
   // query("#deckDetailsDiv").hidden=false;
    
  }
  
  void showDictionary() {
    print('show dictionarty');
    $['wordFilesDiv'].hidden = true;
    $['dictionaryPanel'].hidden = false;
  }
  
 // void showCurrentQuestion() {
   // Card card = engine.currentCard;
    //ui.showQuestion(card);    
 // }
  
  void fetchPronunciations() {
    initProgress(engine.allCardsInDeck.length * 4);
  //  downloaderUI.initProgress(engine.allCardsInDeck.length * 4);    
    for (Card card in engine.allCardsInDeck) {
      pronounciationManager.fetchMissingPronunciations("en", ForvoRequestUtils.sanitizeWord("en", card.en), step);      
      pronounciationManager.fetchMissingPronunciations("ko", ForvoRequestUtils.sanitizeWord("ko", card.ko), step);  
      pronounciationManager.fetchMissingPronunciations("fi", ForvoRequestUtils.sanitizeWord("fi", card.fi), step);
      pronounciationManager.fetchMissingPronunciations("fr", ForvoRequestUtils.sanitizeWord("fr", card.fr), step);
    }
    
  }
  
  void initProgress(int pTotal) {
    this.total = pTotal;
    currentSucc = 0; 
    currentFail = 0;
    showProgress = true; 
    //Observable.dirtyCheck();
  }
  
  void step(bool success) {
    
      if (success) {
        currentSucc = currentSucc + 1;
        /*scheduleMicrotask(() {
         
          });*/
              
      } else {
        currentFail = currentFail + 1;
        /*scheduleMicrotask(() {
          
          });*/
              
      }                
      
      if ((currentSucc + currentFail) == total) {
        showProgress = false;
      }  
    
        
  }
  
  void step1() {
    
  }
 
  
  void goToHomePanel() {
    print('show home');
   // engine.initLearningList();
   // ui.showHomePanel();
    showHomePanel();
    
    //to enforce update event in word table
    cards.clear();
    showDeckData();
    
  //  showDeckData();
  }
  
  void level1Clicked(Event e, var detail, Element target) {
    items = level1Files;
    $['level2Tab'].parent.classes.remove('active');
    $['level1Tab'].parent.classes.add('active');
  }
  
  void level2Clicked(Event e, var detail, Element target) {
    items = level2Files;
    $['level1Tab'].parent.classes.remove('active');
    $['level2Tab'].parent.classes.add('active');
  }
 
  void flagClicked(Event e, var detail, Element target) {
    var idx = langs.indexOf(primaryLang);
    if (idx == langs.length - 1) {
      primaryLang = langs[0];      
    } else {
      primaryLang = langs[idx+1];
    }
    window.localStorage['primaryLang'] = primaryLang;
  }
  
  void primaryLangChanged() {
    flagPath = flagsPaths[primaryLang];   
  }
  
 
  
  
 
  
  List<String> get allDeckNames {
    var deckNames = new List();
    deckNames.addAll(level1Files);
    deckNames.addAll(level2Files);
    return deckNames;
  }
  
  
// This lets the Bootstrap CSS "bleed through" into the Shadow DOM
  // of this element.
  bool get applyAuthorStyles => true;
}

