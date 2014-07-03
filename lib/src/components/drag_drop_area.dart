part of dart_flex;

class DragDropArea extends HGroup {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  RichText _labelDisplay;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent<List<File>>> onFilesReceivedEvent = const EventHook<FrameworkEvent<List<File>>>('filesReceived');
  Stream<FrameworkEvent<List<File>>> get onFilesReceived => DragDropArea.onFilesReceivedEvent.forTarget(this);
  
  //---------------------------------
  // label
  //---------------------------------

  String _label = 'drag and drop files here';

  String get label => _label;
  set label(String value) {
    if (value != _label) {
      _label = value;

      if (_labelDisplay != null) _labelDisplay.richText = value;
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  DragDropArea({String elementId: null}) : super(elementId: elementId) {
    _className = 'DragDropArea';
    
    horizontalScrollPolicy = verticalScrollPolicy = ScrollPolicy.NONE;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _labelDisplay = new RichText()
      ..align = 'center'
      ..autoSize = false
      ..cssClasses = const <String>['drag-drop-label']
      ..percentWidth = 100.0
      ..height = 26
      ..richText = _label;
    
    addComponent(_labelDisplay);
    
    _initEvents();
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _initEvents() {
    _control.onDragOver.listen(_drag_drop_start);
    _control.onDragEnter.listen(_drag_drop_start);
    _control.onDragLeave.listen(_drag_drop_end);
    _control.onDragEnd.listen(_drag_drop_end);
    _control.onDrop.listen(_drop_handler);
  }
  
  void _drop_handler(MouseEvent event) {
    event.dataTransfer.dropEffect = 'move';
    
    _drag_drop_end(event);
    
    notify(
      new FrameworkEvent<List<File>>(
          'filesReceived',
          relatedObject: event.dataTransfer.files
      )    
    );
  }
  
  void _drag_drop_start(MouseEvent event) {
    className = 'DragDropArea-over';
    
    event.stopImmediatePropagation();
    
    event.preventDefault();
  }
  
  void _drag_drop_end(MouseEvent event) {
    className = 'DragDropArea';
    
    event.stopImmediatePropagation();
    
    event.preventDefault();
  }
}