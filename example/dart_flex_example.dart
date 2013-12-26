import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:dart_flex/dart_flex.dart';
import 'package:observe/observe.dart';

void main() {
  init();
}

void init() {
  // Setup the components via code
  
  // the main container, which maps to the DIV with id=dart_flex_container
  VGroup verticalContainer = new VGroup(elementId:'#dart_flex_container')
  ..percentWidth = 100.0
  ..percentHeight = 100.0;
  
  // a sub container
  HGroup horizontalContainer = new HGroup()
  ..percentWidth = 100.0
  ..percentHeight = 100.0;
  
  // the center area container
  HGroup centerContainer = new HGroup()
  ..cssClasses = const <String>['main-panel']
  ..paddingBottom = 15
  ..percentWidth = 100.0
  ..percentHeight = 100.0;
  
  // the main tasks data grid
  DataGrid dataGrid = new DataGrid()
  ..cssClasses = const <String>[]
  ..percentWidth = 100.0
  ..percentHeight = 100.0
  ..headerHeight = 30
  ..rowHeight = 34
  ..columnSpacing = 0
  ..rowSpacing = 0
  ..columns = createColumns()
  ..dataProvider = createDataProvider()
  ..sortHandler = dataGrid_sortHandler
  ..onRendererAdded.listen(_dataGrid_rendererAddedHandler);
  
  // a container to display the master tables vertically
  VGroup masterTables = new VGroup()
  ..width = 200
  ..percentHeight = 100.0;
  
  // an 'edit tasks' image
  Image editTasksImage = new Image()
  ..width = 200
  ..height = 50
  ..source = 'images/edit_tasks.jpg';
  
  // an 'edit urgency' image
  Image editUrgenciesImage = new Image()
  ..width = 200
  ..height = 50
  ..source = 'images/edit_urgencies.jpg';
  
  // the tasks master list
  ListRenderer tasksGrid = new ListRenderer()
  ..cssClasses = const <String>[]
  ..percentWidth = 100.0
  ..percentHeight = 100.0
  ..rowHeight = 34
  ..rowSpacing = 0
  ..field = taskNameSymbol
  ..itemRendererFactory = new ClassFactory<EditableLabelItemRenderer>(constructorMethod: EditableLabelItemRenderer.construct)
  ..dataProvider = taskNames;
  
  // the urgencies master list
  ListRenderer urgenciesGrid = new ListRenderer()
  ..paddingBottom = 30
  ..cssClasses = const <String>[]
  ..percentWidth = 100.0
  ..percentHeight = 100.0
  ..rowHeight = 34
  ..rowSpacing = 0
  ..field = urgencyNameSymbol
  ..itemRendererFactory = new ClassFactory<EditableLabelItemRenderer>(constructorMethod: EditableLabelItemRenderer.construct)
  ..dataProvider = urgencyNames;
  
  // vertical layout, master tables and the editing images
  masterTables.addComponent(editTasksImage);
  masterTables.addComponent(tasksGrid);
  masterTables.addComponent(editUrgenciesImage);
  masterTables.addComponent(urgenciesGrid);
  
  // central area
  // this is a sub container to the horizontalContainer, because the container has its own CSS rules
  centerContainer.addComponent(dataGrid);
  centerContainer.addComponent(masterTables);
  centerContainer.addComponent(new Group()..width = 8);
  
  // the main horizontal container
  horizontalContainer.addComponent(new Group()..width = 100);
  horizontalContainer.addComponent(centerContainer);
  horizontalContainer.addComponent(new Group()..width = 100);
  
  // the main vertical container
  verticalContainer.addComponent(new Group()..height = 100);
  verticalContainer.addComponent(horizontalContainer);
  verticalContainer.addComponent(new Group()..height = 100);
}

// sort handling when clicking on the data grid headers
String dataGrid_sortHandler(ObservableMap<Symbol, dynamic> data, Symbol propertySymbol) {
  if (propertySymbol == taskNameSymbol) return data[taskSymbol][taskNameSymbol];
  if (propertySymbol == urgencyNameSymbol) return data[urgencySymbol][urgencyNameSymbol];
  if (propertySymbol == dueDateSymbol) return data[dueDateSymbol].toString();
  
  return data[propertySymbol];
}

// two listeners, to update the CSS of the renderer(s) whenever the user switches between
// task status completed or open
void _dataGrid_rendererAddedHandler(FrameworkEvent<DataGridItemRenderer> event) {
  event.relatedObject.onDataChanged.listen(_renderer_dataChangedHandler);
  event.relatedObject.onDataPropertyChanged.listen(_renderer_dataChangedHandler);
}

void _renderer_dataChangedHandler(FrameworkEvent event) {
  final ItemRenderer renderer = event.currentTarget as ItemRenderer;
  
  if (renderer.data != null) {
    String status = renderer.data[statusSymbol];
    
    if (status == 'open') renderer.reflowManager.invalidateCSS(renderer.control, 'text-decoration', 'none');
    else renderer.reflowManager.invalidateCSS(renderer.control, 'text-decoration', 'line-through');
  }
}

// data modelling, using SYMBOL as key
const Symbol taskNameSymbol = const Symbol('task.task.name');
const Symbol taskSymbol = const Symbol('task.task');
const Symbol urgencyNameSymbol = const Symbol('task.urgency.name');
const Symbol urgencySymbol = const Symbol('task.urgency');
const Symbol dueDateSymbol = const Symbol('task.dueDate');
const Symbol statusSymbol = const Symbol('task.status');

