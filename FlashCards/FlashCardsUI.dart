#library('FlashCards');
#import('dart:html');
#import('Card.dart');
#import('ForvoApi.dart');

typedef void ForvoResonseCallback();

class FlashCardsUI {
  
  final String NBSP = "\u00A0";
  
  final String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
  
  void showQuestion(Card card) {
    query("#en").text = card.en;    
    getPronunciations("en", card.en, "#enPro", true);  
    clearAnswerNodes();
    setAnswerButtonsDisabled(true);
    setQuestionButtonsDisabled(false);  
  }
  
  void showAnswer(Card card) { 
    query("#ko").text = card.ko;
    query("#fi").text = card.fi;
    query("#fr").text = card.fr;
    getPronunciations("ko", card.ko, "#koPro", true);
    getPronunciations("fi", card.fi, "#fiPro", false);
    getPronunciations("fr", card.fr, "#frPro", false);
    setAnswerButtonsDisabled(false);
    setQuestionButtonsDisabled(true);
  }

  
  void clearAnswerNodes() {
    query("#ko").text = NBSP;
    query("#fi").text = NBSP;
    query("#fr").text = NBSP;
    query("#koPro").nodes.clear();
    query("#fiPro").nodes.clear();
    query("#frPro").nodes.clear();
  }
  
  void setAnswerButtonsDisabled(bool disabled) {
    ButtonElement goodAnswerButton = query("#goodAnswerButton");
    goodAnswerButton.disabled = disabled;
    ButtonElement poorAnswerButton = query("#poorAnswerButton");
    poorAnswerButton.disabled = disabled;
    ButtonElement badAnswerButton = query("#badAnswerButton");
    badAnswerButton.disabled = disabled;
  }
  
  void setQuestionButtonsDisabled(bool disabled) {
    ButtonElement showAnswerButton = query("#showAnswerButton");
    showAnswerButton.disabled = disabled;    
  }


  
  void getPronunciations(String lang, String word, String containerId, bool play) {
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    
    // call the web server asynchronously
    Element container = query(containerId);
    
    var request = new XMLHttpRequest.get(url, (req) => onForvoSuccess(req, container, play));
    //processForvoRespone(ff, container); 
  }

// print the raw json response text from the server
  void onForvoSuccess(XMLHttpRequest req, Element container, bool play) {  
    String responseText = req.responseText;
    if (!responseText.isEmpty()) {
      processForvoResponeText(responseText, container, play);
    }
    
  }

  void processForvoResponeText(String responseText, Element container, bool play) {  
    ForvoResponse r = ForvoResponse.fromJsonString(responseText);
    List<Element> pronounciationNodes = createAudioNodes(r);
    container.nodes.clear();
    container.nodes.addAll(pronounciationNodes);  
    if (play && !r.items.isEmpty()) {
      playPronounciation(getPreferredPronunciation(r));
    }
  }
  
  ForvoItem getPreferredPronunciation(ForvoResponse r) {
    Set<String> favoriteUsers = new Set();
    favoriteUsers.addAll(['ssoonkimi', 'x_WoofyWoo_x', 'floridagirl']);
    for (ForvoItem item in r.items) {
      if (favoriteUsers.contains(item.username) ) {
        return item;
      }
    }
    return r.items[0];
  }
  
  List<Element> createAudioNodes(ForvoResponse r) {
    List<Element> ret = [];
    for (ForvoItem item in r.items) {
      DivElement div = new DivElement(); 
      div.classes.add('btn-group');
      ButtonElement button = new ButtonElement();
      button.text = item.username;
      button.classes.add("btn");
      button.attributes['rel'] = 'tooltip';
      button.attributes['title'] = '${item.sex} ${item.country}';
      button.on.click.add((e)  => playPronounciation(item));
      div.nodes.add(button);   
      ret.add(div);
    }
    return ret;
  }

  void playPronounciation(ForvoItem item) {
    String url= item.pathogg;
    var html='<audio autoplay="true"><source src="$url"></audio>';
    query("#audioContainer").innerHTML = html;
  }


}
