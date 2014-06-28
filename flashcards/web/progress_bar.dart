import 'package:polymer/polymer.dart';

@CustomTag('progress-bar')
class ProgressBarElement extends PolymerElement {
  //@published int count = 0;
  
  @published int total;
  
  @published int currentSucc;
  
  @published int currentFail;
  
  // Instead of a getter, make an observable field, and update
  // that when one of its source fields change.
  // Polymer.dart doesn't have a slick way to mark a getter as
  // observable. But this seems to do nicely.
  @observable num precentSucc;
  
  @observable num precentFail;  
  
  ProgressBarElement.created() : super.created();
  
  totalChanged(int oldValue) {
    //second = timestamp.second;
   // precentSucc = 10;
  }
  
  currentSuccChanged(int oldValue) {
    precentSucc = (currentSucc*100)/total;  
  }
  
  currentFailChanged(int oldValue) {
    precentFail = (currentFail*100)/total;  
  }
   
}