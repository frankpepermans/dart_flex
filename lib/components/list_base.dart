part of dart_flex;

typedef bool InactiveHandler(dynamic data);
typedef bool InvalidHandler(dynamic data);

class ListBase extends Group {

  bool _isElementUpdateRequired = false;
  bool _skipPresentationUpdate = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // inactiveHandler
  //---------------------------------

  InactiveHandler _inactiveHandler;

  InactiveHandler get inactiveHandler => _inactiveHandler;
  set inactiveHandler(InactiveHandler value) {
    if (value != _inactiveHandler) {
      _inactiveHandler = value;
    }
  }

  //---------------------------------
  // dataProvider
  //---------------------------------

  static const EventHook<FrameworkEvent> onDataProviderChangedEvent = const EventHook<FrameworkEvent>('dataProviderChanged');
  Stream<FrameworkEvent> get onDataProviderChanged => ListBase.onDataProviderChangedEvent.forTarget(this);
  ObservableList<dynamic> _dataProvider;
  StreamSubscription _dataProviderChangesListener;

  ObservableList<dynamic> get dataProvider => _dataProvider;
  set dataProvider(ObservableList<dynamic> value) {
    if (value != _dataProvider) {
      _dataProvider = value;
      _isElementUpdateRequired = true;
      
      if (_dataProviderChangesListener != null) _dataProviderChangesListener.cancel();

      if (value != null) _dataProviderChangesListener = value.listChanges.listen(_dataProvider_collectionChangedHandler);
      
      notify(
          new FrameworkEvent(
            'dataProviderChanged',
            relatedObject: value
          )
      );
      
      invalidatePresentation();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // presentationHandler
  //---------------------------------

  CompareHandler _presentationHandler;
  
  CompareHandler get presentationHandler => _presentationHandler;
  set presentationHandler(CompareHandler value) {
    if (value != _presentationHandler) {
      _presentationHandler = value;
      
      invalidatePresentation();
    }
  }
  
  //---------------------------------
  // labelField
  //---------------------------------

  static const EventHook<FrameworkEvent> onFieldChangedEvent = const EventHook<FrameworkEvent>('fieldChanged');
  Stream<FrameworkEvent> get onFieldChanged => ListBase.onFieldChangedEvent.forTarget(this);
  Symbol _field;

  Symbol get field => _field;
  set field(Symbol value) {
    if (value != _field) {
      _field = value;
      
      notify(
          new FrameworkEvent(
            'fieldChanged'
          )
      );
    }
  }

  //---------------------------------
  // labelFunction
  //---------------------------------

  static const EventHook<FrameworkEvent> onLabelFunctionChangedEvent = const EventHook<FrameworkEvent>('labelFunctionChanged');
  Stream<FrameworkEvent> get onLabelFunctionChanged => ListBase.onLabelFunctionChangedEvent.forTarget(this);
  Function _labelFunction;

  Function get labelFunction => _labelFunction;
  set labelFunction(Function value) {
    if (value != _labelFunction) {
      _labelFunction = value;
      
      notify(
          new FrameworkEvent(
            'labelFunctionChanged'
          )
      );
    }
  }

  //---------------------------------
  // selectedIndex
  //---------------------------------

  static const EventHook<FrameworkEvent> onSelectedIndexChangedEvent = const EventHook<FrameworkEvent>('selectedIndexChanged');
  Stream<FrameworkEvent> get onSelectedIndexChanged => ListBase.onSelectedIndexChangedEvent.forTarget(this);
  int _selectedIndex = -1;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    if (value != _selectedIndex) {
      _selectedIndex = value;
      
      if (
          (_dataProvider != null) &&
          (value >= 0) &&
          (value < _dataProvider.length)
      ) {
        _selectedItem = _dataProvider[value];
        
        notify(
            new FrameworkEvent<dynamic>(
                'selectedItemChanged',
                relatedObject: _selectedItem
            )
        );
      }

      notify(
          new FrameworkEvent(
            'selectedIndexChanged',
            relatedObject: value
          )
      );

      later > _updateSelection;
    }
  }

  //---------------------------------
  // selectedItem
  //---------------------------------

  static const EventHook<FrameworkEvent> onSelectedItemChangedEvent = const EventHook<FrameworkEvent>('selectedItemChanged');
  Stream<FrameworkEvent> get onSelectedItemChanged => ListBase.onSelectedItemChangedEvent.forTarget(this);
  dynamic _selectedItem;

  dynamic get selectedItem => _selectedItem;
  set selectedItem(dynamic value) {
    if (value != _selectedItem) {
      _selectedItem = value;
      
      if (_dataProvider != null) {
        _selectedIndex = _dataProvider.indexOf(value);
        
        notify(
            new FrameworkEvent(
                'selectedIndexChanged',
                relatedObject: _selectedIndex
            )
        );
      }

      notify(
          new FrameworkEvent<dynamic>(
            'selectedItemChanged',
            relatedObject: value
          )
      );

      later > _updateSelection;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ListBase({String elementId: null}) : super(elementId: elementId) {
  	_className = 'ListWrapper';
  }

  //---------------------------------
  //
  // Operator overloads
  //
  //---------------------------------

  int operator +(dynamic item) {
    if (_dataProvider == null) dataProvider = new ObservableList<dynamic>();
    
    _dataProvider.add(item);

    return item;
  }

  int operator -(dynamic item) {
    if (_dataProvider == null) dataProvider = new ObservableList<dynamic>();
    else _dataProvider.remove(item);

    return item;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void commitProperties() {
    super.commitProperties();

    if (_control != null) {
      if (_isElementUpdateRequired) {
        _isElementUpdateRequired = false;
        
        if (!_skipPresentationUpdate) _updatePresentation();
        
        _skipPresentationUpdate = false;
        
        _updateElements();
        _updateAfterScrollPositionChanged();
        
        if (_dataProvider != null) selectedIndex = _dataProvider.indexOf(_selectedItem);
      }
    }
  }
  
  void invalidatePresentation() {
    _isElementUpdateRequired = true;
    
    invalidateProperties();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _updatePresentation() {
    if (
        (_dataProvider != null) &&
        (_presentationHandler != null)
    ) _dataProvider.sort(_presentationHandler);
  }

  void _setControl(Element element) {
    super._setControl(element);

    _isElementUpdateRequired = true;
  }

  void _removeAllElements() {
    if (_control != null) while (_control.children.length > 0) _control.children.removeLast();

    _childWrappers = <IUIWrapper>[];
  }
  
  void _updateAfterScrollPositionChanged() {}

  void _updateElements() {
    if (_dataProvider == null) return;
    
    int len = _dataProvider.length;
    int i;

    _removeAllElements();

    for (i=0; i<len; i++) _createElement(_dataProvider[i], i);

    _updateSelection();
  }

  void _updateSelection() {}

  void _createElement(dynamic item, int index) {}

  void _dataProvider_collectionChangedHandler(List<ListChangeRecord> changes) {
    _isElementUpdateRequired = true;
    _skipPresentationUpdate = true;

    invalidateProperties();
  }
}

