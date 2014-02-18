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
                     'CultureBegginer',
                     'Home',
                     'City',
                     'Sport',
                     'Travel',
                     'Holiday',
                     'Clothes',
                     'Food',
                     'Fruits',
                     'Animals',
                     'People',
                     'Body',
                     'Emotions',
                     'Health',
                     'Colors'];
  
  List<String> level2Files = ['NatureIntermediate',
                              'Work',
                              'School',
                              'Computers',
                              'Begginer7',
                              'Begginer8',
                              'Begginer9',
                              'Mythology',
                              'Professions',
                              'Containers',
                              'Military',
                              'Countries',
                              'Plants',
                              'Calendar',
                              'Tools',
                              'Cooking',
                              'Politics',
                              'Money',
                              'Substances',
                              'Intermediate1',
                              'Sentences1',
                              'TopikInter1']; 
  
  static List<String> langs = ["ko", "fi", "hu"];
  
  static List<String> all_langs = ["en", "ko", "fi", "fr", "hu", "zh"];
  
  static Map<String, String> flagsPaths = {"ko": "resources/svgFlags/Flag_of_Republic_of_Korea.svg", 
                                      "fi": "resources/svgFlags/Flag_of_Finland_1920-1978_(State).svg",
                                      "hu": "resources/svgFlags/Civil_Ensign_of_Hungary.svg",
                                      "zh": "resources/svgFlags/Flag_of_the_People's_Republic_of_China.svg"};
  
  @observable List<String> items;
  
  @observable String primaryLang;
  
  @observable String secondaryLang = "fi";
  
  @observable String thirdLang ="fr";
  
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
    if (engine.allCardsInDeck != null) {
      cards = toObservable(engine.allCardsInDeck);
    } else {
      print("No cards loaded");
    }
    
    
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
    $['welcomePageDiv'].hidden = true;    
    var learningPanel = $['learningPanel'];    
    learningPanel.hidden = false;
    learningPanel.startPanel(); 
  }

  void showHomePanel() {
    $['welcomePageDiv'].hidden = false;
    $['learningPanel'].hidden = true;
    $['dictionaryPanel'].hidden = true;
  
  }
  
  void showDictionary() {    
    $['welcomePageDiv'].hidden = true;
    $['learningPanel'].hidden = true;
    $['dictionaryPanel'].hidden = false;
  }
  
 // void showCurrentQuestion() {
   // Card card = engine.currentCard;
    //ui.showQuestion(card);    
 // }
  
  void fetchPronunciations() {
    initProgress(engine.allCardsInDeck.length * all_langs.length);    
    for (Card card in engine.allCardsInDeck) {
      for (String lang in all_langs) {
        pronounciationManager.fetchMissingPronunciations(lang, ForvoRequestUtils.sanitizeWord(lang, card.getValueForLang(lang)), step);        
      }                  
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
    primaryLang = langs[(idx + 1) % langs.length];          
    secondaryLang = langs[(idx + 2) % langs.length];
    thirdLang = langs[(idx + 3) % langs.length];
    window.localStorage['primaryLang'] = primaryLang;
  }
  
  void primaryLangChanged() {
    flagPath = flagsPaths[primaryLang];   
  }
  
  
  void showOptions() {        
    $['optionsDialogFramePart'].style.transform= "translate(300%, 0)";
    $['optionsBacksplashPart'].style.display= "block";
    $['optionsBacksplashPart'].style.opacity= "0.25";      
  }
  
  void hideOptions() {
    $['optionsDialogFramePart'].style.transform= "translate(400%, 0)";
    $['optionsBacksplashPart'].style.display= "none";
    $['optionsBacksplashPart'].style.opacity= "1";
  }
  
  void updateOptions() {
    var option1Element = $['optionsRadios1'];
    var option2Element = $['optionsRadios2'];
    var option3Element = $['optionsRadios3'];    
    if (option1Element.checked) {
      langs = ["fi","ko","fr"];       
    } else if (option2Element.checked) {
      langs = ["ko","fi","hu"];      
    } else {
      langs = ["fi","ko","zh"];      
    }
    primaryLang = langs[0];
    secondaryLang = langs[1];
    thirdLang = langs[2];
    
    
    hideOptions();
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

