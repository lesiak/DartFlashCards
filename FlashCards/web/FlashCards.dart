import 'dart:html';
import '../lib/flashcards_core.dart';
import '../lib/filecache_api.dart';
import 'FlashCardsUI.dart';

class FlashCardsApp {
  
  Engine engine;
  FlashCardsUI ui;
  
  List<String> level1Files = ['Begginer1',
                     'Begginer2',
                     'Begginer3',
                     'Begginer4',
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
                              'Begginer5', 
                              'Begginer6',
                              'Begginer7',
                              'Begginer8',
                              'Begginer9',
                              'Mythology',
                              'Professions',
                              'Military',
                              'Sentences1',
                              'TopikInter1'];
  
  
  
  FlashCardsApp(FileCache fileCache) {
    
    
      
      
   
    
    this.engine = new Engine();    
    this.ui = new FlashCardsUI(engine, fileCache);
    
    query("#showAnswerButton").onClick.listen((e) => showAnswer());    
    query("#goodAnswerButton").onClick.listen((e) => goodAnswer());
    query("#poorAnswerButton").onClick.listen((e) => poorAnswer());
    query("#badAnswerButton").onClick.listen((e) => badAnswer());
    
    query("#clearCache").onClick.listen((e) => window.localStorage.clear());
        
    query("#startButton").onClick.listen((e) {
      ui.showLearningPanel();
      showQuestion(); 
    });
    query("#clearResultsButton").onClick.listen((e) => clearDeckResults());
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
      
      Element cell = tRow.insertCell(0);
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
  }
  
  
  
  
  

  void loadWordTable(String wordfile) {
    engine.loadData('wordfiles/$wordfile', () { 
      query("#wordListDiv").hidden=false;
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
  
  void fillSummary() {
    query("#totalWords").text = "${engine.deckSize}";
    query("#completedWords").text = "${engine.completedSize}";
    int progress = ((engine.completedSize/engine.deckSize) * 100).toInt();
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


void main() {
  FileCache fileCache = new FileCache( (cache) {
    FlashCardsApp app = new FlashCardsApp(cache);
    app.startApplication();  
  });
  
}


