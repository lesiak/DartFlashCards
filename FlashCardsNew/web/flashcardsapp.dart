import 'package:polymer/polymer.dart';

import 'dart:html';
import 'dart:async';

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
                              'MoneyInter',
                              'Sentences1',
                              'TopikInter1'];  
  
  @observable List<String> items;
  
  @observable String primaryLang = "fi";
  
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
    engine.clearDeckResults();
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
    var z = $['learningPanel'].xtag;
   $['learningPanel'].hidden = false;
  //  showLearningPanel1 = true;
    //var x = z.sasa();
   z.startPanel();
   
  }

  void showHomePanel() {
    $['wordFilesDiv'].hidden = false;
    $['learningPanel'].hidden = true;
  //  showLearningPanel1 = false;
    //query("#wordFilesDiv").hidden=false;
   // query("#learningPanel").hidden=true;
   // query("#deckDetailsDiv").hidden=false;
    
  }
  
 // void showCurrentQuestion() {
   // Card card = engine.currentCard;
    //ui.showQuestion(card);    
 // }
  
  void fetchPronunciations() {
    initProgress(engine.allCardsInDeck.length * 4);
  //  downloaderUI.initProgress(engine.allCardsInDeck.length * 4);    
    for (Card card in engine.allCardsInDeck) {
      pronounciationManager.fetchMissingPronunciations("en", sanitizeWord("en", card.en), step);      
      pronounciationManager.fetchMissingPronunciations("ko", sanitizeWord("ko", card.ko), step);  
      pronounciationManager.fetchMissingPronunciations("fi", sanitizeWord("fi", card.fi), step);
      pronounciationManager.fetchMissingPronunciations("fr", sanitizeWord("fr", card.fr), step);
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
  
  RegExp IN_PARENTHESES = new RegExp("\\(.+?\\)");
  
  String sanitizeWord(String lang, String word) {
    if (word.contains(IN_PARENTHESES)) {
      word = word.replaceAll(IN_PARENTHESES, "");
    }
    if (word.contains(',')) {
      word = word.split(',')[0];
    }
    if (lang == "en") {
      if (word.startsWith("to ")) {
        word = word.substring(3);
      }
      else if (word.startsWith("a ")) {
        word = word.substring(2);
      }
    }
    return word.trim();
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
  
  
  
// This lets the Bootstrap CSS "bleed through" into the Shadow DOM
  // of this element.
  bool get applyAuthorStyles => true;
}

