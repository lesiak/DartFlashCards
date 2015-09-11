import 'package:polymer/polymer.dart';
import 'package:flashcardsnew/flashcards_core.dart';
import 'package:flashcardsnew/forvo_api.dart';

@CustomTag('prono-download-panel')
class PronoDownloadPanel extends PolymerElement {   
  
  @observable int total;
    
  @observable int currentSucc;
    
  @observable int currentFail;
  
  @observable bool showProgress = false; 
  
  PronoDownloadPanel.created() : super.created();
  
  void fetchPronunciations(PronounciationManager pronounciationManager, List<Card> allCardsInDeck, List<String> all_langs) {
      initProgress(allCardsInDeck.length * all_langs.length);    
      for (Card card in allCardsInDeck) {
        for (String lang in all_langs) {
          pronounciationManager.fetchMissingPronunciations(lang, CardUtils.sanitizeWordEntry(lang, card.getValueForLang(lang)), step);
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
   
  
 
}