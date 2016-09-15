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
  
  List<String> level1Files = [
                     'Level1/NatureBeginner',
                     'Level1/City',
                     'Level1/Transport',
                     'Level1/Home',
                     'Level1/Shops',
                     'Level1/AppearanceBeginner',
                     'Level1/AppearancePeople',
                     'Level1/Beginner2',
                     'Level1/Beginner3',
                     'Level1/Beginner3aTimeExpressions',
                     'Level1/Beginner3bCommunication',
                     'Level1/Beginner4',
                     'Level1/Beginner4aDescriptions',
                     'Level1/Beginner5AbstractDescriptions',
                     'Level1/Beginner5Quantities',
                     'Level1/Beginner6',
                     'Level1/CultureBegginer',
                     'Level1/Sport',
                     'Level1/Holiday',
                     'Level1/Clothes',
                     'Level1/Food',
                     'Level1/FoodEating',
                     'Level1/Fruits',
                     'Level1/Vegetables',
                     'Level1/Animals',
                     'Level1/People',
                     'Level1/BodyBeginner',
                     'Level1/Emotions',
                     'Level1/Character',
                     'Level1/Health',
                     'Level1/Colors'];
  
  List<String> level2Files = ['Level2/NatureIntermediate',
                              'Level2/Work',
                              'Level2/School',
                              'Level2/SchoolSubjects',
                              'Level2/Computers',
                              'Level2/Professions',
                              'Level2/Bathroom',
                              'Level2/FreeTime',
                              'Level2/Beginner7',
                              'Level2/Beginner8',
                              'Level2/Beginner9',
                              'Level2/Beginner9Speaking',
                              'Level2/Beginner10OtherObjects',
                              'Level2/Driving',
                              'Level2/Architecture',
                              'Level2/CultureMusic',
                              'Level2/BodyIntermediate',
                              'Level2/Religion',
                              'Level2/Mythology',
                              'Level2/Economy',
                              'Level2/Law',
                              'Level2/Containers',
                              'Level2/Military',
                              'Level2/HouseWork',
                              'Level2/Countries',
                              'Level2/LocationInSpace',
                              'Level2/Plants',
                              'Level2/Farm',
                              'Level2/Calendar',
                              'Level2/Tools',
                              'Level2/Cooking',
                              'Level2/Money',
                              'Level2/Substances',
                              'Level2/Intermediate1',
                              'Level2/Sentences1',
                              'Level2/TopikInter1'];

  List<String> level3Files = ['Level3/New2016',
                              'Level3/Politics'];
  
  static List<String> langs = ["fi", "es", "de", "ko", "fr", "it", "hu"];
  
  static List<String> all_langs = ["en", "fi", "es", "de", "ko", "fr", "it", "hu"];
  
  @observable List<String> items;
  
  @observable String primaryLang;

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
    /*var langsInStoreJSON = window.localStorage['langs'];
    if (langsInStoreJSON != null) {
      List<String> langsInStore = JSON.decode(langsInStoreJSON);
      langs = langsInStore;
    }
    */
    var idx = 0;
    if (langInStore != null) {
      idx = langs.indexOf(langInStore);
      if (idx == -1) {
        idx = 0;
      }
    }
    primaryLang = langs[idx];
    /*secondaryLang = langs[(idx + 1) % langs.length];
    thirdLang = langs[(idx + 2) % langs.length];*/
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
    $['level3Tab'].parent.classes.remove('active');
    $['level1Tab'].parent.classes.add('active');
  }
  
  void level2Clicked(Event e, var detail, Element target) {
    items = level2Files;
    $['level1Tab'].parent.classes.remove('active');
    $['level3Tab'].parent.classes.remove('active');
    $['level2Tab'].parent.classes.add('active');
  }

  void level3Clicked(Event e, var detail, Element target) {
    items = level3Files;
    $['level1Tab'].parent.classes.remove('active');
    $['level2Tab'].parent.classes.remove('active');
    $['level3Tab'].parent.classes.add('active');
  }
 
  void flagClicked(Event e, var detail, Element target) {
    var idx = langs.indexOf(primaryLang);       
    primaryLang = langs[(idx + 1) % langs.length];
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
    /*var optionsLangs = $['optionsPanel'];
    var selectedLangs = optionsLangs.selectedOption;
    if (selectedLangs == 'optionsRadiosKoFiHu') {
      langs = ["ko","fi","hu"];      
    } else if (selectedLangs == 'optionsRadiosEsItFr'){
      langs = ["es","it","fr"];      
    } else if (selectedLangs == 'optionsRadiosFiKoEs') {
      langs = ["fi","ko","es"];
    } else {
      langs = ["es","de","fi"];
    }
    
    primaryLang = langs[0];
    secondaryLang = langs[1];
    thirdLang = langs[2];
    window.localStorage['langs'] = JSON.encode(langs);
    window.localStorage['primaryLang'] = primaryLang;
   */
    
    hideOptions();
  }
 
  
  List<String> get allDeckNames {
    var deckNames = new List();
    deckNames.addAll(level1Files);
    deckNames.addAll(level2Files);
    deckNames.addAll(level3Files);
    return deckNames;
  }
  
}

