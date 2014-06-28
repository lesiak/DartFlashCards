import "dart:html";

import "package:polymer/polymer.dart";


@CustomTag("safe-html")
class SafeHtml extends PolymerElement  {

  @published String model;

  NodeValidator nodeValidator;
  bool get applyAuthorStyles => true;

  SafeHtml.created() : super.created() {
    nodeValidator = new NodeValidatorBuilder()
    ..allowTextElements()
    ..allowElement('SPAN', attributes: ['class']);
    onPropertyChange(this, #model, _addFragment);
  }

  void _addFragment() {
    var fragment = new DocumentFragment.html(model, validator: nodeValidator);

    $["container"].nodes
    ..clear()
    ..add(fragment);
  }

  @override
  void attached() {   
    _addFragment();
  }
}