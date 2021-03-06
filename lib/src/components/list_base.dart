part of dart_flex;

typedef bool InactiveHandler(dynamic data);
typedef bool InvalidHandler(dynamic data);

class ListBase extends Group {
  
  @event Stream<FrameworkEvent> onDataProviderChanged;
  @event Stream<FrameworkEvent> onFieldChanged;
  @event Stream<FrameworkEvent> onLabelFunctionChanged;
  @event Stream<FrameworkEvent> onAllowMultipleSelectionChanged;
  @event Stream<FrameworkEvent> onSelectedIndexChanged;
  @event Stream<FrameworkEvent> onSelectedIndicesChanged;
  @event Stream<FrameworkEvent> onSelectedItemChanged;
  @event Stream<FrameworkEvent> onSelectedItemsChanged;

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
      
      invalidateProperties();
    }
  }

  //---------------------------------
  // dataProvider
  //---------------------------------

  ObservableList<dynamic> _dataProvider;

  ObservableList<dynamic> get dataProvider => _dataProvider;
  set dataProvider(ObservableList<dynamic> value) {
    if (value != _dataProvider) {
      _dataProvider = value;
      _isElementUpdateRequired = true;
      
      if (value != null) _streamSubscriptionManager.add(
          'list_base_dataProviderChanges', 
          value.listChanges.listen(_dataProvider_collectionChangedHandler),
          flushExisting: true
      );
      else _streamSubscriptionManager.flushIdent('list_base_dataProviderChanges');
      
      notify('dataProviderChanged', value);
      
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
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // labelField
  //---------------------------------
  
  Symbol _field;

  Symbol get field => _field;
  set field(Symbol value) {
    if (value != _field) {
      _field = value;
      
      notify('fieldChanged');
      
      invalidateProperties();
    }
  }

  //---------------------------------
  // labelFunction
  //---------------------------------

  Function _labelFunction;

  Function get labelFunction => _labelFunction;
  set labelFunction(Function value) {
    if (value != _labelFunction) {
      _labelFunction = value;
      
      notify('labelFunctionChanged');
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // allowMultipleSelection
  //---------------------------------
  
  bool _allowMultipleSelection = false;
  
  bool get allowMultipleSelection => _allowMultipleSelection;
  set allowMultipleSelection(bool value) {
    if (value != _allowMultipleSelection) {
      _allowMultipleSelection = value;
      
      notify('allowMultipleSelectionChanged', value);
      
      invalidateProperties();
    }
  }

  //---------------------------------
  // selectedIndex
  //---------------------------------

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
        
        notify('selectedItemChanged', _selectedItem);
      }

      notify('selectedIndexChanged', value);

      invokeLaterSingle('updateSelection', _updateSelection);
    }
  }
  
  //---------------------------------
  // selectedIndices
  //---------------------------------
  
  ObservableList<int> _selectedIndices = new ObservableList<int>();

  ObservableList<int> get selectedIndices => _selectedIndices;
  set selectedIndices(ObservableList<int> value) {
    if (value != _selectedIndices) {
      _selectedIndices = value;
      _selectedItems.clear();
      
      if (_dataProvider != null && value != null) {
        int len = _dataProvider.length, i;
        
        for (i=0; i<len; i++) {
          if (value.contains(i)) _selectedItems.add(_dataProvider[i]);
        }
      }
      
      notify('selectedItemsChanged', _selectedItems);

      notify('selectedIndicesChanged', value);

      invokeLaterSingle('updateSelection', _updateSelection);
    }
  }

  //---------------------------------
  // selectedItem
  //---------------------------------

  dynamic _selectedItem;

  dynamic get selectedItem => _selectedItem;
  set selectedItem(dynamic value) {
    if (value != _selectedItem) {
      _selectedItem = value;
      
      if (_dataProvider != null) {
        _selectedIndex = _dataProvider.indexOf(value);
        
        notify('selectedIndexChanged', _selectedIndex);
      }

      notify('selectedItemChanged', value);

      invokeLaterSingle('updateSelection', _updateSelection);
    }
  }
  
  //---------------------------------
  // selectedItems
  //---------------------------------
  
  ObservableList<dynamic> _selectedItems = new ObservableList<dynamic>();
  
  ObservableList<dynamic> get selectedItems => _selectedItems;
  set selectedItems(ObservableList<dynamic> value) {
    if (value != _selectedItems) {
      _selectedItems = value;
      _selectedIndices.clear();
      
      if (_dataProvider != null && value != null) {
        int len = _dataProvider.length, i;
        
        for (i=0; i<len; i++) {
          if (value.contains(_dataProvider[i])) _selectedIndices.add(i);
        }
      }
      
      notify('selectedIndicesChanged', _selectedIndices);
  
      notify('selectedItemsChanged', value);
  
      invokeLaterSingle('updateSelection', _updateSelection);
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

    _childWrappers = <BaseComponent>[];
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

