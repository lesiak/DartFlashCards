library DownloaderUI;

import 'dart:html';
import 'package:polymer/polymer.dart';


class DownloaderUI extends Object with ObservableMixin {
  
  int _total;
  
  int _currentSucc;
  
  int _currentFail;
  
  @observable num precentSucc;
  
  @observable num precentFail;  
  
  @observable bool showElement = false;
  
  int get currentSucc => _currentSucc;
  
  void set currentSucc(int c) {    
    _currentSucc = c;
    precentSucc = (currentSucc*100)/_total;
  }
  
  int get currentFail => _currentFail;
  
  void set currentFail(int c) {
    _currentFail = c;
    precentFail = (currentFail*100)/_total;
  }
    
  DownloaderUI() {
   bindModel();
  }
  
  void bindModel() {
    query('#progressDivTmpl').model = this; 
  }
     
  void initProgress(int pTotal) {
    this._total = pTotal;
    currentSucc = 0; 
    currentFail = 0;
    showElement = true; 
    //Observable.dirtyCheck();
  }
  
  void step(bool success) {
    if (success) {
      currentSucc = currentSucc + 1;      
    } else {
      currentFail = currentFail + 1;      
    }                
    
    if ((_currentSucc + _currentFail) == _total) {
      showElement = false;
    }
    Observable.dirtyCheck();
  }
}
