part of dart_flex;

class Header extends HGroup {
  
  @event Stream<FrameworkEvent> onLabelChanged;
  @event Stream<FrameworkEvent> onLeftSideItemsChanged;
  @event Stream<FrameworkEvent> onRightSideItemsChanged;
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  RichText _headerLabel;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // label
  //---------------------------------

  String _label;
  bool _isLabelChanged = false;

  String get label => _label;
  set label(String value) {
    if (value != _label) {
      _label = value;
      _isLabelChanged = true;

      notify('labelChanged');

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // labelCSSClassName
  //---------------------------------
  
  String _labelCSSClassName = 'header-title';
  
  String get labelCSSClassName => _labelCSSClassName;
  set labelCSSClassName(String value) {
    if (value != _labelCSSClassName) {
      _labelCSSClassName = value;
      
      if (_headerLabel != null) _headerLabel.cssClasses = <String>[value];
    }
  }
  
  //---------------------------------
  // leftSideContainer
  //---------------------------------

  HGroup _leftSideContainer;

  HGroup get leftSideContainer => _leftSideContainer;
  
  //---------------------------------
  // rightSideContainer
  //---------------------------------

  HGroup _rightSideContainer;

  HGroup get rightSideContainer => _rightSideContainer;
  
  //---------------------------------
  // leftSideItems
  //---------------------------------

  ObservableList _leftSideItems;
  bool _isLeftSideItemsChanged = false;

  ObservableList get leftSideItems => _leftSideItems;
  set leftSideItems(ObservableList value) {
    if (value != _leftSideItems) {
      _leftSideItems = value;
      _isLeftSideItemsChanged = true;
      
      if (value != null) _streamSubscriptionManager.add(
          'header_leftListChanges', 
          value.listChanges.listen(_leftSideItems_collectionChangedHandler),
          flushExisting: true
      );
      else _streamSubscriptionManager.flushIdent('header_leftListChanges');

      notify('leftSideItemsChanged');

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // rightSideItems
  //---------------------------------

  ObservableList _rightSideItems;
  bool _isRightSideItemsChanged = false;

  ObservableList get rightSideItems => _rightSideItems;
  set rightSideItems(ObservableList value) {
    if (value != _rightSideItems) {
      _rightSideItems = value;
      _isRightSideItemsChanged = true;
      
      if (value != null) _streamSubscriptionManager.add(
          'header_rightListChanges', 
          value.listChanges.listen(_rightSideItems_collectionChangedHandler),
          flushExisting: true
      );
      else _streamSubscriptionManager.flushIdent('header_rightListChanges');

      notify('rightSideItemsChanged');

      invalidateProperties();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Header({String elementId: null}) : super(elementId: elementId) {
  	_className = 'Header';
	
    leftSideItems = new ObservableList();
    rightSideItems = new ObservableList();
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    _headerLabel = new RichText()
    ..paddingTop = 7
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..autoSize = true
    ..align = 'center'
    ..text = _label
    ..cssClasses = <String>[_labelCSSClassName];
    
    _leftSideContainer = new HGroup()
    ..percentHeight = 100.0;
    
    _rightSideContainer = new HGroup()
    ..percentHeight = 100.0;
    
    _rightSideContainer.layout.align = 'right';
    
    addComponent(new Group()..width = 3);
    addComponent(_leftSideContainer);
    addComponent(_headerLabel);
    addComponent(_rightSideContainer);
    addComponent(new Group()..width = 3);

    super.createChildren();
  }
  
  @override
  void commitProperties() {
    super.commitProperties();

    if (
        _isLabelChanged &&
        (_headerLabel != null)
    ) {
      _isLabelChanged = false;

      _headerLabel.richText = _label;
    }
    
    if (
        _isLeftSideItemsChanged &&
        (_leftSideContainer != null)
    ) {
      _isLeftSideItemsChanged = false;
      
      _updateItems(_leftSideContainer, _leftSideItems);
    }
    
    if (
        _isRightSideItemsChanged &&
        (_rightSideContainer != null)
    ) {
      _isRightSideItemsChanged = false;
      
      _updateItems(_rightSideContainer, _rightSideItems);
    }
    
    if (
      (_leftSideContainer != null) &&
      (_rightSideContainer != null)
    ) {
      final int len = max(_leftSideContainer.childWrappers.length, _rightSideContainer.childWrappers.length);
          
      _leftSideContainer.width = max(1, _leftSideContainer.layout.gap * (len - 1) + 28 * len);
      _rightSideContainer.width = max(1, _rightSideContainer.layout.gap * (len - 1) + 28 * len);
    }
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _updateItems(HGroup group, ObservableList dataProvider) {
    final int len = dataProvider.length;
    BaseComponent child;
    int i = group.childWrappers.length;
    
    while (i > 0) {
      child = group.childWrappers[--i];
      
      if (dataProvider.indexOf(child) == -1) group.removeComponent(child);
    }
    
    for (i=0; i<len; i++) {
      child = dataProvider[i];
      
      if (group.childWrappers.indexOf(child) == -1) group.addComponent(child);
    }
    
    invalidateProperties();
  }
  
  void _leftSideItems_collectionChangedHandler(List<ListChangeRecord> listChanges) {
    _isLeftSideItemsChanged = true;
    
    invalidateProperties();
  }
  
  void _rightSideItems_collectionChangedHandler(List<ListChangeRecord> listChanges) {
    _isRightSideItemsChanged = true;
    
    invalidateProperties();
  }
}

