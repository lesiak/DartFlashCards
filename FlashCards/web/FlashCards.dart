import 'dart:html';
import '../lib/flashcards_core.dart';
import '../lib/filecache_api.dart';
//TODO: remove async and forvo_api to test whrn pub works
import 'dart:async';
import '../lib/forvo_api.dart';
import 'FlashCardsUI.dart';

class FlashCardsApp {
  
  Engine engine;
  FlashCardsUI ui;
  
  List<String> level1Files = ['Begginer1',
                     'Begginer2',
                     'Begginer3',
                     'Begginer4',
                     'Begginer5',
                     'Begginer6',
                     'Home',
                     'City',
                     'Travel',
                     'Clothes',
                     'Food',
                     'Animals',
                     'People',
                     'Body',
                     'Health',
                     'People',
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
                              'Sentences1',
                              'TopikInter1'];  
  
  FlashCardsApp(FileCache fileCache) {
        
    this.engine = new Engine();    
    this.ui = new FlashCardsUI(engine, fileCache);
    
    query("#showAnswerButton").onClick.listen((e) => showAnswer());    
    query("#goodAnswerButton").onClick.listen((e) => goodAnswer());
    query("#poorAnswerButton").onClick.listen((e) => poorAnswer());
    query("#badAnswerButton").onClick.listen((e) => badAnswer());
    
  //  query("#clearCache").onClick.listen((e) => window.localStorage.clear());
        
    query("#startButton").onClick.listen((e) {
      ui.showLearningPanel();
      showQuestion(); 
    });
    
    query("#clearResultsButton").onClick.listen((e) => clearDeckResults());
    
    query("#fetchPronoButton").onClick.listen((e) => fetchPronunciations());
        
    query("#homePill").onClick.listen((e) {
      engine.initLearningList();
      ui.showHomePanel();
      fillDeckData();
    });
    
    Element level1Tab = query("#level1Tab");
    Element level2Tab = query("#level2Tab");
    
    level1Tab.onClick.listen((e) {
      level2Tab.parent.classes.remove('active');
      level1Tab.parent.classes.add('active');
      fillQuestionDecksTable(level1Files);
    });
    level2Tab.onClick.listen((e) {
      level1Tab.parent.classes.remove('active');
      level2Tab.parent.classes.add('active');
      fillQuestionDecksTable(level2Files);
    });
  }
  
  void startApplication() {    
    fillQuestionDecksTable(level1Files);
  }
  
  void fillQuestionDecksTable(List<String> wordFiles) {
    TableElement table = query("#questionDecksTable");
    TableSectionElement tBody = table.tBodies[0]; 
    tBody.nodes.clear();
    for (String deckName in wordFiles) {
      TableRowElement tRow = tBody.insertRow(-1); // add at the end
                         
        Element cell = tRow.insertCell(-1);
        cell.classes.add('deckLink');
        AnchorElement deckLink = new AnchorElement(href: "#");
        deckLink.text = deckName;
        deckLink.onClick.listen((e) {
          
          tBody.children.forEach((aRow) => aRow.classes.remove('selectedTableRow'));
          tRow.classes.add('selectedTableRow');
          loadWordTable( "${deckName}.json");        
        });
        cell.nodes.add(deckLink);
    }
    /*for (List<String> rowDeckNames in invertList(wordFiles)) {
      TableRowElement tRow = tBody.insertRow(-1); // add at the end
      for (String deckName in rowDeckNames) {                   
        Element cell = tRow.insertCell(-1);
        cell.classes.add('deckLink');
        AnchorElement deckLink = new AnchorElement(href: "#");
        deckLink.text = deckName;
        deckLink.onClick.listen((e) {
          
          tBody.children.forEach((aRow) => aRow.classes.remove('selectedTableRow'));
          tRow.classes.add('selectedTableRow');
          loadWordTable( "${deckName}.json");        
        });
        cell.nodes.add(deckLink);
      }
    }*/
  }
  