ObservableList<ObservableMap<Symbol, String>> taskNames = new ObservableList<ObservableMap<Symbol, String>>.from(
    [
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'water plants'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'go to dentist'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'mow the lawn'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'take out trash'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'clean the garage'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'bring car to garage'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'football practice'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'buy groceries'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'buy xmas gifts'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'make dart flex example'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'walk the dog'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'do laundry'}),
      new ObservableMap<Symbol, String>.from({taskNameSymbol: 'write better css'})
    ]  
);

ObservableList<ObservableMap<Symbol, String>> urgencyNames = new ObservableList<ObservableMap<Symbol, String>>.from(
    [
      new ObservableMap<Symbol, String>.from({urgencyNameSymbol: 'immediately'}),
      new ObservableMap<Symbol, String>.from({urgencyNameSymbol: 'this week'}),
      new ObservableMap<Symbol, String>.from({urgencyNameSymbol: 'later...'})
    ]  
);

ObservableList<ObservableMap<Symbol, dynamic>> createDataProvider() {
  ObservableList<ObservableMap<Symbol, dynamic>> list = new ObservableList<ObservableMap<Symbol, dynamic>>();
  
  for (int i=0; i<1000; i++) list.add(
      new ObservableMap<Symbol, dynamic>.from(
          <Symbol, dynamic>{
            taskSymbol: _getRandomTaskName(),
            urgencySymbol: _getRandomUrgency(),
            dueDateSymbol: _getRandomDate(),
            statusSymbol: _getRandomStatus()
          }
      )
  );
  
  return list;
}

ObservableList createColumns() {
  ObservableList list = new ObservableList();
  
  list.add(
      new DataGridColumn()
      ..fields = const <Symbol>[taskSymbol]
      ..field = taskNameSymbol
      ..percentWidth = 100.0
      ..headerData = const HeaderData('', taskNameSymbol, 'task', 'Task name')
      ..headerItemRendererFactory = new ClassFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
      ..columnItemRendererFactory = new ClassFactory<LabelItemRenderer>(constructorMethod: LabelItemRenderer.construct)   
  );
  
  list.add(
      new DataGridColumn()
      ..fields = const <Symbol>[urgencySymbol]
      ..field = urgencyNameSymbol
      ..width = 130
      ..headerData = const HeaderData('', urgencyNameSymbol, 'urgency', 'Urgency name')
      ..headerItemRendererFactory = new ClassFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
      ..columnItemRendererFactory = new ClassFactory<LabelItemRenderer>(constructorMethod: LabelItemRenderer.construct)   
  );
  
  list.add(
      new DataGridColumn()
      ..field = dueDateSymbol
      ..width = 130
      ..headerData = const HeaderData('', dueDateSymbol, 'due date', 'Due date')
      ..headerItemRendererFactory = new ClassFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
      ..columnItemRendererFactory = new ClassFactory<DateItemRenderer>(constructorMethod: DateItemRenderer.construct)   
  );
  
  list.add(
      new DataGridColumn()
      ..field = statusSymbol
      ..width = 100
      ..headerData = const HeaderData('', statusSymbol, 'status', 'Status')
      ..headerItemRendererFactory = new ClassFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
      ..columnItemRendererFactory = new ClassFactory<StatusComboBoxItemRenderer>(constructorMethod: StatusComboBoxItemRenderer.construct)   
  );
  
  return list;
}

// Randomizers

ObservableMap<Symbol, String> _getRandomTaskName() {
  Random random = new Random();
  
  return taskNames[random.nextInt(taskNames.length)];
}

ObservableMap<Symbol, String> _getRandomUrgency() {
  Random random = new Random();
  
  return urgencyNames[random.nextInt(urgencyNames.length)];
}

DateTime _getRandomDate() {
  Random random = new Random();
  
  return new DateTime(2013 + random.nextInt(2), random.nextInt(12), random.nextInt(31));
}

String _getRandomStatus() {
  Random random = new Random();
  
const List<String> statusNames = const <String>[
    'complete!',
    'open'
  ];
  
  return statusNames[random.nextInt(statusNames.length)];
}

//
//
// ITEM RENDERERS
//
//

class DateItemRenderer extends ItemRenderer {
  
  EditableDate input;

  static DateItemRenderer construct() => new DateItemRenderer();
  
  void createChildren() {
    super.createChildren();
    
    input = new EditableDate()
    ..percentWidth = 100.0
    ..autoSize = true
    ..onDataFinalized.listen(_input_dataChangedHandler);

    addComponent(input);
  }
  
  void invalidateData() {
    super.invalidateData();
    
    if (
        (input != null) &&
        (data != null) &&
        (field != null)
    ) input.data = data[field];
  }
  
  void _input_dataChangedHandler(FrameworkEvent event) {
    data[field] = input.data;
  }
}

class StatusComboBoxItemRenderer extends ItemRenderer {
  
  ComboBox input;

  static StatusComboBoxItemRenderer construct() => new StatusComboBoxItemRenderer();
  
  void createChildren() {
    super.createChildren();
    
    input = new ComboBox()
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..dataProvider = new ObservableList.from(const <String>['complete!', 'open'])
    ..onSelectedItemChanged.listen(_input_onSelectedItemChanged);

    addComponent(input);
  }
  
  void invalidateData() {
    super.invalidateData();
    
    if (
        (input != null) &&
        (data != null) &&
        (field != null)
    ) input.selectedItem = data[field];
  }
  
  void _input_onSelectedItemChanged(FrameworkEvent<String> event) {
    if (data[field] != event.relatedObject) {
      data[field] = event.relatedObject;
      
      notify(
          new FrameworkEvent<dynamic>(
              'dataPropertyChanged',
              relatedObject: data
          )
      );
    }
  }
}