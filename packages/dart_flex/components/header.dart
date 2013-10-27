part of dart_flex;

class Header extends Group {
  
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
  
  static const EventHook<FrameworkEvent> onLabelChangedEvent = const EventHook<FrameworkEvent>('labelChanged');
  Stream<FrameworkEvent> get onLabelChanged => Header.onLabelChangedEvent.forTarget(this);

  String _label;
  bool _isLabelChanged = false;

  String get label => _label;
  set label(String value) {
    if (value != _label) {
      _label = value;
      _isLabelChanged = true;

      notify(
        new FrameworkEvent(
          'labelChanged'
        )
      );

      invalidateProperties();
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
  
  static const EventHook<FrameworkEvent> onLeftSideItemsChangedEvent = const EventHook<FrameworkEvent>('leftSideItemsChanged');
  Stream<FrameworkEvent> get onLeftSideItemsChanged => Header.onLeftSideItemsChangedEvent.forTarget(this);

  ObservableList _leftSideItems;
  bool _isLeftSideItemsChanged = false;

  ObservableList get leftSideItems => _leftSideItems;
  set leftSideItems(ObservableList value) {
    if (value != _leftSideItems) {
      /*if (_leftSideItems != null) {
        _leftSideItems.ignore(
            CollectionEvent.COLLECTION_CHANGED, 
            _leftSideItems_collectionChangedHandler
        );
      }*/
      
      _leftSideItems = value;
      _isLeftSideItemsChanged = true;
      
      if (value != null) {
        value.changes.listen(_leftSideItems_collectionChangedHandler);
      }

      notify(
        new FrameworkEvent(
          'leftSideItemsChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // rightSideItems
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onRightSideItemsChangedEvent = const EventHook<FrameworkEvent>('rightSideItemsChanged');
  Stream<FrameworkEvent> get onRightSideItemsChanged => Header.onRightSideItemsChangedEvent.forTarget(this);

  ObservableList _rightSideItems;
  bool _isRightSideItemsChanged = false;

  ObservableList get rightSideItems => _rightSideItems;
  set rightSideItems(ObservableList value) {
    if (value != _rightSideItems) {
      /*if (_rightSideItems != null) {
        _rightSideItems.ignore(
            CollectionEvent.COLLECTION_CHANGED, 
            _rightSideItems_collectionChangedHandler
        );
      }*/
      
      _rightSideItems = value;
      _isRightSideItemsChanged = true;
      
      if (value != null) {
        value.changes.listen(_rightSideItems_collectionChangedHandler);
      }

      notify(
        new FrameworkEvent(
          'rightSideItemsChanged'
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
  
  void _createChildren() {
    _layout = new AbsoluteLayout();
    
    _headerLabel = new RichText()
    ..width = 400
    ..height = 20
    ..align = 'center'
    ..text = _label
    ..cssClasses = ['header-title'];
    
    _leftSideContainer = new HGroup();
    
    _rightSideContainer = new HGroup();
    
    _rightSideContainer.layout.align = 'right';
    
    _headerLabel.onWidthChanged.listen(_updateWidth);
    _headerLabel.onHeightChanged.listen(_updateHeight);
    
    addComponent(_leftSideContainer);
    addComponent(_rightSideContainer);
    addComponent(_headerLabel);

    super._createChildren();
  }
  
  void _commitProperties() {
    super._commitProperties();

    if (
        _isLabelChanged &&
        (_headerLabel != null)
    ) {
      _isLabelChanged = false;

      _headerLabel.text = _label;
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
  }
  
  void _updateLayout() {
    if (
        (_width > 0) &&
        (_height > 0)
    ) {
      IUIWrapper child;
      int maxHeight = 0;
      int i = _leftSideItems.length;
      
      _headerLabel.x = (_width * .5 - _headerLabel._width * .5).toInt();
      _headerLabel.y = (_height * .5 - _headerLabel._height * .5).toInt();
      
      while (i > 0) {
        child = _leftSideItems[--i];
        
        if (child.height > maxHeight) {
          maxHeight = child.height;
        }
      }
      
      _leftSideContainer.height = maxHeight;
      _leftSideContainer.x = 10;
      _leftSideContainer.y = (_height * .5 - _leftSideContainer.height * .5).toInt();
      _leftSideContainer.width = _headerLabel.x - 20;
      
      maxHeight = 0;
      
      i = _rightSideItems.length;
      
      while (i > 0) {
        child = _rightSideItems[--i];
        
        if (child.height > maxHeight) {
          maxHeight = child.height;
        }
      }
      
      _rightSideContainer.height = maxHeight;
      _rightSideContainer.x = _width - _leftSideContainer.width - 10;
      _rightSideContainer.y = (_height * .5 - _rightSideContainer.height * .5).toInt();
      _rightSideContainer.width = _leftSideContainer.width;
    }
    
    super._updateLayout();
  }
  
  void _updateWidth(FrameworkEvent event) {
    invalidateProperties();
  }
  
  void _updateHeight(FrameworkEvent event) {
    invalidateProperties();
  }
  
  void _updateItems(HGroup group, ObservableList dataProvider) {
    IUIWrapper child;
    final int len = dataProvider.length;
    int i = group.childWrappers.length;
    
    while (i > 0) {
      child = group.childWrappers[--i];
      
      if (dataProvider.indexOf(child) == -1) {
        group.removeComponent(child);
      }
    }
    
    for (i=0; i<len; i++) {
      child = dataProvider[i];
      
      if (group.childWrappers.indexOf(child) == -1) {
        child.onHeightChanged.listen(
            (FrameworkEvent event) => invalidateProperties()
        );
        
        group.addComponent(child);
      }
    }
    
    invalidateProperties();
  }
  
  void _leftSideItems_collectionChangedHandler(List<ChangeRecord> changes) {
    _isLeftSideItemsChanged = true;
    
    invalidateProperties();
  }
  
  void _rightSideItems_collectionChangedHandler(List<ChangeRecord> changes) {
    _isRightSideItemsChanged = true;
    
    invalidateProperties();
  }
}

