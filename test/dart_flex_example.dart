import 'src/dart_flex_test.dart';

void main() {
  final RegExp exp = new RegExp(r"'[^']+'");
  String str = "/ fn.c(t.e.st - o.uip.xx) + ";
  Match match = exp.firstMatch(str);
  
  while (match != null) {
    str = str.substring(0, match.start) + str.substring(match.end);
    
    match = exp.firstMatch(str);
  }
  
  final RegExp exp2 = new RegExp(r"[^\(\) \+\-\/\*\&\|]+");
  
  exp2.allMatches(str).forEach(
    (Match M) => print(str.substring(M.start, M.end))    
  );
        
  UIMLBinding view = new UIMLBinding(elementId:'#dart_flex_container')
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
}