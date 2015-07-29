import 'dart:html';

import 'src/dart_flex_test.dart';

void main() {
  print('test'[0]);
        
  new ExampleView()
    ..wrapTarget(querySelector('#dart_flex_container'))
    ..useMatrixTransformations = true
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
}