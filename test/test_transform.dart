import 'src/dart_flex_codegen.dart' as codegen;
import 'package:dart_flex/dart_flex.dart' as flex;

void main() {
  final _TestClass instance = new _TestClass();
}

class _TestClass extends flex.UIWrapper {

  flex.VGroup verticalContainer, masterTables;
  flex.HGroup horizontalContainer, centerContainer;
  flex.DataGrid dataGrid;
  flex.Accordion accordion;
  flex.Image editTasksImage, editUrgenciesImage;
  flex.ListRenderer tasksGrid, urgenciesGrid;

  _TestClass() {
    final codegen.Scanner S = new codegen.Scanner(this, 'src/views/example_view.xml');
  }

}














