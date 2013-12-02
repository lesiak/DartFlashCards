part of flashcards_core;

// Waiting on bug https://code.google.com/p/dart/issues/detail?id=13849
//import 'package:polymer/polymer.dart'
//show ObservableMixin, observable, bindProperty, notifyProperty;

class Card extends Object with Observable {
  @observable String en;
  @observable String ko;
  @observable String fi;
  @observable String fr;
  
  Card(this.en, this.ko, this.fi, this.fr);
  
  
}
