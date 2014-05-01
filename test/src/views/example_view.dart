part of dart_flex_test;

class ExampleView extends UIWrapper {
  
  VGroup verticalContainer, masterTables;
  HGroup horizontalContainer, centerContainer;
  DataGrid dataGrid;
  Accordion accordion;
  Image editTasksImage, editUrgenciesImage;
  ListRenderer tasksGrid, urgenciesGrid;
  
  ExampleView({String elementId: null}) : super(elementId: elementId) {
    onSkinPartAdded.listen(
      (FrameworkEvent<IUIWrapper> event) {
        if (event.relatedObject == dataGrid) dataGrid.onRendererAdded.listen(_dataGrid_rendererAddedHandler);
      }    
    );
  }
  
  @Skin('dart_flex|test/src/views/example_view.xml')
  
  // data modelling, using SYMBOL as key
  static const Symbol taskNameSymbol = const Symbol('task.task.name');
  static const Symbol taskSymbol = const Symbol('task.task');
  static const Symbol urgencyNameSymbol = const Symbol('task.urgency.name');
  static const Symbol urgencySymbol = const Symbol('task.urgency');
  static const Symbol dueDateSymbol = const Symbol('task.dueDate');
  static const Symbol statusSymbol = const Symbol('task.status');

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

      if (status == 'open') renderer.reflowManager.invalidateCSS(renderer.control, 'text-decoration', 'none'); else renderer.reflowManager.invalidateCSS(renderer.control, 'text-decoration', 'line-through');
    }
  }

  ObservableList<ObservableMap<Symbol, String>> taskNames = new ObservableList<ObservableMap<Symbol, String>>.from([new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'water plants'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'go to dentist'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'mow the lawn'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'take out trash'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'clean the garage'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'bring car to garage'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'football practice'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'buy groceries'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'buy xmas gifts'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'make dart flex example'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'walk the dog'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'do laundry'
    }), new ObservableMap<Symbol, String>.from({
      taskNameSymbol: 'write better css'
    })]);

  ObservableList<ObservableMap<Symbol, String>> urgencyNames = new ObservableList<ObservableMap<Symbol, String>>.from([new ObservableMap<Symbol, String>.from({
      urgencyNameSymbol: 'immediately'
    }), new ObservableMap<Symbol, String>.from({
      urgencyNameSymbol: 'this week'
    }), new ObservableMap<Symbol, String>.from({
      urgencyNameSymbol: 'later...'
    })]);

  ObservableList<ObservableMap<Symbol, dynamic>> createDataProvider() {
    ObservableList<ObservableMap<Symbol, dynamic>> list = new ObservableList<ObservableMap<Symbol, dynamic>>();

    for (int i = 0; i < 1000; i++) list.add(new ObservableMap<Symbol, dynamic>.from(<Symbol, dynamic> {
      taskSymbol: _getRandomTaskName(),
      urgencySymbol: _getRandomUrgency(),
      dueDateSymbol: _getRandomDate(),
      statusSymbol: _getRandomStatus()
    }));

    return list;
  }

  ObservableList<ObservableMap<Symbol, dynamic>> createAccordionDataProvider() {
    ObservableList<ObservableMap<Symbol, dynamic>> list = new ObservableList<ObservableMap<Symbol, dynamic>>();

    for (int i = 0; i < 10; i++) list.add(new ObservableMap<Symbol, dynamic>.from(<Symbol, dynamic> {
      taskSymbol: _getRandomTaskName(),
      urgencySymbol: _getRandomUrgency(),
      dueDateSymbol: _getRandomDate(),
      statusSymbol: _getRandomStatus()
    }));

    return list;
  }

  ObservableList createColumns() {
    ObservableList list = new ObservableList();

    list.add(new DataGridColumn()
        ..fields = const <Symbol>[taskSymbol]
        ..field = taskNameSymbol
        ..percentWidth = 100.0
        ..headerData = const HeaderData('', taskNameSymbol, 'task', 'Task name')
        ..headerItemRendererFactory = new ItemRendererFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ItemRendererFactory<LabelItemRenderer>(constructorMethod: LabelItemRenderer.construct));

    list.add(new DataGridColumn()
        ..fields = const <Symbol>[urgencySymbol]
        ..field = urgencyNameSymbol
        ..width = 130
        ..headerData = const HeaderData('', urgencyNameSymbol, 'urgency', 'Urgency name')
        ..headerItemRendererFactory = new ItemRendererFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ItemRendererFactory<LabelItemRenderer>(constructorMethod: LabelItemRenderer.construct));

    list.add(new DataGridColumn()
        ..field = dueDateSymbol
        ..width = 130
        ..headerData = const HeaderData('', dueDateSymbol, 'due date', 'Due date')
        ..headerItemRendererFactory = new ItemRendererFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ItemRendererFactory<DateItemRenderer>(constructorMethod: DateItemRenderer.construct));

    list.add(new DataGridColumn()
        ..field = statusSymbol
        ..width = 100
        ..headerData = const HeaderData('', statusSymbol, 'status', 'Status')
        ..headerItemRendererFactory = new ItemRendererFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ItemRendererFactory<StatusComboBoxItemRenderer>(constructorMethod: StatusComboBoxItemRenderer.construct));

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

    const List<String> statusNames = const <String>['complete!', 'open'];

    return statusNames[random.nextInt(statusNames.length)];
  }

}
