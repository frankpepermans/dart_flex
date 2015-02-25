import 'src/dart_flex_codegen.dart' as codegen;
import 'package:dart_flex/dart_flex.dart';
import 'package:observe/observe.dart';
import 'dart:async';

void main() {
  final _TestClass instance = new _TestClass();
}

abstract class UIWrapperChangeNotifier extends UIWrapper {}

class _TestClass extends UIWrapperChangeNotifier with ChangeNotifier {

  VGroup verticalContainer, masterTables;
  @observable HGroup horizontalContainer, centerContainer;
  DataGrid dataGrid;
  Accordion accordion;
  Image editTasksImage, editUrgenciesImage;
  ListRenderer tasksGrid, urgenciesGrid;
  
  VGroup vg;

  _TestClass() {
    final codegen.Scanner S = new codegen.Scanner(this, 'src/views/example_view.xml');
  }

  

}














