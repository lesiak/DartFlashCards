#import('dart:html');

#import('Card.dart');
#import('CardScore.dart');
#import('FlashCardsUI.dart');
#import('Engine.dart');

class FlashCardsApp {
  
  Engine engine;
  FlashCardsUI ui;
  
  
  FlashCardsApp() {
    this.engine = new Engine();
    this.ui = new FlashCardsUI();
    
    query("#showAnswerButton").on.click.add((e) => showAnswer());    
    query("#goodAnswerButton").on.click.add((e) => goodAnswer());
    query("#poorAnswerButton").on.click.add((e) => poorAnswer());
    query("#badAnswerButton").on.click.add((e) => badAnswer());
    
    query("#clearCache").on.click.add((e) => window.localStorage.clear());
        
    query("#startButton").on.click.add((e) {
      query("#wordFilesDiv").hidden=true;
      query("#learningPanel").hidden=false;
      showQuestion(); 
    });
    query("#clearResultsButton").on.click.add((e) => clearDeckResults());
  }
  
  void startApplication() {
    fillQuestionDecksTable();
  }
  
  void fillQuestionDecksTable() {
    var wordFiles = ['Begginer1', 'Begginer2', 'Begginer3', 'TopikInter1'];
    TableElement table = query("#questionDecksTable");
    TableSectionElement tBody = table.tBodies[0]; 
    tBody.nodes.clear();
    for (String deckName in wordFiles) {
      TableRowElement newLine = tBody.insertRow(-1); // add at the end
      Element cell = newLine.insertCell(0);
      cell.classes.add('deckLink');
      AnchorElement deckLink = new AnchorElement("#");
      deckLink.text = deckName;
      deckLink.on.click.add((e) => loadWordTable(engine, "${deckName}.json"));
      cell.nodes.add(deckLink);
    }
    

  }

  void loadWordTable(Engine engine, String wordfile) {
    engine.loadData('wordfiles/$wordfile', () { 
      query("#wordListDiv").hidden=false;
      fillWordsTable();
      fillSummary();
    }  
    );
  }
  
  void clearDeckResults() {
    engine.clearDeckResults();
    fillWordsTable();
    fillSummary();
  }
  
  void fillSummary() {
    query("#totalWords").text = "${engine.allCardsInDeck.length}";
  }
  
  void fillWordsTable() {
    TableElement table = query("#wordTable");
    TableSectionElement tBody = table.tBodies[0]; 
    tBody.nodes.clear();
    for (Card card in engine.allCardsInDeck) {
      CardScore score = engine.getCardScoreFromStore(card);
      TableRowElement newLine = tBody.insertRow(-1); // add at the end
      if (score != null) {
        if (score.isGoodAnswer()) {
          newLine.classes.add("succ");
        }
        else if (score.isPoorAnswer()) {
          newLine.classes.add("error");
        }
        else if (score.isBadAnswer()) {
          newLine.classes.add("error");
        }
      }
      
      newLine.insertCell(0).text = card.en;
      newLine.insertCell(1).text = card.ko;
      newLine.insertCell(2).text = card.fi;
      newLine.insertCell(3).text = card.fr;
      
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
    Card card = engine.currentCard();
    ui.showAnswer(card);
  }


  void showQuestion() {
    Card card = engine.currentCard();
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
  FlashCardsApp app = new FlashCardsApp();
  app.startApplication();
}


