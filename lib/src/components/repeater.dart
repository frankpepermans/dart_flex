part of dart_flex;

typedef IUIWrapper CreationHandler();

class Repeater extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  int _currentIndex = 0;
  
  bool _isIterationInvalid = false;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // from
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onFromChangedEvent = const EventHook<FrameworkEvent>('fromChanged');
  Stream<FrameworkEvent> get onFromChanged => Repeater.onFromChangedEvent.forTarget(this);
  int _from;
  
  int get from => _from;
  set from(int value) {
    if (value != _from) {
      _from = value;
  
      _isIterationInvalid = true;
  
      notify(
        new FrameworkEvent(
          "fromChanged"
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // to
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onToChangedEvent = const EventHook<FrameworkEvent>('toChanged');
  Stream<FrameworkEvent> get onToChanged => Repeater.onToChangedEvent.forTarget(this);
  int _to;
  
  int get to => _to;
  set to(int value) {
    if (value != _to) {
      _to = value;
  
      _isIterationInvalid = true;
  
      notify(
        new FrameworkEvent(
          "toChanged"
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // creationHandler
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onCreationHandlerEvent = const EventHook<FrameworkEvent>('creationHandlerChanged');
  Stream<FrameworkEvent> get onCreationHandler => Repeater.onCreationHandlerEvent.forTarget(this);
  CreationHandler _creationHandler;
  
  CreationHandler get creationHandler => _creationHandler;
  set creationHandler(CreationHandler value) {
    if (value != _creationHandler) {
      _creationHandler = value;
  
      _isIterationInvalid = true;
  
      notify(
        new FrameworkEvent(
          "creationHandlerChanged"
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  Repeater({String elementId: null}) : super(elementId: elementId) {
    _className = 'Repeater';
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    if (_control == null) _setControl(new DivElement());
  
    super.createChildren();
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
  
    if (_control != null) {
      if (_isIterationInvalid) {
        _isIterationInvalid = false;
  
        _refresh();
      }
    }
  }
  
  @override
  void addComponent(IUIWrapper element, {bool prepend: false}) {
    _isIterationInvalid = true;
    
    invalidateProperties();
  }
  
  dynamic getCurrentValueFor(IUIWrapper target) => _from + _currentIndex;
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _refresh() {
    if (!_isInitialized) return;
    
    owner.removeAll();
    
    _currentIndex = 0;
    
    for (int i=_from; i<=_to; i++) {
      final IUIWrapper instance = _creationHandler();
      
      _currentIndex++;
      
      owner.addComponent(instance);
    }
  }
}