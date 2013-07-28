import 'dart:html';
import '../lib/flashcards_core.dart';
import '../lib/filecache_api.dart';
import 'DownloaderUI.dart';
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
      showCurrentQuestion(); 
    });
    
    query("#clearResultsButton").onClick.listen((e) => clearDeckResults());
    
    query("#fetchPronoButton").onClick.listen((e) => fetchPronunciations());
        
    query("#homePill").onClick.listen((e) => goToHomePanel());
    
    ImageElement imgFlag = query("#imgFlag"); 
    imgFlag.onClick.listen((e) {      
      if (imgFlag.src.endsWith('svgFlags/Flag_of_Republic_of_Korea.svg')) {
        imgFlag.src = '../assets/svgFlags/Flag_of_Finland_1920-1978_(State).svg';
      } else {
        imgFlag.src = '../assets/svgFlags/Flag_of_Republic_of_Korea.svg';  
      }      
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
  
  void goToHomePanel() {
    engine.initLearningList();
    ui.showHomePanel();
    showDeckData();
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
  }

  void loadWordTable(String wordfile) {
    engine.loadData('../wordfiles/$wordfile', () { 
      query("#deckDetailsDiv").hidden=false;
      showDeckData();
    }  
    );
  }
  
  void showDeckData() {
    fillWordsTable();
    fillSummary();
  }
  
  void clearDeckResults() {
    engine.clearDeckResults();
    showDeckData();
  }
  
  void fetchPronunciations() {
    DownloaderUI downloaderUI = new DownloaderUI(engine.allCardsInDeck.length * 4);
    downloaderUI.initProgress();    
    for (Card card in engine.allCardsInDeck) {
      ui.pronounciationManager.fetchMissingPronunciations("en", ui.sanitizeWord("en", card.en), downloaderUI.step);      
      ui.pronounciationManager.fetchMissingPronunciations("ko", ui.sanitizeWord("ko", card.ko), downloaderUI.step);  
      ui.pronounciationManager.fetchMissingPronunciations("fi", ui.sanitizeWord("fi", card.fi), downloaderUI.step);
      ui.pronounciationManager.fetchMissingPronunciations("fr", ui.sanitizeWord("fr", card.fr), downloaderUI.step);
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
      showCurrentQuestion(); 
    });
  }



  void showAnswer() {
    Card card = engine.currentCard;
    ui.showAnswer(card);
  }


  void showCurrentQuestion() {
    Card card = engine.currentCard;
    ui.showQuestion(card);    
  }


  void showNextQuestion() {
    if (engine.hasNextCard()) {
      engine.nextCard();
      showCurrentQuestion();
    }
    else {
      goToHomePanel();
    }
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


