import 'src/dart_flex_codegen.dart' as codegen;
import 'package:dart_flex/dart_flex.dart' as flex;
import 'package:observe/observe.dart';

void main() {
  final _TestClass instance = new _TestClass();
}

abstract class UIWrapperChangeNotifier extends flex.UIWrapper {}

class _TestClass extends UIWrapperChangeNotifier with ChangeNotifier {

  flex.VGroup verticalContainer, masterTables;
  @observable flex.HGroup horizontalContainer, centerContainer;
  flex.DataGrid dataGrid;
  flex.Accordion accordion;
  flex.Image editTasksImage, editUrgenciesImage;
  flex.ListRenderer tasksGrid, urgenciesGrid;
  
  flex.VGroup vg;

  _TestClass() {
    final codegen.Scanner S = new codegen.Scanner(this, 'src/views/example_view.xml');
  }
}