  List<List<String>> invertList(List<String> list) {
    int sIndex = list.length~/2;
    int lastIndex = list.length;
    print(sIndex);
    print(lastIndex);
    List<String> list1 = list.getRange(0,sIndex);
    List<String> list2 = list.getRange(sIndex,lastIndex-sIndex);
    List<String> ret = new List<String>();
  
   return zip(list1, list2);
  }
   
  static List<List<String>> zip(List<String> list1, List<String> list2) {
    List<List<String>> zipped = new List<List<String>>();
    for (List<String> list in [list1, list2]) {
        for (int i = 0, listSize = list.length; i < listSize; i++) {
            List<String> list2;
            if (i >= zipped.length) {
                zipped.add(list2 = new List<String>());
            }
            else {
                list2 = zipped[i];
            }
            list2.add(list[i]);
        }
    }
    return zipped;
}
  // while(it1.moveNext()) 
  //}
  
  void _createDeckCell(String deckName) {
    
  }
  
  
  
  
  

  void loadWordTable(String wordfile) {
    engine.loadData('wordfiles/$wordfile', () { 
      query("#deckDetailsDiv").hidden=false;
      fillDeckData();
    }  
    );
  }
  
  void fillDeckData() {
    fillWordsTable();
    fillSummary();
  }
  
  void clearDeckResults() {
    engine.clearDeckResults();
    fillDeckData();
  }
  
  void fetchPronunciations() {            
    for (Card card in engine.allCardsInDeck) {
      ui.pronounciationManager.fetchMissingPronunciations("en", ui.sanitizeWord("en", card.en));
      ui.pronounciationManager.fetchMissingPronunciations("ko", ui.sanitizeWord("ko", card.ko));  
      ui.pronounciationManager.fetchMissingPronunciations("fi", ui.sanitizeWord("fi", card.fi));
      ui.pronounciationManager.fetchMissingPronunciations("fr", ui.sanitizeWord("fr", card.fr));
    }
  }
  
  void fillSummary() {
    var deckSize = engine.deckSize;
    var completedSize = engine.completedSize;
    query("#totalWords").text = "${deckSize}";
    query("#completedWords").text = "${completedSize}";
    query("#dueTodayWords").text = "${engine.dueSize}";
    
    int progress = ((completedSize/deckSize) * 100).toInt();
    query("#deckProgress").text = "${progress}%";
  }
  
  void fillWordsTable() {
    var currentDate = new DateTime.now();
    TableElement table = query("#wordTable");
    TableSectionElement tBody = table.tBodies[0]; 
    tBody.nodes.clear();
    for (Card card in engine.allCardsInDeck) {
      CardScore score = ResultStore.getCardScoreFromStore(card);
      TableRowElement newLine = tBody.insertRow(-1); // add at the end
      
      String dueIn = "";
      if (score != null) {
        if (score.isGoodAnswer() && !engine.isInLearningList(score)) {
          newLine.classes.add("succ");
        }
        else if (score.isGoodAnswer() && engine.isInLearningList(score)) {
          newLine.classes.add("succInList");
        }
        else if (score.isPoorAnswer()) {
          newLine.classes.add("almost");
        }
        else if (score.isBadAnswer()) {
          newLine.classes.add("error");
        }
        
        dueIn = formatDuration(score.getDueInDuration(currentDate));
      }
      
      newLine.insertCell(0).text = card.en;
      newLine.insertCell(1).text = card.ko;
      newLine.insertCell(2).text = card.fi;
      newLine.insertCell(3).text = card.fr;
      newLine.insertCell(4).text = dueIn;
    }
  }
  
  String formatDuration (Duration d) {    
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    if (d.inMilliseconds < 0) {
     /* Duration duration =
          new Duration(milliseconds: -d.inMilliseconds);
      return "-$duration";
      */
      return "now";
    }
    var days = d.inDays;
    var hours = d.inHours.remainder(Duration.HOURS_PER_DAY);
    String twoDigitMinutes =
        twoDigits(d.inMinutes.remainder(Duration.MINUTES_PER_HOUR));       
    if (days == 0) {
      return "${d.inHours} hours ${twoDigitMinutes} min";
    }
    else {
      return "${days} days ${hours} hours";
    }
  }
  
  


