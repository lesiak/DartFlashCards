import 'package:polymer/polymer.dart';

import 'dart:html';
import 'dart:async';
import 'dart:convert' show JSON;

import 'package:flashcardsnew/filecache_api.dart';
import 'package:flashcardsnew/flashcards_core.dart';
import 'package:flashcardsnew/forvo_api.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('flashcards-app')
class FlashCardsApp extends PolymerElement {
    
  Engine engine;
  
  @observable List<Card> cards = toObservable([]);
  
  @observable List<CardWithScore> learningList = toObservable([]);
  
  @observable List<CardWithScore> notInLearningList = toObservable([]);
  
  List<String> level1Files = ['Beginner1',
                     'Home',
                     'City',
                     'AppearanceBeginner',
                     'AppearancePeople',
                     'Beginner2',
                     'Beginner3',
                     'Beginner3aTimeExpressions',
                     'Beginner3bCommunication',                     
                     'Beginner4',
                     'Beginner4aDescriptions',
                     'Beginner5AbstractDescriptions',
                     'Beginner6',
                     'CultureBegginer',                     
                     'CultureMusic',
                     'Sport',
                     'Transport',
                     'Holiday',
                     'Shops',
                     'Clothes',
                     'Food',
                     'FoodEating',
                     'Fruits',
                     'Vegetables',
                     'Animals',
                     'People',
                     'Body',
                     'Emotions',
                     'Character',
                     'Health',
                     'Colors'];
  
  List<String> level2Files = ['NatureIntermediate',
                              'Work',
                              'School',
                              'Computers',
                              'Professions',
                              'FreeTime',
                              'Beginner7',
                              'Beginner8',
                              'Beginner9',
                              'Beginner9Speaking',
                              'Beginner10OtherObjects',
                              'Mythology',
                              'Law',
                              'Containers',
                              'Military',
                              'HouseWork',
                              'Countries',
                              'Plants',
                              'Farm',
                              'Calendar',
                              'Tools',
                              'Cooking',
                              'Politics',
                              'Money',
                              'Substances',
                              'Intermediate1',
                              'Sentences1',
                              'TopikInter1']; 
  
  static List<String> langs = ["ko", "fi", "es"];
  
  static List<String> all_langs = ["en", "ko", "fi", "fr", "hu", "es", "da"];
  
  @observable List<String> items;
  
  @observable String primaryLang;
    
  //TODO: find out why initializing this variable breaks the app in 0.10.0+1, but not in 0.9.5
  @observable String secondaryLang;
  
  @observable String thirdLang;
    
  @observable FileCache fileCache;
  
  PronounciationManager pronounciationManager;                                    
  
  FlashCardsApp.created() : super.created() {
    print('created app');
    items = level1Files;
    this.engine = new Engine();
    
    this.fileCache = new FileCache(all_langs, (cache) {
      //FlashCardsApp app = new FlashCardsApp(cache);
      //app.startApplication();
      this.pronounciationManager = new PronounciationManager(cache, null);
    });
    initLangsFromLocalStorage();      
  }
  
  void initLangsFromLocalStorage() {
    var langInStore = window.localStorage['primaryLang'];
    var langsInStoreJSON = window.localStorage['langs'];
    if (langsInStoreJSON != null) {
      List<String> langsInStore = JSON.decode(langsInStoreJSON);
      langs = langsInStore;
    }
    
    var idx = 0;
    if (langInStore != null) {
      idx = langs.indexOf(langInStore);
      if (idx == -1) {
        idx = 0;
      }
    }
    primaryLang = langs[idx];
    secondaryLang = langs[(idx + 1) % langs.length];    
    thirdLang = langs[(idx + 2) % langs.length];  
  }
  
  @override
  void attached() {   
    print('attached app');
//    loadWordTable( "Begginer1.json");     
   // fillQuestionDecksTable(level1Files);
    //onVisibilityChan
  }
  
  
  void deckNameChangeHandler(Event e, var deckName, Node target) { 
    loadWordTable(deckName+".json");
  }
  
  void loadWordTable(String wordfile) {
    print('loading $wordfile');
    $["deckDetailsDiv"].hidden=false;
    engine.loadData('wordfiles/$wordfile').then((allCards) {
      print('data loaded');
      
     // query("#deckDetailsDiv").hidden=false;
      showDeckData();
    });
  }
  
  void showDeckData() {
    //cards = toObservable(engine.allCardsInDeck);    
   // cards.replaceRange(0, cards.length, engine.allCardsInDeck);
    if (engine.allCardsInDeck != null) {
      new Future(() {
        cards = toObservable(engine.allCardsInDeck);
        List<CardWithScore> cardsWithScores = DeckEngine.mapCardsAddScores(cards, primaryLang);
        return cardsWithScores;
      }).then((cardsWithScores) {
        Iterable<List<CardWithScore>> matchedUnmatched = DeckEngine.partitionCards(cardsWithScores);
        learningList = toObservable(matchedUnmatched.first);
        notInLearningList = toObservable(matchedUnmatched.last);
      });
      
     // learningList = toObservable(DeckEngine.buildLearningList(cards, primaryLang));
     
     
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
    showLearningPanel();
  }
  
  void showLearningPanel() {       
    var learningPanel = $['learningPanel'];        
    learningPanel.startPanel();
    $['dicPages'].selected = 2;
  }

  void showHomePanel() {
    $['dicPages'].selected = 0;
  
  }
  
  void showDictionary() {    
    $['dicPages'].selected = 1;
  }
  
  void fetchPronunciations() {
    var pronoDownloadPanel = $['pronoDownloadPanel'];       
    pronoDownloadPanel.fetchPronunciations(pronounciationManager, engine.allCardsInDeck, all_langs);
  }
  
  void goToHomePanel() {
    print('show home');
    showHomePanel();
    
    //to enforce update event in word table
    cards.clear();
    showDeckData();
    
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
    showDeckData();
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
    var optionsLangs = $['optionsLangs'];
    var selectedLangs = optionsLangs.selected;
    if (selectedLangs == 'optionsRadiosFiDaEs') {
      langs = ["fi","da","es"];       
    } else if (selectedLangs == 'optionsRadios2') {
      langs = ["ko","fi","hu"];      
    } else if (selectedLangs == 'optionsRadiosFiKoEs'){
      langs = ["fi","ko","es"];      
    } else {
      langs = ["fi","es","fr"];
    }
    
    primaryLang = langs[0];
    secondaryLang = langs[1];
    thirdLang = langs[2];
    window.localStorage['langs'] = JSON.encode(langs);
    window.localStorage['primaryLang'] = primaryLang;
   
    
    hideOptions();
  }
 
  
  List<String> get allDeckNames {
    var deckNames = new List();
    deckNames.addAll(level1Files);
    deckNames.addAll(level2Files);
    return deckNames;
  }
  
}

