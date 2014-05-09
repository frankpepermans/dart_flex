import 'dart:html';

import 'src/dart_flex_test.dart';

void main() {
  print('test'[0]);
        
  UIMLBinding view = new UIMLBinding()
    ..wrapTarget(querySelector('#dart_flex_container'))
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
}