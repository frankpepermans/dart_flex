part of dart_flex;

class ListRenderer extends ListBase {

  Group _scrollTarget;
  
  bool _hasScrolled = false;
  int _firstIndex = 0, _previousFirstIndex = -1, _itemRendererLen = 0;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // dataProvider
  //---------------------------------
  
  @override
  set dataProvider(ObservableList value) {
    if (value != _dataProvider) _previousFirstIndex = -1;
    
    super.dataProvider = value;
  }
  
  //---------------------------------
  // itemRenderers
  //---------------------------------
  
  List<IItemRenderer> _itemRenderers;
  
  List<IItemRenderer> get itemRenderers => _itemRenderers;

  //---------------------------------
  // width
  //---------------------------------
  
  @override
  void set width(int value) {
    if (value != _width) {
      super.width = value;

      if (_dataProvider != null) _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // height
  //---------------------------------
  
  @override
  void set height(int value) {
    if (value != _height) {
      super.height = value;

      if (_dataProvider != null) _updateAfterScrollPositionChanged();
    }
  }
  
  //---------------------------------
  // labelField
  //---------------------------------
  
  @override
  set field(Symbol value) {
    if (value != field) {
      super.field = value;
      
      later > _updateVisibleItemRenderers;
    }
  }
  
  //---------------------------------
  // labelFunction
  //---------------------------------
  
  @override
  set labelFunction(Function value) {
    if (value != labelFunction) {
      super.labelFunction = value;
      
      later > _updateVisibleItemRenderers;
    }
  }

  //---------------------------------
  // orientation
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onOrientationChangedEvent = const EventHook<FrameworkEvent>('orientationChanged');
  Stream<FrameworkEvent> get onOrientationChanged => ListRenderer.onOrientationChangedEvent.forTarget(this);

  String _orientation;
  bool _isOrientationChanged = false;

  String get orientation => _orientation;
  set orientation(String value) {
    if (value != _orientation) {
      _orientation = value;
      _isOrientationChanged = true;

      notify(
        new FrameworkEvent(
          'orientationChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // useSelectionEffects
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onUseSelectionEffectsChangedEvent = const EventHook<FrameworkEvent>('useSelectionEffectsChanged');
  Stream<FrameworkEvent> get onUseSelectionEffectsChanged => ListRenderer.onUseSelectionEffectsChangedEvent.forTarget(this);

  bool _useSelectionEffects = true;
  bool _isUseSelectionEffectsChanged = false;

  bool get useSelectionEffects => _useSelectionEffects;
  set useSelectionEffects(bool value) {
    if (value != _useSelectionEffects) {
      _useSelectionEffects = value;
      _isUseSelectionEffectsChanged = true;

      notify(
        new FrameworkEvent(
          'useSelectionEffectsChanged'
        )
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // itemRenderer
  //---------------------------------

  static const EventHook<FrameworkEvent> onItemRendererFactoryChangedEvent = const EventHook<FrameworkEvent>('itemRendererFactoryChanged');
  Stream<FrameworkEvent> get onItemRendererFactoryChanged => ListRenderer.onItemRendererFactoryChangedEvent.forTarget(this);
  ClassFactory _itemRendererFactory;

  ClassFactory get itemRendererFactory => _itemRendererFactory;
  set itemRendererFactory(ClassFactory value) {
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
  // colWidth
  //---------------------------------

  static const EventHook<FrameworkEvent> onColWidthChangedEvent = const EventHook<FrameworkEvent>('colWidthChanged');
  Stream<FrameworkEvent> get onColWidthChanged => ListRenderer.onColWidthChangedEvent.forTarget(this);
  int _colWidth = 0;

  int get colWidth => _colWidth;
  set colWidth(int value) {
    if (value != _colWidth) {
      _colWidth = value;

      notify(
        new FrameworkEvent(
          'colWidthChanged'
        )
      );
      
      _previousFirstIndex = -1;

      _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // colPercentWidth
  //---------------------------------

  static const EventHook<FrameworkEvent> onColPercentWidthChangedEvent = const EventHook<FrameworkEvent>('colPercentWidthChanged');
  Stream<FrameworkEvent> get onColPercentWidthChanged => ListRenderer.onColPercentWidthChangedEvent.forTarget(this);
  double _colPercentWidth = .0;

  double get colPercentWidth => _colPercentWidth;
  set colPercentWidth(double value) {
    if (value != _colPercentWidth) {
      _colPercentWidth = value;

      notify(
        new FrameworkEvent(
          'colPercentWidthChanged'
        )
      );
      
      _previousFirstIndex = -1;

      _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // rowHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onRowHeightChangedEvent = const EventHook<FrameworkEvent>('rowHeightChanged');
  Stream<FrameworkEvent> get onRowHeightChanged => ListRenderer.onRowHeightChangedEvent.forTarget(this);
  int _rowHeight = 0;

  int get rowHeight => _rowHeight;
  set rowHeight(int value) {
    if (value != _rowHeight) {
      _rowHeight = value;

      notify(
        new FrameworkEvent(
          'rowHeightChanged'
        )
      );
      
      _previousFirstIndex = -1;

      _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // rowPercentHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onRowPercentHeightChangedEvent = const EventHook<FrameworkEvent>('rowPercentHeightChanged');
  Stream<FrameworkEvent> get onRowPercentHeightChanged => ListRenderer.onRowPercentHeightChangedEvent.forTarget(this);
  double _rowPercentHeight = .0;

  double get rowPercentHeight => _rowPercentHeight;
  set rowPercentHeight(double value) {
    if (value != _rowPercentHeight) {
      _rowPercentHeight = value;

      notify(
        new FrameworkEvent(
          'rowPercentHeightChanged'
        )
      );
      
      _previousFirstIndex = -1;

      _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // scrollPosition
  //---------------------------------

  static const EventHook<FrameworkEvent> onListScrollPositionChangedEvent = const EventHook<FrameworkEvent>('listScrollPositionChanged');
  Stream<FrameworkEvent> get onListScrollPositionChanged => ListRenderer.onListScrollPositionChangedEvent.forTarget(this);
  int _scrollPosition = 0;

  int get scrollPosition => _scrollPosition;
  set scrollPosition(int value) {
    if (value != _scrollPosition) {
      _scrollPosition = value;

      notify(
        new FrameworkEvent(
          'listScrollPositionChanged'
        )
      );

      _updateAfterScrollPositionChanged();
    }
  }
  
  //---------------------------------
  // headerScrollPosition
  //---------------------------------

  static const EventHook<FrameworkEvent> onHeaderScrollPositionChangedEvent = const EventHook<FrameworkEvent>('headerScrollPositionChanged');
  Stream<FrameworkEvent> get onHeaderScrollPositionChanged => ListRenderer.onHeaderScrollPositionChangedEvent.forTarget(this);
  int _headerScrollPosition = 0;

  int get headerScrollPosition => _headerScrollPosition;
  set headerScrollPosition(int value) {
    if (value != _headerScrollPosition) {
      _headerScrollPosition = value;

      notify(
        new FrameworkEvent(
          'headerScrollPositionChanged'
        )
      );
    }
  }

  //---------------------------------
  // rowSpacing
  //---------------------------------

  int _rowSpacing = 0;

  int get rowSpacing => _rowSpacing;
  set rowSpacing(int value) {
    if (value != _rowSpacing) {
      _rowSpacing = value;

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // autoScrollSelectionIntoView
  //---------------------------------

  bool _autoScrollSelectionIntoView = false;

  bool get autoScrollSelectionIntoView => _autoScrollSelectionIntoView;
  set autoScrollSelectionIntoView(bool value) {
    if (value != _autoScrollSelectionIntoView) {
      _autoScrollSelectionIntoView = value;

      if (value) later > scrollSelectionIntoView;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ListRenderer({String orientation: 'vertical'}) : super(elementId: null) {
  	_className = 'ListRenderer';
	
    this.orientation = orientation;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void scrollSelectionIntoView() {
    if (
        (_selectedIndex >= 0) &&
        (_itemRenderers != null)
    ) {
      final int pageItemSize = _getPageItemSize();
      final int startIndex = (pageItemSize > 0) ? (_scrollPosition ~/ pageItemSize) : 0;
      final int endIndex = startIndex + ((_itemRenderers != null) ? _itemRenderers.length : 0);
      int offset, target;
      
      if (
          (_selectedIndex < startIndex) || 
          (_selectedIndex >= endIndex)
      ) {
        if (_layout is VerticalLayout) {
          _control.scrollTop = _selectedIndex * _rowHeight;
        } else {
          _control.scrollLeft = _selectedIndex * _colWidth;
        }
      }
    }
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  @override
  void _commitProperties() {
    ILayout defaultLayout;

    if (_isOrientationChanged) {
      _isOrientationChanged = false;
      
      if (orientation == 'horizontal') {
        defaultLayout = new HorizontalLayout();

        _rowHeight = 0;
        _rowPercentHeight = 100.0;

        horizontalScrollPolicy = ScrollPolicy.AUTO;
        verticalScrollPolicy = ScrollPolicy.NONE;
      } else if (orientation == 'vertical') {
        defaultLayout = new VerticalLayout();

        _colWidth = 0;
        _colPercentWidth = 100.0;

        horizontalScrollPolicy = ScrollPolicy.NONE;
        verticalScrollPolicy = ScrollPolicy.AUTO;
      } else if (orientation == 'grid') {
        defaultLayout = new VerticalLayout(constrainToBounds: false);

        _colWidth = 0;
        _colPercentWidth = 100.0;

        verticalScrollPolicy = ScrollPolicy.AUTO;
      }

      defaultLayout.useVirtualLayout = true;
      defaultLayout.gap = _rowSpacing;

      layout = defaultLayout;
    }

    if (_layout != null) _layout.gap = _rowSpacing;
    
    if (_isUseSelectionEffectsChanged) {
      _isUseSelectionEffectsChanged = false;
      
      _itemRenderers.forEach(
        (IItemRenderer renderer) => renderer.autoDrawBackground = _useSelectionEffects    
      );
    }

    super._commitProperties();
  }
  
  @override
  void _createChildren() {
    final DivElement container = new DivElement()
    ..onScroll.listen(_container_scrollHandler)
    ..onTouchCancel.listen(_container_scrollHandler)
    ..onTouchEnd.listen(_container_scrollHandler)
    ..onTouchLeave.listen(_container_scrollHandler)
    ..onTouchStart.listen(_container_scrollHandler)
    ..onTouchEnter.listen(_container_scrollHandler)
    ..onMouseWheel.listen(_container_scrollHandler);

    _scrollTarget = new Group();

    _scrollTarget.autoSize = false;
    _scrollTarget.includeInLayout = false;

    addComponent(_scrollTarget);

    _setControl(container);

    super._createChildren();
  }

  void _removeAllElements() {
    if (_itemRenderers != null) _itemRenderers = <IItemRenderer>[];

    removeAll();

    addComponent(_scrollTarget);
  }

  void _updateRenderer(IItemRenderer renderer) {
    if (_colWidth > 0) {
      renderer.width = _colWidth;
    } else if (_colPercentWidth > .0) {
      renderer.percentWidth = _colPercentWidth;
    }

    if (_rowHeight > 0) {
      renderer.height = _rowHeight;
    } else if (_rowPercentHeight > .0) {
      renderer.percentHeight = _rowPercentHeight;
    }
  }

  static const EventHook<FrameworkEvent> onRendererAddedEvent = const EventHook<FrameworkEvent>('rendererAdded');
  Stream<FrameworkEvent> get onRendererAdded => ListRenderer.onRendererAddedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onRendererRemovedEvent = const EventHook<FrameworkEvent>('rendererRemoved');
  Stream<FrameworkEvent> get onRendererRemoved => ListRenderer.onRendererRemovedEvent.forTarget(this);
  
  void _createElement(Object item, int index) {
    if (_itemRenderers == null) _itemRenderers = new List<IItemRenderer>();

    final IItemRenderer renderer = (_itemRendererFactory.immediateInstance() as IItemRenderer)
      ..index = index
      ..enableHighlight = true
      ..autoDrawBackground = _useSelectionEffects;

    _updateRenderer(renderer);

    _itemRenderers.add(renderer);

    renderer.onControlChanged.listen(_itemRenderer_controlChangedHandler);

    addComponent(renderer);

    notify(
        new FrameworkEvent<IItemRenderer>(
            'rendererAdded',
            relatedObject: renderer
        )
    );
  }
  
  @override
  int _getPageItemSize() {
    if (
        (_dataProvider == null) ||
        (_dataProvider.length == 0)
    ) return super._getPageItemSize();

    return (_layout is VerticalLayout) ? _rowHeight : _colWidth;
  }
  
  @override
  int _getPageOffset() => _scrollPosition;
  
  @override
  int _getPageSize() => (_dataProvider != null) ? ((_dataProvider.length * _getPageItemSize())) : 0;
  
  @override
  void removeComponent(IUIWrapper element, {bool flush: true}) {
    super.removeComponent(element, flush:flush);

    if (_itemRenderers != null) _itemRenderers.remove(element);
    
    notify(
      new FrameworkEvent<IUIWrapper>(
          'rendererRemoved',
          relatedObject: element
      )    
    );
  }

  bool _updateElements() {
    if (_dataProvider == null) return false;
    
    final bool hasWidth = ((_colWidth > 0) || (_colPercentWidth > .0));
    final bool hasHeight = ((_rowHeight > 0) || (_rowPercentHeight > .0));

    if (
        (_itemRendererFactory != null) &&
        hasWidth &&
        hasHeight
    ) {
      final bool isVerticalLayout = (_layout is VerticalLayout);
      int elementsRequired;

      if (isVerticalLayout) {
        if (
            (_height == 0) || 
            (_rowHeight == 0)
        ) {
          elementsRequired = 0;
        } else {
          elementsRequired = min(
              (_height ~/ _rowHeight + 2),
              _dataProvider.length
          );
        }
      } else {
        if (
            (_width == 0) || 
            (_colWidth == 0)
        ) {
          elementsRequired = 0;
        } else {
          elementsRequired = min(
              (_width ~/ _colWidth + 2),
              _dataProvider.length
          );
        }
      }

      Object element;
      final int existingLen = (_itemRenderers != null) ? _itemRenderers.length : 0;
      final int len = elementsRequired - existingLen;
      int i;

      for (i=len; i<0; i++) removeComponent(_itemRenderers.removeLast());
      
      for (i=0; i<len; i++) _createElement(null, i);
      
      if (_scrollTarget != null) {
        if (isVerticalLayout) {
          _scrollTarget.width = 1;

          if (_rowHeight > 0) {
            _scrollTarget.height = _dataProvider.length * _rowHeight;
          }
        } else {
          if (_colWidth > 0) {
            _scrollTarget.width = _dataProvider.length * _colWidth;
          }

          _scrollTarget.height = 1;
        }
      }

      if (len > 0) {
        _updateVisibleItemRenderers(ignorePreviousIndex: true);
        _updateLayout();

        return true;
      }
    }

    return false;
  }

  void _updateAfterScrollPositionChanged() {
    if (_dataProvider != null) {
      if (_updateElements()) return;
      
      _updateVisibleItemRenderers();
    }
    
    later > _updateLayout;
  }

  void _updateVisibleItemRenderers({bool ignorePreviousIndex: false}) {
    if (_itemRenderers == null) return;
    
    final int pageItemSize = _getPageItemSize();
    
    _firstIndex = (pageItemSize > 0) ? (_scrollPosition ~/ pageItemSize) : 0;
    
    if (
        ignorePreviousIndex ||
        (_firstIndex != _previousFirstIndex)
    ) {
      _itemRendererLen = (_itemRenderers != null) ? _itemRenderers.length : 0;
      
      final int dpLen = _dataProvider.length;
      final int len = _firstIndex + _itemRendererLen;

      dynamic data;
      bool isRendererShown;
      int rendererIndex = 0;
      int i;

      _itemRenderers.sort(_itemRenderer_sortHandler);
      
      _previousFirstIndex = _firstIndex;
      
      _childWrappers = _itemRenderers.sublist(0);

      for (i=_firstIndex; i<len; i++) {
        isRendererShown = (i < dpLen);
        
        data = isRendererShown ? _dataProvider[i] : null;
        
        if (
            (data != null) &&
            (_labelFunction != null)
        ) data = _labelFunction(data);
        
        _updateRenderer(
            _itemRenderers[rendererIndex++]
            ..index = i
            ..includeInLayout = isRendererShown
            ..visible = isRendererShown
            ..selected = (i == _selectedIndex)
            ..data = data
            ..field = _field
        );
      }
    }
  }
  
  int _itemRenderer_sortHandler(IItemRenderer rendererA, IItemRenderer rendererB) {
    int sortIndexA = rendererA.index - _firstIndex;
    int sortIndexB = rendererB.index - _firstIndex;
    
    sortIndexA = (sortIndexA >= _itemRendererLen) ? -sortIndexA : (sortIndexA < 0) ? sortIndexA + 1000000 : sortIndexA;
    sortIndexB = (sortIndexB >= _itemRendererLen) ? -sortIndexB : (sortIndexB < 0) ? sortIndexB + 1000000 : sortIndexB;

    return sortIndexA.compareTo(sortIndexB);
  }

  void _handleMouseInteraction(Event event) {
    if (event.type == 'mousedown') {
      final Element target = event.currentTarget as Element;
      final IItemRenderer itemRenderer = _itemRenderers.firstWhere(
          (IItemRenderer renderer) => (renderer.control == target),
          orElse: () => null
      );
      
      if (itemRenderer != null) {
        _previousFirstIndex = -1;
        
        selectedIndex = (_scrollPosition ~/ _getPageItemSize()) + _itemRenderers.indexOf(itemRenderer);

        selectedItem = _dataProvider[selectedIndex];
      }
    }
  }

  void _container_scrollHandler(Event event) => _updateScrollPosition();
  
  void _updateScrollPosition() {
    _hasScrolled = true;
    
    if (_layout is VerticalLayout) {
      scrollPosition = _control.scrollTop;
      headerScrollPosition = _control.scrollLeft;
    } else {
      scrollPosition = _control.scrollLeft;
      headerScrollPosition = _control.scrollTop;
    }
  }
  
  void _updateSelection() {
    _updateVisibleItemRenderers();
    
    if (_autoScrollSelectionIntoView) later > scrollSelectionIntoView;
  }

  void _itemRenderer_controlChangedHandler(FrameworkEvent<Element> event) {
    event.relatedObject.onMouseDown.listen(_handleMouseInteraction);
  }
  
  @override
  void _dataProvider_collectionChangedHandler(List<ChangeRecord> changes) {
    _previousFirstIndex = -1;
    
    _updateAfterScrollPositionChanged();
  }
}