  void loadWords(String wordfile) {
    engine.loadData('wordfiles/$wordfile', () { 
      query("#wordFilesDiv").hidden=true;
      query("#learningPanel").hidden=false;
      showQuestion(); 
    });
  }



  void showAnswer() {
    Card card = engine.currentCard;
    ui.showAnswer(card);
  }


  void showQuestion() {
    Card card = engine.currentCard;
    ui.showQuestion(card);    
  }


  void showNextQuestion() {
    engine.nextCard();
    showQuestion();    
  }


  void goodAnswer() {      
    engine.goodAnswer();
    showNextQuestion();
  }


  void poorAnswer() {      
    engine.poorAnswer();
    showNextQuestion();
  }


  void badAnswer() {      
    engine.badAnswer();
    showNextQuestion();
  }

}

void test1() {
  String resp1 = '{"attributes":{"total":1},"items":[{"id":260301,"addtime":"2009-07-28 03:49:23","hits":96,"username":"fairybel","sex":"f","country":"Korea, Republic of","code":"ko","langname":"Korean","pathmp3":"http:\/\/apifree.forvo.com\/audio\/2d1i1p242h28393o1g1b2j2c1p3l342o2q1l3b2i1b2l1f253m343m2b2e3834342d3m38351l3m2f1l341f1n1j2n3p2q2q1m3o1o3g281n38231n2e212j2c3i352d312n3p1f3d352n2p2j222i3l3i292i3b3639282g393n1t1t_3f2g1k333n1m3i2o2n2k23223l3f323b3c381j233b3n1t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/2f1f2i312a3d2l2a2b1m1f2n3n1o3i2837231h2f3l3m3k2b2b331l2n363h2e2o2k3f2g1m1n1h2l2m2c1n1i2h343g3h3q3m1n1m2a3f2d2p273c22213o233q381g3h2g3h3e251l1o1b2g3e3e371o3m323j3q2h2i1j253n1t1t_2d361j2i3e33351g3l342k243m2k2f1m2a382a3i1g371t1t","rate":1,"num_votes":1,"num_positive_votes":1}]}';
  ForvoResponse r = new ForvoResponse.fromJsonString("aa", "bb", resp1);
  print(r.toJsonString());
  ForvoResponse r1 = new ForvoResponse.fromJsonString("aa", "bb", r.toJsonString());
}

void test2() {
  String lang = "en";
  String word = "run";
    String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
    
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    print(url);
    // call the web server asynchronously
    Future<int> intFut = HttpRequest.request(url).then((xhr) { return 42; }, onError: (asyncError) { 
      print(asyncError);
      throw asyncError;  
    });
    intFut.then((intVal) { print('aaa $intVal'); }, onError: (asyncError) => print("error2 ${asyncError}"));
}

void test3() {
  String lang = "en";
  String word = "run";
    String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";    
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    
    Future<String> f1 = new Future.immediate("1");
    
    var aaa = [0, 1, 2];
    Future f = Future.forEach(aaa, (intval) {
      if (intval == 0) {
        return new Future.of(() {
          print('intval $intval' );
          aaa[intval] = intval +1;
        });
      }
      else if (intval == 1){
        aaa[intval] = intval +3;
      }
      else {
        throw new Exception('dupa');
      }
    });
    f.then((v) {
      print('all ok');
      print(aaa);
      print('v = $v');
    }, onError: (e) {
      print('got error $e');
      
    });
    

   
   /* Future<int> intFut = HttpRequest.request(url).then((xhr) { return 42; }, onError: (asyncError) { 
      print(asyncError);
      throw asyncError;  
    });
    intFut.then((intVal) { print('aaa $intVal'); }, onError: (asyncError) => print("error2 ${asyncError}"));
    */
}



void main() {  
//  test1();
  //test2();
  //test3();
 // List l1 = ['1','2','3','77'];
 // List l2 = ['3','4','5'];
 // print(FlashCardsApp.zip(l1,l2));
  FileCache fileCache = new FileCache( (cache) {
    FlashCardsApp app = new FlashCardsApp(cache);
    app.startApplication();  
  });
  
}


