
#import('dart:html');

#import('Card.dart');
#import('FlashCardsUI.dart');
#import('Engine.dart');

bool question = true;



void main() {
  Engine engine = new Engine();
  FlashCardsUI ui = new FlashCardsUI();


  query("#showAnswerButton").on.click.add((e) => showAnswer(engine, ui));    
  query("#goodAnswerButton").on.click.add((e) => goodAnswer(engine, ui));
  query("#poorAnswerButton").on.click.add((e) => poorAnswer(engine, ui));
  query("#badAnswerButton").on.click.add((e) => badAnswer(engine, ui));
  
  query("#clearCache").on.click.add((e) => window.localStorage.clear());
  
  
  
  
  query("#Begginer1").on.click.add((e) => loadWords(engine, ui));
  
  /*loadWords(engine, ui);
  
  loadWords(engine, ui);*/
  
}


String ff='''{"attributes":{"total":3},"items":[{"id":3562,"addtime":"2008-04-05 20:34:21","hits":9398,"username":"Brett","sex":"m","country":"United States","code":"en","langname":"English","pathmp3":"http:\/\/apifree.forvo.com\/audio\/242d3439212g261f2q2j1p2q1k312o1i2o3e1n3c232j3n242336322e343g3m3a1g3g2p3p22252b3g3i1g2d3c1n363h1j3a291l3q3o3d1g1j2a1f2h25221h3q3k_2n2e3o292m2h25281n2m3l3o3a1h3e3i38252h1f1o211t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/293937252e363g2n232f3m3g2p2i3k2m1h252c2l3m232j2k392c3n2j2f243k1k3m322g1b2p2o2b382k2e2m1f3b253d1o1b3c2b2e3o2j1o3h2p283j381j2e1b2c_2i213c3b2l1n3i2e2c2b1p2k361g1h343j2e3j3q352h1t1t","rate":"0","num_votes":"0","num_positive_votes":0},{"id":712440,"addtime":"2010-08-09 15:47:49","hits":"0","username":"leowarfare","sex":"m","country":"United States","code":"en","langname":"English","pathmp3":"http:\/\/apifree.forvo.com\/audio\/2o3e1b3p342d2n1h3g2l2o3d3438393f2c3e21293h3f2a312g212d221g2o2d273g3i3j2b393o3o3p232g3p392o332n292j323a291h311j232c2m1j352k1m1b3g2f34332d28362n363f1p3j35353g3222223m3h2l3a371t1t_243m32373b1l1k252j3b37242h1h3d3e3b2d3c2f3f3n1t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/272l34342l3h253d1k3d2p2k3a222i1g361p2a292c2b3a243f1g21222b1b3b3a223a3n3f3k251p293f2p1n353c1k3a341k2n2c1i2m283p2p233k2i1f3f293h3q1m1m2l1f32273p3k1m32233h243o2e3i253o2n3b2e2h1t1t_3e2h2n2n1b2c1b2e3b1i3q2i3o2k1o38333i1f2k26211t1t","rate":"0","num_votes":"0","num_positive_votes":0},{"id":1433780,"addtime":"2012-02-17 17:22:10","hits":"0","username":"x_WoofyWoo_x","sex":"f","country":"United Kingdom","code":"en","langname":"English","pathmp3":"http:\/\/apifree.forvo.com\/audio\/2d2i2g3f34263h2g3634221i1m22211b3c2c242m332o2c2q1k273p2l3c2e352o3o1n1m3p2e1g3839283e3p1o3a1o3b2f2b3i2g262q233e263b3e1j2b3b312q383l3b2h1g233m2a1i3l1h2l3j242j351j3d2p243q2m211t1t_391h1o29343c252i3c2c3o3p3b28253g3a231n2g1l211t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/3c272q3l1j1m2a3b243q1o3o1n3a3a2m2n3n332c3e2b3l372j3q333d1k2l1m263435333a1n2m1i3o3n2f1k2n383g252m2j3f2m22242m34223l2l3l3n1h34292d341p2n3b3p3i1p1l2p3g2a3l3g2i2f39241f3o37322h1t1t_1i1b1b2i1p2m2b2d2o1h3e2c1g2d2i361f361g371i3n1t1t","rate":"0","num_votes":1,"num_positive_votes":1}]}''';

void loadWords(Engine engine, FlashCardsUI ui) {
  engine.loadData('wordfiles/Begginer1.json', () { 
    query("#wordFilesDiv").hidden=true;
    query("#learningPanel").hidden=false;
    showQuestion(engine, ui); 
  });
}


void showAnswer(Engine engine, FlashCardsUI ui) {
  Card card = engine.currentCard();
  ui.showAnswer(card);
}


void showQuestion(Engine engine, FlashCardsUI ui) {
  Card card = engine.currentCard();
  ui.showQuestion(card);    
}


void showNextQuestion(Engine engine, FlashCardsUI ui) {
  engine.nextCard();
  showQuestion(engine, ui);    
}


void goodAnswer(Engine engine, FlashCardsUI ui) {      
  engine.goodAnswer();
  showNextQuestion(engine, ui);
}


void poorAnswer(Engine engine, FlashCardsUI ui) {      
  engine.poorAnswer();
  showNextQuestion(engine, ui);
}


void badAnswer(Engine engine, FlashCardsUI ui) {      
  engine.badAnswer();
  showNextQuestion(engine, ui);
}
