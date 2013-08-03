part of dartflex;

class ListWrapper extends Group {

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
  Stream<FrameworkEvent> get onDataProviderChanged => ListWrapper.onDataProviderChangedEvent.forTarget(this);
  ListCollection _dataProvider;

  ListCollection get dataProvider => _dataProvider;
  set dataProvider(ListCollection value) {
    if (value != _dataProvider) {
      if (_dataProvider != null) {
        _dataProvider.ignore(
            CollectionEvent.COLLECTION_CHANGED,
            _dataProvider_collectionChangedHandler
        );
      }

      _dataProvider = value;
      _isElementUpdateRequired = true;

      if (value != null) {
        value.onCollectionChanged.listen(_dataProvider_collectionChangedHandler);
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
  // labelFunction
  //---------------------------------

  static const EventHook<FrameworkEvent> onLabelFunctionChangedEvent = const EventHook<FrameworkEvent>('labelFunctionChanged');
  Stream<FrameworkEvent> get onLabelFunctionChanged => ListWrapper.onLabelFunctionChangedEvent.forTarget(this);
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
  Stream<FrameworkEvent> get onSelectedIndexChanged => ListWrapper.onSelectedIndexChangedEvent.forTarget(this);
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
  Stream<FrameworkEvent> get onSelectedItemChanged => ListWrapper.onSelectedItemChangedEvent.forTarget(this);
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

  ListWrapper({String elementId: null}) : super(elementId: elementId) {
  	_className = 'ListWrapper';
  }

  //---------------------------------
  //
  // Operator overloads
  //
  //---------------------------------

  int operator +(Object item) {
    if (_dataProvider == null) {
      dataProvider = new ListCollection();
    }

    return _dataProvider.addItem(item);
  }

  int operator -(Object item) {
    if (_dataProvider == null) {
      dataProvider = new ListCollection();
    }

    return _dataProvider.removeItem(item);
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
      }
    }
  }

  void _removeAllElements() {
    if (_control != null) {
      while (_control.children.length > 0) {
        _control.children.removeLast();
      }
    }

    _children = new List<IUIWrapper>();
  }

  void _updateElements() {
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

  void _dataProvider_collectionChangedHandler(FrameworkEvent event) {
    _isElementUpdateRequired = true;

    invalidateProperties();
  }

}

