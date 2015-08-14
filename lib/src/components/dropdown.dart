part of dart_flex;

class Dropdown extends ListBase {
  
  @event Stream<FrameworkEvent> onItemRendererFactoryChanged;
  @event Stream<FrameworkEvent> onNumRowsDisplayed;
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  EditableText _input;
  Button _handle;
  ListRenderer _list;
  bool _isDropdownShown = false;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // itemRenderer
  //---------------------------------
  
  ItemRendererFactory _itemRendererFactory;
  
  ItemRendererFactory get itemRendererFactory => _itemRendererFactory;
  set itemRendererFactory(ItemRendererFactory value) {
    if (value != _itemRendererFactory) {
      _itemRendererFactory = value;
  
      notify(
        new FrameworkEvent(
          'itemRendererFactoryChanged'
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // numRowsDisplayed
  //---------------------------------
  
  int _numRowsDisplayed = 6;
  
  int get numRowsDisplayed => _numRowsDisplayed;
  set numRowsDisplayed(int value) {
    if (value != _numRowsDisplayed) {
      _numRowsDisplayed = value;
  
      notify(
        new FrameworkEvent(
          'numRowsDisplayedChanged'
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // rowHeight
  //---------------------------------
  
  int _rowHeight = 22;
  
  int get rowHeight => _rowHeight;
  set rowHeight(int value) {
    if (value != _rowHeight) {
      _rowHeight = value;
  
      notify(
        new FrameworkEvent(
          'rowHeightChanged'
        )
      );
  
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // inactiveHandler
  //---------------------------------
  
  @override
  set inactiveHandler(InactiveHandler value) {
    super.inactiveHandler = value;
    
    if (_list != null) _list.inactiveHandler = value;
  }
  
  //---------------------------------
  // dataProvider
  //---------------------------------
  
  @override
  set dataProvider(ObservableList<dynamic> value) {
    super.dataProvider = value;
    
    if (_list != null) _list.dataProvider = value;
  }
  
  //---------------------------------
  // presentationHandler
  //---------------------------------
  
  @override
  set presentationHandler(CompareHandler value) {
    super.presentationHandler = value;
        
    if (_list != null) _list.presentationHandler = value;
  }
  
  //---------------------------------
  // labelField
  //---------------------------------
  
  @override
  set field(Symbol value) {
    super.field = value;
            
    if (_list != null) _list.field = value;
  }
  
  //---------------------------------
  // labelFunction
  //---------------------------------
  
  @override
  set labelFunction(Function value) {
    super.labelFunction = value;
                
    if (_list != null) _list.labelFunction = value;
  }
  
  //---------------------------------
  // allowMultipleSelection
  //---------------------------------
  
  @override
  set allowMultipleSelection(bool value) {
    super.allowMultipleSelection = value;
                    
    if (_list != null) _list.allowMultipleSelection = value;
  }
  
  //---------------------------------
  // selectedIndex
  //---------------------------------
  
  @override
  set selectedIndex(int value) {
    super.selectedIndex = value;
                        
    if (_list != null) _list.selectedIndex = value;
  }
  
  //---------------------------------
  // selectedIndices
  //---------------------------------
  
  @override
  set selectedIndices(ObservableList<int> value) {
    super.selectedIndices = value;
                            
    if (_list != null) _list.selectedIndices = value;
  }
  
  //---------------------------------
  // selectedItem
  //---------------------------------
  
  @override
  set selectedItem(dynamic value) {
    super.selectedItem = value;
                                
    if (_list != null) _list.selectedItem = value;
  }
  
  //---------------------------------
  // selectedItems
  //---------------------------------
  
  @override
  set selectedItems(ObservableList<dynamic> value) {
    super.selectedItems = value;
                                    
    if (_list != null) _list.selectedItems = value;
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Dropdown() : super(elementId: null) {
    _className = 'Dropdown';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    layout = new HorizontalLayout()..gap = 0;
    
    _input = new EditableText()
      ..className = 'dropdown-input'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onTextChanged.listen((_) => open());
    
    _handle = new Button()
      ..className = 'dropdown-handle'
      ..width = 26
      ..percentHeight = 100.0
      ..onButtonClick.listen((_) => toggle());
    
    _list = new ListRenderer()
      ..className = 'dropdown-list'
      ..useEvenOdd = false
      ..includeInLayout = false
      ..disableRecycling = false
      ..autoScrollSelectionIntoView = false
      ..rowSpacing = 0
      ..useSelectionEffects = true
      ..autoManageScrollBars = true
      ..allowMultipleSelection = false
      ..onSelectedItemChanged.listen((FrameworkEvent<dynamic> event) => handleListSelection(event.relatedObject));
    
    addComponent(_input);
    addComponent(_handle);
  }
  
  @override 
  void commitProperties() {
    super.commitProperties();
    
    if (_list != null) {
      _list.itemRendererFactory = _itemRendererFactory;
      _list.rowHeight = _rowHeight;
      _list.labelFunction = _labelFunction;
      _list.dataProvider = _dataProvider;
      _list.field = _field;
      _list.allowMultipleSelection = _allowMultipleSelection;
    }
  }
  
  @override
  void _updateSelection() {
    _list.selectedIndex = _selectedIndex;
    _list.selectedIndices = _selectedIndices;
    _list.selectedItem = _selectedItem;
    _list.selectedItems = _selectedItems;
    _list.inactiveHandler = _inactiveHandler;
  }
  
  Future<bool> invalidateListPosition() async {
    await reflowManager.invocationFrame;
    
    if (!_isDropdownShown) return false;
    
    commitListPosition();
    
    invalidateListPosition();
    
    return true;
  }
  
  void toggle() {
    _isDropdownShown = !_isDropdownShown;
    
    if (_isDropdownShown) addComponent(_list);
    else removeComponent(_list, flush: false);
    
    commitListPosition();
    
    invalidateListPosition();
  }
  
  void open() {
    if (!_isDropdownShown) toggle();
  }
  
  void close() {
    if (_isDropdownShown) toggle();
  }
  
  void commitListPosition() {
    final Point P = control.documentOffset;
    
    _list.paddingLeft = P.x + 2;
    _list.paddingTop = P.y + _input.height + 2;
    _list.width = width;
    _list.height = _numRowsDisplayed * _rowHeight;
    
    invalidateLayout();
  }
  
  void handleListSelection(dynamic item) {
    _input.text = itemToLabel(item);
    
    toggle();
  }
  
  String itemToLabel(dynamic item) {
    if (labelFunction != null) return labelFunction(item);
    
    return item.toString();
  }
  
  @override
  void _updateElements() {}
}