library DownloaderUI;

import 'dart:html';

class DownloaderUI {
  
  int total;
  
  int currentSucc;
  
  int currentFail;
  
  DownloaderUI(this.total) {
    currentSucc = 0; 
    currentFail = 0;
  } 
  
  void initProgress() {
    query("#progressDiv").hidden=false;
    query("#progressBarSuccess").style.width = "0%";
    query("#progressBarFailure").style.width = "0%";
  }
  
  void step(bool success) {
    if (success) {
      ++currentSucc;
      query("#progressBarSuccess").style.width = "${(currentSucc*100)/total}%";
    } else {
      ++currentFail;
      query("#progressBarFailure").style.width = "${(currentFail*100)/total}%";
    }            
    print('succ: ${currentSucc}, fail = ${currentFail}, total: ${total}');
    
    if ((currentSucc + currentFail) == total) {
      query("#progressDiv").hidden=true;
    }
  }
}
