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
  
  static const EventHook<FrameworkEvent> onRedrawEvent = const EventHook<FrameworkEvent>('redraw');
  Stream<FrameworkEvent> get onRedraw => ListRenderer.onRedrawEvent.forTarget(this);
  
  //---------------------------------
  // inactiveHandler
  //---------------------------------
  
  set inactiveHandler(InactiveHandler value) {
    if (
        (value != _inactiveHandler) &&
        (_itemRenderers != null)
    ) _itemRenderers.forEach(
      (IItemRenderer renderer) => renderer.inactiveHandler = value    
    );
    
    super.inactiveHandler = value;
  }
  
  //---------------------------------
  // dataProvider
  //---------------------------------
  
  @override
  set dataProvider(ObservableList value) {
    _previousFirstIndex = -1;
    _firstIndex = 0;
    
    super.dataProvider = value;
  }
  
  //---------------------------------
  // itemRenderers
  //---------------------------------
  
  List<IItemRenderer> _itemRenderers, _removedItemRenderers;
  
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
      
      invokeLaterSingle('updateVisibleItemRenderers', _updateVisibleItemRenderers);
    }
  }
  
  //---------------------------------
  // labelFunction
  //---------------------------------
  
  @override
  set labelFunction(Function value) {
    if (value != labelFunction) {
      super.labelFunction = value;
      
      invokeLaterSingle('updateVisibleItemRenderers', _updateVisibleItemRenderers);
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
      _firstIndex = -1;
      
      scrollPosition = 0;
      
      if (_control != null) _control.scrollLeft = _control.scrollTop = 0;

      notify(
        new FrameworkEvent(
          'orientationChanged'
        )
      );

      invalidateProperties();
      
      invokeLaterSingle('updateAfterScrollPositionChanged', _updateAfterScrollPositionChanged);
    }
  }
  
  //---------------------------------
  // autoManageScrollBars
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onAutoManageScrollBarsChangedEvent = const EventHook<FrameworkEvent>('autoManageScrollBarsChanged');
  Stream<FrameworkEvent> get onAutoManageScrollBarsChanged => ListRenderer.onAutoManageScrollBarsChangedEvent.forTarget(this);

  bool _autoManageScrollBars = true;

  bool get autoManageScrollBars => _autoManageScrollBars;
  set autoManageScrollBars(bool value) {
    if (value != _autoManageScrollBars) {
      _autoManageScrollBars = value;
      _isOrientationChanged = true;

      notify(
        new FrameworkEvent(
          'autoManageScrollBarsChanged'
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
  // useEvenOdd
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onUseEvenOddChangedEvent = const EventHook<FrameworkEvent>('useEvenOddChanged');
  Stream<FrameworkEvent> get onUseEvenOddChanged => ListRenderer.onUseEvenOddChangedEvent.forTarget(this);
  
  bool _useEvenOdd = false;
  bool _isUseEvenOddChanged = false;
  
  bool get useEvenOdd => _useEvenOdd;
  set useEvenOdd(bool value) {
    if (value != _useEvenOdd) {
      _useEvenOdd = value;
      _isUseEvenOddChanged = true;
  
      notify(
        new FrameworkEvent(
          'useEvenOddChanged'
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
  ItemRendererFactory _itemRendererFactory;

  ItemRendererFactory get itemRendererFactory => _itemRendererFactory;
  set itemRendererFactory(ItemRendererFactory value) {
    if (value != _itemRendererFactory) {
      _itemRendererFactory = value;
      
      _removeAllElements();

      notify(
        new FrameworkEvent(
          'itemRendererFactoryChanged'
        )
      );

      invalidateProperties();
      
      invokeLaterSingle('updateAfterScrollPositionChanged', _updateAfterScrollPositionChanged);
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
      
      _forceRefresh();
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
      
      _forceRefresh();
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
      
      _forceRefresh();
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
      
      _forceRefresh();
    }
  }

  //---------------------------------
  // scrollPosition
  //---------------------------------

  static const EventHook<FrameworkEvent> onListScrollPositionChangedEvent = const EventHook<FrameworkEvent>('listScrollPositionChanged');
  Stream<FrameworkEvent> get onListScrollPositionChanged => ListRenderer.onListScrollPositionChangedEvent.forTarget(this);
  int _scrollPosition = 0;
  
  void setScrollPositionExternally(int value) {
    if (value != _scrollPosition) {
      _scrollPosition = value;
      
      if (_layout is VerticalLayout) _control.scrollTop = _scrollPosition;
      else _control.scrollLeft = _scrollPosition;

      invokeLaterSingle('updateAfterScrollPositionChanged', _updateAfterScrollPositionChanged);
    }
  }

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

  bool _autoScrollSelectionIntoView = true;

  bool get autoScrollSelectionIntoView => _autoScrollSelectionIntoView;
  set autoScrollSelectionIntoView(bool value) {
    if (value != _autoScrollSelectionIntoView) {
      _autoScrollSelectionIntoView = value;

      if (value) invokeLaterSingle('scrollSelectionIntoView', scrollSelectionIntoView);
    }
  }
  
  //---------------------------------
  // selectedIndex
  //---------------------------------
  
  set selectedIndex(int value) {
    super.selectedIndex = value;
    
    _forceRefresh();
  }
  
  //---------------------------------
  // selectedIndices
  //---------------------------------
  
  set selectedIndices(ObservableList<int> value) {
    super.selectedIndices = value;
    
    _forceRefresh();
  }

  //---------------------------------
  // selectedItem
  //---------------------------------
  
  set selectedItem(dynamic value) {
    super.selectedItem = value;
    
    _forceRefresh();
  }
  
  //---------------------------------
  // selectedItems
  //---------------------------------
  
  set selectedItems(ObservableList<dynamic> value) {
    super.selectedItems = value;
    
    _forceRefresh();
  }
  
  //---------------------------------
  // disableRecycling
  //---------------------------------

  bool _disableRecycling = false;

  bool get disableRecycling => _disableRecycling;
  set disableRecycling(bool value) {
    if (value != _disableRecycling) {
      _disableRecycling = value;

      _forceRefresh();
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
  
  @override
  void createChildren() {
    final DivElement container = new DivElement();
    
    _streamSubscriptionManager.add(
        'list_base_containerScroll', 
        container.onScroll.listen(_container_scrollHandler)
    );

    _scrollTarget = new Group();
    
    _scrollTarget.autoSize = false;
    _scrollTarget.includeInLayout = false;
    
    _scrollTarget.className = 'ListScrollTarget';

    addComponent(_scrollTarget);

    _setControl(container);

    super.createChildren();
  }
  
  @override
  void commitProperties() {
    _updateOrientationIfNeeded();

    if (_layout != null) _layout.gap = _rowSpacing;
    
    if (
        _isUseSelectionEffectsChanged &&
        (_itemRenderers != null)
    ) {
      _isUseSelectionEffectsChanged = false;
      
      _itemRenderers.forEach(
        (IItemRenderer renderer) => renderer.autoDrawBackground = _useSelectionEffects    
      );
    }
    
    if (_isUseEvenOddChanged) {
      _isUseEvenOddChanged = false;
      
      _updateAfterScrollPositionChanged();
    }

    super.commitProperties();
  }
  
  void scrollSelectionIntoView() {
    if (
        (_selectedIndex >= 0) &&
        (_itemRenderers != null)
    ) {
      final int pageItemSize = _getPageItemSize();
      final int startIndex = (pageItemSize > 0) ? (_scrollPosition ~/ pageItemSize) : 0;
      final int endIndex = startIndex + ((_itemRenderers != null) ? _itemRenderers.length : 0);
      
      if (
          (_selectedIndex < startIndex) || 
          (_selectedIndex >= endIndex)
      ) {
        if (_layout is VerticalLayout) _control.scrollTop = _selectedIndex * _rowHeight;
        else _control.scrollLeft = _selectedIndex * _colWidth;
      }
    }
  }
  
  void setScrollPosition({int horizontalScrollValue: null, int verticalScrollValue: null}) {
    if (_control == null) return;
    
    if (horizontalScrollValue != null)  _control.scrollLeft = horizontalScrollValue;
    if (verticalScrollValue != null)    _control.scrollTop = verticalScrollValue;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _removeAllElements() {
    if (_itemRenderers != null) {
      int i = _itemRenderers.length;
      
      while (i > 0) removeComponent(_itemRenderers[--i]);
    }
    
    _removedItemRenderers = <IItemRenderer>[];
  }

  void _updateRenderer(IItemRenderer renderer) {
    if (_colWidth > 0) renderer.width = _colWidth;
    else if (_colPercentWidth > .0) renderer.percentWidth = _colPercentWidth;

    if (_rowHeight > 0) renderer.height = _rowHeight;
    else if (_rowPercentHeight > .0) renderer.percentHeight = _rowPercentHeight;
  }

  static const EventHook<FrameworkEvent> onRendererAddedEvent = const EventHook<FrameworkEvent>('rendererAdded');
  Stream<FrameworkEvent> get onRendererAdded => ListRenderer.onRendererAddedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onRendererRemovedEvent = const EventHook<FrameworkEvent>('rendererRemoved');
  Stream<FrameworkEvent> get onRendererRemoved => ListRenderer.onRendererRemovedEvent.forTarget(this);
  
  void _createElement(dynamic item, int index) {
    if (_itemRenderers == null) _itemRenderers = new List<IItemRenderer>();

    IItemRenderer renderer;
    
    if (_removedItemRenderers.length > 0) renderer = _removedItemRenderers.removeLast()
        ..index = index
        ..autoDrawBackground = _useSelectionEffects;
    else {
      renderer = _itemRendererFactory.immediateInstance()
        //..useMatrixTransformations = true
        ..index = index
        ..enableHighlight = true
        ..autoDrawBackground = _useSelectionEffects;
      
      renderer.streamSubscriptionManager.add(
          'list_base_rendererControlChanged', 
          renderer.onControlChanged.listen(
            (FrameworkEvent event) {
              final target = event.currentTarget as IItemRenderer;
              
              target.streamSubscriptionManager.flushIdent('list_base_rendererControlChanged');
              
              target.streamSubscriptionManager.add(
                  'list_base_rendererMouseDown', 
                  event.relatedObject.onMouseDown.listen(_handleMouseInteraction)
              );
            }
          )
      );
    }

    _updateRenderer(renderer);

    _itemRenderers.add(renderer);

    addComponent(renderer);

    notify(
        new FrameworkEvent<IItemRenderer>(
            'rendererAdded',
            relatedObject: renderer
        )
    );
  }
  
  void _forceRefresh() {
    _previousFirstIndex = -1;

    _updateAfterScrollPositionChanged();
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
    
    if (_removedItemRenderers == null) _removedItemRenderers = <IItemRenderer>[];
    
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
        } else if (_disableRecycling) {
          elementsRequired = _dataProvider.length;
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
        } else if (_disableRecycling) {
          elementsRequired = _dataProvider.length;
        } else {
          elementsRequired = min(
              (_width ~/ _colWidth + 2),
              _dataProvider.length
          );
        }
      }

      final int existingLen = (_itemRenderers != null) ? _itemRenderers.length : 0;
      final int len = elementsRequired - existingLen;
      int i;

      for (i=len; i<0; i++) {
        IItemRenderer renderer = _itemRenderers.removeLast();
        
        removeComponent(renderer, flush: false);
        
        _removedItemRenderers.add(renderer);
      }
      
      for (i=0; i<len; i++) _createElement(null, i);
      
      if (_scrollTarget != null) {
        if (isVerticalLayout) {
          _scrollTarget.width = 1;

          if (_rowHeight > 0) _scrollTarget.height = _dataProvider.length * _rowHeight;
        } else {
          if (_colWidth > 0) _scrollTarget.width = _dataProvider.length * _colWidth;

          _scrollTarget.height = 1;
        }
      }

      if (len > 0) {
        _updateVisibleItemRenderers(ignorePreviousIndex: true);
        updateLayout();

        return true;
      }
    }

    return false;
  }

  void _updateAfterScrollPositionChanged() {
    if (_dataProvider != null && (_updateElements() || _disableRecycling)) return;
    
    _invalidateAfterScrollPositionChanged();
  }
  
  void _invalidateAfterScrollPositionChanged() {
    if (_dataProvider != null) _updateVisibleItemRenderers();
    
    updateLayout();
    
    notify(
      new FrameworkEvent('redraw')    
    );
  }

  void _updateVisibleItemRenderers({bool ignorePreviousIndex: false}) {
    if (
        (_itemRenderers == null) ||
        (_dataProvider == null)
    ) return;
    
    final int pageItemSize = _getPageItemSize();
    
    _firstIndex = _disableRecycling ? 0 : (pageItemSize > 0) ? (_scrollPosition ~/ pageItemSize) : 0;
    
    if (
        ignorePreviousIndex ||
        (_firstIndex != _previousFirstIndex)
    ) {
      _itemRendererLen = (_itemRenderers != null) ? _itemRenderers.length : 0;
      
      final int dpLen = _dataProvider.length;
      final int len = _firstIndex + _itemRendererLen;

      dynamic data;
      bool isRendererShown;
      int i, rendererIndex = 0;

      _itemRenderers.sort(_itemRenderer_sortHandler);
      
      _previousFirstIndex = _firstIndex;
      
      _childWrappers = new List<IItemRenderer>.from(_itemRenderers);
      
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
            ..selected = (
                _useSelectionEffects && 
                (
                    (i == _selectedIndex) ||
                    (_selectedIndices.contains(i))
                )
            )
            ..data = data
            ..inactiveHandler = _inactiveHandler
            ..field = _field
            ..cssClasses = _useEvenOdd ? ((i % 2 == 0) ? const <String>['even'] : const <String>['odd']) : null
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
        final int pageItemSize = _getPageItemSize();
        
        if (pageItemSize is int && pageItemSize <= 0) return;
        
        final int index = _disableRecycling ? _itemRenderers.indexOf(itemRenderer) : (_scrollPosition ~/ _getPageItemSize()) + _itemRenderers.indexOf(itemRenderer);
        
        if (_allowMultipleSelection) {
          selectedIndex = -1;
          selectedItem = null;
          
          if (selectedIndices.contains(index)) {
            selectedIndices.remove(index);
            selectedItems.remove(_dataProvider[index]);
          } else {
            selectedIndices.add(index);
            selectedItems.add(_dataProvider[index]);
          }
          
          notify(
              new FrameworkEvent<Iterable<int>>(
                  'selectedIndicesChanged',
                  relatedObject: _selectedIndices
              )
          );
      
          notify(
              new FrameworkEvent<Iterable<dynamic>>(
                'selectedItemsChanged',
                relatedObject: _selectedItems
              )
          );
          
          invokeLaterSingle('updateSelection', _updateSelection);
          
          _forceRefresh();
        } else {
          selectedIndex = index;
          selectedItem = _dataProvider[index];
          
          selectedIndices.clear();
          selectedItems.clear();
        }
      }
    }
  }

  void _container_scrollHandler(Event event) => _updateScrollPosition();
  
  void _updateScrollPosition() {
    _hasScrolled = true;
    
    if (_layout is VerticalLayout) {
      _control.scrollTop = scrollPosition = _rowHeight * (_control.scrollTop ~/ _rowHeight);
      headerScrollPosition = _control.scrollLeft;
    } else {
      _control.scrollLeft = scrollPosition = _colWidth * (_control.scrollLeft ~/ _colWidth);
      headerScrollPosition = _control.scrollTop;
    }
  }
  
  void _updateSelection() {
    _updateVisibleItemRenderers(ignorePreviousIndex: true);
    
    if (_autoScrollSelectionIntoView) invokeLaterSingle('scrollSelectionIntoView', scrollSelectionIntoView);
  }
  
  void _updateOrientationIfNeeded() {
    if (_isOrientationChanged) {
      ILayout defaultLayout;
      
      _isOrientationChanged = false;
      
      if (orientation == 'horizontal') {
        defaultLayout = new HorizontalLayout();

        _rowHeight = 0;
        _rowPercentHeight = 100.0;
        
        if (_autoManageScrollBars) {
          horizontalScrollPolicy = ScrollPolicy.AUTO;
          verticalScrollPolicy = ScrollPolicy.NONE;
        }
      } else if (orientation == 'vertical') {
        defaultLayout = new VerticalLayout();

        _colWidth = 0;
        _colPercentWidth = 100.0;
        
        if (_autoManageScrollBars) {
          horizontalScrollPolicy = ScrollPolicy.NONE;
          verticalScrollPolicy = ScrollPolicy.AUTO;
        }
      } else if (orientation == 'grid') {
        defaultLayout = new VerticalLayout(constrainToBounds: false);

        _colWidth = 0;
        _colPercentWidth = 100.0;
        
        if (_autoManageScrollBars) verticalScrollPolicy = ScrollPolicy.AUTO;
      }

      defaultLayout.useVirtualLayout = true;
      defaultLayout.gap = _rowSpacing;

      layout = defaultLayout;
    }
  }
  
  @override
  void _dataProvider_collectionChangedHandler(List<ListChangeRecord> changes) => _forceRefresh();
}