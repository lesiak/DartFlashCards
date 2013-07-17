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
    query("#progressBar").style.width = "0%";
  }
  
  void step(bool success) {
    if (success) {
      ++currentSucc;  
    } else {
      ++currentFail;
    }
    var valPercent = ((currentSucc + currentFail)*100)/total; 
    query("#progressBar").style.width = "${valPercent}%";
    print('succ: ${currentSucc}, fail = ${currentFail}, total: ${total}');
    
    if ((currentSucc + currentFail) == total) {
      query("#progressDiv").hidden=true;
    }
  }
}
