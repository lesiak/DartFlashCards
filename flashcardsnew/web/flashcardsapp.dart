import 'package:polymer/polymer.dart';

import 'dart:html';
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
  
  @observable List<Card> learningList = toObservable([]);
  
  @observable List<Card> notInLearningList = toObservable([]);
  
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
                     'Beginner5',
                     'Beginner6',
                     'CultureBegginer',                     
                     'CultureMusic',
                     'Sport',
                     'Transport',
                     'Holiday',
                     'Shops',
                     'Clothes',
                     'Food',
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
  
  static List<String> all_langs = ["en", "ko", "fi", "fr", "hu", "es"];
  
  static Map<String, String> flagsPaths = {"ko": "resources/svgFlags/Flag_of_Republic_of_Korea.svg", 
                                      "fi": "resources/svgFlags/Flag_of_Finland_1920-1978_(State).svg",
                                      "hu": "resources/svgFlags/Civil_Ensign_of_Hungary.svg",
                                      "fr": "resources/svgFlags/Flag_of_France.svg",
                                      "es": "resources/svgFlags/Flag_of_Spain.svg"};
  
  @observable List<String> items;
  
  @observable String primaryLang;
    
  //TODO: find out why initializing this variable breaks the app in 0.10.0+1, but not in 0.9.5
  @observable String secondaryLang;
  
  @observable String thirdLang;
  
  @observable String flagPath;
  
  @observable int total;
  
  @observable int currentSucc;
  
  @observable int currentFail;
  
  @observable bool showProgress = false;  
  
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
  
  
 
 
  
  void deckNameChanged1(Event e, var deckName, Node target) { 
    loadWordTable(deckName+".json");
  }
  
  void loadWordTable(String wordfile) {
    print('loading $wordfile');
    $["deckDetailsDiv"].hidden=false;
    engine.loadData('wordfiles/$wordfile', () {
      print('data loaded');
      
     // query("#deckDetailsDiv").hidden=false;
      showDeckData();
    }  
    );
  }
  
  void showDeckData() {
    //cards = toObservable(engine.allCardsInDeck);    
   // cards.replaceRange(0, cards.length, engine.allCardsInDeck);
    if (engine.allCardsInDeck != null) {
      cards = toObservable(engine.allCardsInDeck);
     // learningList = toObservable(DeckEngine.buildLearningList(cards, primaryLang));
     Iterable<List<Card>> matchedUnmatched = DeckEngine.partitionCards(cards, primaryLang);
     learningList = toObservable(matchedUnmatched.first);
     notInLearningList = toObservable(matchedUnmatched.last);
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
        pronounciationManager.fetchMissingPronunciations(lang, CardUtils.sanitizeWord(lang, card.getValueForLang(lang)), step);        
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
    var optionsRadiosFiKoEs = $['optionsRadiosFiKoEs'];    
    var optionsRadiosFiEsFr = $['optionsRadiosFiEsFr'];
    if (option1Element.checked) {
      langs = ["fi","ko","fr"];       
    } else if (option2Element.checked) {
      langs = ["ko","fi","hu"];      
    } else if (optionsRadiosFiKoEs.checked ){
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

