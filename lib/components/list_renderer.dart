part of dartflex;

class ListRenderer extends ListBase {

  List<IItemRenderer> _itemRenderers;

  Group _scrollTarget;
  
  bool _hasScrolled = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // width
  //---------------------------------

  void set width(int value) {
    if (value != _width) {
      super.width = value;

      if (_dataProvider != null) {
        _updateAfterScrollPositionChanged();
      }
    }
  }

  //---------------------------------
  // height
  //---------------------------------

  void set height(int value) {
    if (value != _height) {
      super.height = value;

      if (_dataProvider != null) {
        _updateAfterScrollPositionChanged();
      }
    }
  }
  
  //---------------------------------
  // labelField
  //---------------------------------

  set labelField(String value) {
    if (value != labelField) {
      super.labelField = value;
      
      later > _updateVisibleItemRenderers;
    }
  }
  
  //---------------------------------
  // labelFunction
  //---------------------------------

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

      _updateAfterScrollPositionChanged();
    }
  }

  //---------------------------------
  // scrollPosition
  //---------------------------------

  static const EventHook<FrameworkEvent> onScrollPositionChangedEvent = const EventHook<FrameworkEvent>('scrollPositionChanged');
  Stream<FrameworkEvent> get onScrollPositionChanged => ListRenderer.onScrollPositionChangedEvent.forTarget(this);
  int _scrollPosition = 0;

  int get scrollPosition => _scrollPosition;
  set scrollPosition(int value) {
    if (value != _scrollPosition) {
      _scrollPosition = value;

      notify(
        new FrameworkEvent(
          'scrollPositionChanged'
        )
      );

      _updateAfterScrollPositionChanged();
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
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

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

    if (_layout != null) {
      _layout.gap = _rowSpacing;
    }
    
    if (_isUseSelectionEffectsChanged) {
      _isUseSelectionEffectsChanged = false;
      
      _itemRenderers.forEach(
        (IItemRenderer renderer) => renderer.autoDrawBackground = _useSelectionEffects    
      );
    }

    super._commitProperties();
  }

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
    if (_itemRenderers != null) {
      _itemRenderers.removeRange(0, _itemRenderers.length);
    }

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
  
  void _createElement(Object item, int index) {
    if (_itemRenderers == null) {
      _itemRenderers = new List<IItemRenderer>();
    }

    final IItemRenderer renderer = (_itemRendererFactory.immediateInstance() as IItemRenderer)
      ..index = index
      ..autoDrawBackground = _useSelectionEffects;

    _updateRenderer(renderer);

    _itemRenderers.add(renderer);

    renderer.onControlChanged.listen(_itemRenderer_controlChangedHandler);

    addComponent(renderer);

    notify(
        new FrameworkEvent(
            'rendererAdded',
            relatedObject: renderer
        )
    );

    /*Future rendererFuture = _itemRendererFactory.futureInstance();

    rendererFuture.then(
      (Object result) {
        IItemRenderer renderer;

        if (result is InstanceMirror) {
          renderer = instanceMirror.reflectee as IItemRenderer;
        } else if (result is IItemRenderer) {
          renderer = result as IItemRenderer;
        }

        Object dataToSet = (_labelFunction != null) ? _labelFunction(item) : item;

        if (_colWidth > 0) {
          renderer.width = _colWidth;
        } else {
          renderer.percentWidth = _colPercentWidth;
        }

        if (_rowHeight > 0) {
          renderer.height = _rowHeight;
        } else {
          renderer.percentHeight = _colPercentHeight;
        }

        renderer.data = dataToSet;

        _itemRenderers.add(renderer);

        renderer['controlChanged'] = _itemRenderer_controlChangedHandler;

        add(renderer);
      }
    );*/
  }

  int _getPageItemSize() {
    if (
        (_dataProvider == null) ||
        (_dataProvider.length == 0)
    ) {
      return super._getPageItemSize();
    }

    return (_layout is VerticalLayout) ? _rowHeight : _colWidth;
  }

  int _getPageOffset() {
    return _scrollPosition;
  }

  int _getPageSize() {
    return (_dataProvider != null) ? ((_dataProvider.length * _getPageItemSize())) : 0;
  }

  void removeComponent(IUIWrapper element) {
    super.removeComponent(element);

    if (_itemRenderers != null) {
      _itemRenderers.remove(element);
    }
  }

  bool _updateElements() {
    if (_dataProvider == null) {
      return false;
    }
    
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

      for (i=len; i<0; i++) {
        removeComponent(_itemRenderers.removeLast());
      }

      for (i=0; i<len; i++) {
        _createElement(null, i);
      }

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
        _updateAfterScrollPositionChanged();

        return true;
      }
    }

    return false;
  }

  void _updateAfterScrollPositionChanged() {
    if (
        (_dataProvider != null) &&
        !_updateElements()
    ) {
      _updateVisibleItemRenderers();
    }

    _updateLayout();
  }

  void _updateVisibleItemRenderers() {
    if (_itemRenderers == null) {
      return;
    }
    
    final int dpLen = _dataProvider.length;
    final int pageItemSize = _getPageItemSize();
    final int firstIndex = (pageItemSize > 0) ? (_scrollPosition ~/ pageItemSize) : 0;
    final int irLen = (_itemRenderers != null) ? _itemRenderers.length : 0;
    final int len = firstIndex + irLen;

    dynamic data;
    IItemRenderer rendererA, rendererB;
    bool isRendererShown;
    int rendererIndex = 0;
    int i, sortIndexA, sortIndexB;

    //
    // START: sort the renderers, this will minimize the amount of updates needed when recycling
    //

    _itemRenderers.sort(
      (rendererA, rendererB) {
        sortIndexA = rendererA.index - firstIndex;
        sortIndexB = rendererB.index - firstIndex;

        if (sortIndexA >= irLen) {
          sortIndexA = -sortIndexA;
        } else if (sortIndexA < 0) {
          sortIndexA += 1000000;
        }

        if (sortIndexB >= irLen) {
          sortIndexB = -sortIndexB;
        } else if (sortIndexB < 0) {
          sortIndexB += 1000000;
        }

        return (sortIndexA < sortIndexB) ? -1 : (sortIndexA > sortIndexB) ? 1 : 0;
      }
    );
    
    _childWrappers = _itemRenderers.sublist(0);

    //
    // END
    //

    for (i=firstIndex; i<len; i++) {
      isRendererShown = (i < dpLen);
      
      data = isRendererShown ? _dataProvider[i] : null;
      
      if (
        (data != null) &&
        (_labelFunction != null)
      ) {
        data = _labelFunction(data);
      }

      _updateRenderer(
        _itemRenderers[rendererIndex++]
        ..index = i
        ..includeInLayout = isRendererShown
        ..visible = isRendererShown
        ..selected = (i == _selectedIndex)
        ..data = data
        ..field = _labelField
      );
    }
  }

  void _handleMouseInteraction(Event event) {
    final Element target = event.currentTarget as Element;
    final int firstIndex = _scrollPosition ~/ _getPageItemSize();

    IItemRenderer renderer;
    Object newSelectedItem;
    int i = _itemRenderers.length;

    while (i > 0) {
      renderer = _itemRenderers[--i];

      if (event.type == 'mousedown') {
        if (renderer.control == target) {
          selectedIndex = firstIndex + i;

          newSelectedItem = _dataProvider[selectedIndex];

          renderer.selected = true;
        } else {
          renderer.selected = false;
        }
      } else {
        if (renderer.control == target) {
          renderer.state = event.type;
        } else {
          renderer.state = 'mouseout';
        }
      }
    }

    selectedItem = newSelectedItem;
  }

  void _container_scrollHandler(Event event) {
    _updateScrollPosition();
  }
  
  void _updateScrollPosition() {
    final int pos = (_layout is VerticalLayout) ? _control.scrollTop : _control.scrollLeft;
    
    _hasScrolled = true;
    
    if (pos != _scrollPosition) {
      scrollPosition = pos;
    } else {
      notify(
          new FrameworkEvent(
              'scrollPositionChanged'
          )
      );
    }
  }

  void _dataProvider_collectionChangedHandler(List<ChangeRecord> changes) {
    _updateAfterScrollPositionChanged();
  }

  void _itemRenderer_controlChangedHandler(FrameworkEvent event) {
    final DivElement renderer = event.relatedObject as DivElement;

    renderer.onMouseOver.listen(_handleMouseInteraction);
    renderer.onMouseOut.listen(_handleMouseInteraction);
    renderer.onMouseDown.listen(_handleMouseInteraction);
    renderer.onMouseUp.listen(_handleMouseInteraction);
  }
}



