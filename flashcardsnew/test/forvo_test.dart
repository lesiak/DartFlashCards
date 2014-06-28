import 'package:unittest/unittest.dart';
import 'package:flashcardsnew/forvo_api.dart';
import 'package:unittest/html_config.dart';
import 'dart:async';
import 'dart:html';

void testForvoJSON() {
  String resp1 = '{"attributes":{"total":1},"items":[{"id":260301,"addtime":"2009-07-28 03:49:23","hits":96,"username":"fairybel","sex":"f","country":"Korea, Republic of","code":"ko","langname":"Korean","pathmp3":"http:\/\/apifree.forvo.com\/audio\/2d1i1p242h28393o1g1b2j2c1p3l342o2q1l3b2i1b2l1f253m343m2b2e3834342d3m38351l3m2f1l341f1n1j2n3p2q2q1m3o1o3g281n38231n2e212j2c3i352d312n3p1f3d352n2p2j222i3l3i292i3b3639282g393n1t1t_3f2g1k333n1m3i2o2n2k23223l3f323b3c381j233b3n1t1t","pathogg":"http:\/\/apifree.forvo.com\/audio\/2f1f2i312a3d2l2a2b1m1f2n3n1o3i2837231h2f3l3m3k2b2b331l2n363h2e2o2k3f2g1m1n1h2l2m2c1n1i2h343g3h3q3m1n1m2a3f2d2p273c22213o233q381g3h2g3h3e251l1o1b2g3e3e371o3m323j3q2h2i1j253n1t1t_2d361j2i3e33351g3l342k243m2k2f1m2a382a3i1g371t1t","rate":1,"num_votes":1,"num_positive_votes":1}]}';
  ForvoResponse r = new ForvoResponse.fromJsonString("aa", "bb", resp1);
  print(r.toJsonString());
  ForvoResponse r1 = new ForvoResponse.fromJsonString("aa", "bb", r.toJsonString());
}

void test2() {
  String lang = "en";
  String word = "run";
    String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";
    
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    print(url);
    // call the web server asynchronously
    Future<int> intFut = HttpRequest.request(url).then((xhr) { return 42; }, onError: (asyncError) { 
      print(asyncError);
      throw asyncError;  
    });
    intFut.then((intVal) { print('aaa $intVal'); }, onError: (asyncError) => print("error2 ${asyncError}"));
}


void test3() {
  String lang = "en";
  String word = "run";
    String forvoKey="ca19d7cd6c0d10ed257b2d23960933ee";    
    var url = "http://apifree.forvo.com/action/word-pronunciations/format/json/word/$word/language/$lang/key/$forvoKey/";
    
    Future<String> f1 = new Future.value("1");
    
    var aaa = [0, 1, 2];
    Future f = Future.forEach(aaa, (intval) {
      if (intval == 0) {
        return new Future(() {
          print('intval $intval' );
          aaa[intval] = intval +1;
        });
      }
      else if (intval == 1){
        aaa[intval] = intval +3;
      }
      else {
        throw new Exception('dupa');
      }
    });
    f.then((v) {
      print('all ok');
      print(aaa);
      print('v = $v');
    }, onError: (e) {
      print('got error $e');
      
    });
    

   
   /* Future<int> intFut = HttpRequest.request(url).then((xhr) { return 42; }, onError: (asyncError) { 
      print(asyncError);
      throw asyncError;  
    });
    intFut.then((intVal) { print('aaa $intVal'); }, onError: (asyncError) => print("error2 ${asyncError}"));
    */
}



main() {
  useHtmlConfiguration();
  group('Forvo:', () {
    test('unmarshall JSON', () {
       testForvoJSON();
    });
    
    test('test2', () {
      test2();
    });
    
    test('test3', () {
      test3();
    });
    
    
  });
}

