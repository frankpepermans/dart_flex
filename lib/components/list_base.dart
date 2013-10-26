part of dart_flex;

class ListBase extends Group {

  bool _isElementUpdateRequired = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // dataProvider
  //---------------------------------

  static const EventHook<FrameworkEvent> onDataProviderChangedEvent = const EventHook<FrameworkEvent>('dataProviderChanged');
  Stream<FrameworkEvent> get onDataProviderChanged => ListBase.onDataProviderChangedEvent.forTarget(this);
  ObservableList _dataProvider;
  
  ObservableList get xDataProvider => dataProvider;
  set xDataProvider(ObservableList value) => dataProvider = value;

  ObservableList get dataProvider => _dataProvider;
  set dataProvider(ObservableList value) {
    if (value != _dataProvider) {
      /*if (_dataProvider != null) {
        _dataProvider.ignore(
            CollectionEvent.COLLECTION_CHANGED,
            _dataProvider_collectionChangedHandler
        );
      }*/

      _dataProvider = value;
      _isElementUpdateRequired = true;

      if (value != null) {
        value.changes.listen(_dataProvider_collectionChangedHandler);
      }
      
      notify(
          new FrameworkEvent(
            'dataProviderChanged',
            relatedObject: value
          )
      );

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
      
      if (_dataProvider != null) _dataProvider.sort(value);
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
  Object _selectedItem;

  Object get selectedItem => _selectedItem;
  set selectedItem(Object value) {
    if (value != _selectedItem) {
      _selectedItem = value;

      notify(
          new FrameworkEvent(
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

  int operator +(Object item) {
    if (_dataProvider == null) {
      dataProvider = new ObservableList();
    }
    
    _dataProvider.add(item);

    return item;
  }

  int operator -(Object item) {
    if (_dataProvider == null) {
      dataProvider = new ObservableList();
    }
    
    _dataProvider.remove(item);

    return item;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _setControl(Element element) {
    super._setControl(element);

    _isElementUpdateRequired = true;
  }

  void _commitProperties() {
    super._commitProperties();

    if (_control != null) {
      if (_isElementUpdateRequired) {
        _isElementUpdateRequired = false;
        
        _updateElements();
        _updateAfterScrollPositionChanged();
      }
    }
  }

  void _removeAllElements() {
    if (_control != null) {
      while (_control.children.length > 0) {
        _control.children.removeLast();
      }
    }

    _childWrappers = new List<IUIWrapper>();
  }
  
  void _updateAfterScrollPositionChanged() {}

  void _updateElements() {
    if (_dataProvider == null) {
      return;
    }
    
    Object element;
    int len = _dataProvider.length;
    int i;

    _removeAllElements();

    for (i=0; i<len; i++) {
      element = _dataProvider[i];

      _createElement(element, i);
    }

    _updateSelection();
  }

  void _updateSelection() {
  }

  void _createElement(Object item, int index) {
  }

  void _dataProvider_collectionChangedHandler(List<ChangeRecord> changes) {
    _isElementUpdateRequired = true;

    invalidateProperties();
  }

}

