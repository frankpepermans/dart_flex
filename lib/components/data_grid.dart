part of dart_flex;

typedef String SortHandler(dynamic data, Symbol propertySymbol);
typedef int CompareHandler(dynamic dataA, dynamic dataB);
typedef void HeaderMouseHandler(IItemRenderer header);

class DataGrid extends ListBase {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  List<IItemRenderer> _headerItemRenderers;

  VGroup _gridContainer;
  HGroup _headerContainer;
  ListRenderer _list;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onRendererAddedEvent = const EventHook<FrameworkEvent>('rendererAdded');
  Stream<FrameworkEvent> get onRendererAdded => DataGrid.onRendererAddedEvent.forTarget(this);

  //---------------------------------
  // columns
  //---------------------------------

  static const EventHook<FrameworkEvent> onColumnsChangedEvent = const EventHook<FrameworkEvent>('columnsChanged');
  Stream<FrameworkEvent> get onColumnsChanged => DataGrid.onColumnsChangedEvent.forTarget(this);
  
  ObservableList<DataGridColumn> _columns;
  bool _isColumnsChanged = false;

  ObservableList<DataGridColumn> get columns => _columns;
  set columns(ObservableList<DataGridColumn> value) {
    if (value != _columns) {
      /*if (_columns != null) {
        _columns.ignoreEventType(
            CollectionEvent.COLLECTION_CHANGED,
            _columns_collectionChangedHandler
        );
      }*/

      _columns = value;
      _isColumnsChanged = true;

      if (value != null) {
        value.changes.listen(_columns_collectionChangedHandler);
      }

      notify(
        new FrameworkEvent(
          'columnsChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // headerMouseOverHandler
  //---------------------------------

  HeaderMouseHandler _headerMouseOverHandler;

  HeaderMouseHandler get headerMouseOverHandler => _headerMouseOverHandler;
  set headerMouseOverHandler(HeaderMouseHandler value) {
    if (value != _headerMouseOverHandler) {
      _headerMouseOverHandler = value;

      later > _invalidateHeaderHoverHandlers;
    }
  }
  
  //---------------------------------
  // headerMouseOutHandler
  //---------------------------------

  HeaderMouseHandler _headerMouseOutHandler;

  HeaderMouseHandler get headerMouseOutHandler => _headerMouseOutHandler;
  set headerMouseOutHandler(HeaderMouseHandler value) {
    if (value != _headerMouseOutHandler) {
      _headerMouseOutHandler = value;

      later > _invalidateHeaderHoverHandlers;
    }
  }

  //---------------------------------
  // headerHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onHeaderHeightChangedEvent = const EventHook<FrameworkEvent>('headerHeightChanged');
  Stream<FrameworkEvent> get onHeaderHeightChanged => DataGrid.onHeaderHeightChangedEvent.forTarget(this);
  int _headerHeight = 24;

  int get headerHeight => _headerHeight;
  set headerHeight(int value) {
    if (value != _headerHeight) {
      _headerHeight = value;

      notify(
        new FrameworkEvent(
          'headerHeightChanged'
        )
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // rowHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onRowHeightChangedEvent = const EventHook<FrameworkEvent>('rowHeightChanged');
  Stream<FrameworkEvent> get onRowHeightChanged => DataGrid.onRowHeightChangedEvent.forTarget(this);
  int _rowHeight = 30;

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
  // columnSpacing
  //---------------------------------

  static const EventHook<FrameworkEvent> onColumnSpacingChangedEvent = const EventHook<FrameworkEvent>('columnSpacingChanged');
  Stream<FrameworkEvent> get onColumnSpacingChanged => DataGrid.onColumnSpacingChangedEvent.forTarget(this);
  int _columnSpacing = 1;

  int get columnSpacing => _columnSpacing;
  set columnSpacing(int value) {
    if (value != _columnSpacing) {
      _columnSpacing = value;

      notify(
        new FrameworkEvent(
          'columnSpacingChanged'
        )
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // rowSpacing
  //---------------------------------

  static const EventHook<FrameworkEvent> onRowSpacingChangedEvent = const EventHook<FrameworkEvent>('rowSpacingChanged');
  Stream<FrameworkEvent> get onRowSpacingChanged => DataGrid.onRowSpacingChangedEvent.forTarget(this);
  int _rowSpacing = 1;

  int get rowSpacing => _rowSpacing;
  set rowSpacing(int value) {
    if (value != _rowSpacing) {
      _rowSpacing = value;

      notify(
        new FrameworkEvent(
          'rowSpacingChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // useSelectionEffects
  //---------------------------------

  static const EventHook<FrameworkEvent> onUseSelectionEffectsChangedEvent = const EventHook<FrameworkEvent>('useSelectionEffectsChanged');
  Stream<FrameworkEvent> get onUseSelectionEffectsChanged => DataGrid.onUseSelectionEffectsChangedEvent.forTarget(this);
  
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
  // dataProvider
  //---------------------------------
  
  @override
  set dataProvider(ObservableList value) {
    if (
        (value != _dataProvider) &&
        (value != null) &&
        (_presentationHandler != null)
    ) value.sort(_presentationHandler);
    
    super.dataProvider = value;
  }
  
  //---------------------------------
  // sortHandler
  //---------------------------------

  SortHandler sortHandler;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  DataGrid() : super(elementId: null) {
	   _className = 'DataGrid';
	   
	   _horizontalScrollPolicy = ScrollPolicy.AUTO;
	   _verticalScrollPolicy = ScrollPolicy.AUTO;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void setScrollTarget(DataGridItemRenderer target, int offset) {
    final int low = target.y;
    final int high = target.y + offset;
    final int lowCompare = _list._scrollPosition;
    final int highCompare = _list._scrollPosition + _list._height;
    
    if (
        (low < lowCompare) ||
        (high >= highCompare)
    ) target._control.scrollIntoView(ScrollAlignment.CENTER);
  }
  
  void refreshColumns() {
    _isColumnsChanged = true;
    
    notify(
      new FrameworkEvent(
        'columnsChanged'
      )
    );

    invalidateProperties();
  }
  
  void refreshColumnData() {
    _list._itemRenderers.forEach(
      (DataGridItemRenderer renderer) => renderer._itemRendererInstances.forEach(
        (ItemRenderer subRenderer) => subRenderer._invalidateData()
      )
    );
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  @override
  void _createChildren() {
    final DivElement container = new DivElement();

    _gridContainer = new VGroup(gap: 0)
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..className = 'data-grid-container';

    _headerContainer = new HGroup(gap: _columnSpacing)
    ..percentWidth = 100.0
    ..height = _headerHeight
    ..autoSize = false
    ..className = 'data-grid-header-container';

    _list = new ListRenderer(orientation: 'grid')
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..colPercentWidth = 100.0
    ..rowSpacing = _rowSpacing
    ..rowHeight = _rowHeight
    ..dataProvider = _dataProvider
    ..itemRendererFactory = new ClassFactory(constructorMethod: DataGridItemRenderer.construct)
    ..useSelectionEffects = _useSelectionEffects;

    _gridContainer.addComponent(_headerContainer);
    _gridContainer.addComponent(_list);

    addComponent(_gridContainer);

    _setControl(container);

    _list.onRendererAdded.listen(_list_rendererAddedHandler);
    _list.onHeaderScrollPositionChanged.listen(_list_headerScrollChangedHandler);
    _list.onSelectedItemChanged.listen(_list_selectedItemChangedHandler);
    
    _updateScrollPolicy();

    super._createChildren();
  }
  
  @override
  void _commitProperties() {
    super._commitProperties();
    
    if (
      _isElementUpdateRequired &&
      (_dataProvider != null) &&
      (_presentationHandler != null)
    ) {
      _dataProvider.sort(_presentationHandler);
    }

    if (
        _isColumnsChanged &&
        (_headerContainer != null)
    ) {
      _isColumnsChanged = false;

      _updateColumnsAndHeaders();
    }
    
    if (_isUseSelectionEffectsChanged) {
      _isUseSelectionEffectsChanged = false;
      
      if (_list != null) _list.useSelectionEffects = _useSelectionEffects;
    }
  }

  void _removeAllElements() {
    if (_headerItemRenderers != null) _headerItemRenderers.removeRange(0, _headerItemRenderers.length);
    
    if (_headerContainer != null) _headerContainer.removeAll();
  }

  void _updateElements() {
    if (_list != null) _list.dataProvider = _dataProvider;
  }

  void _updateColumnsAndHeaders() {
    DataGridColumn column;
    IItemRenderer header;
    int i, len;

    _removeAllElements();

    _headerItemRenderers = new List<IItemRenderer>();

    if (_columns != null) {
      len = _columns.length;

      for (i=0; i<len; i++) {
        column = _columns[i];
        
        if (column._isActive) {
          header = column.headerItemRendererFactory.immediateInstance()
            ..height = _headerHeight
            ..data =  column.headerData
            ..['buttonClick'] = _header_clickHandler;

          if (column.width > 0) {
            header.width = column.width;
          } else {
            header.percentWidth = column.percentWidth;
          }
          
          _headerItemRenderers.add(header);

          _headerContainer.addComponent(header);
        }
      }

      if (
          (_list != null) &&
          (_list._itemRenderers != null)
      ) {
        _list._itemRenderers.forEach(
          (DataGridItemRenderer renderer) {
            renderer.gap = _columnSpacing;
            
            if (renderer.columns != _columns) {
              renderer.columns = _columns;
            } else {
              renderer._refreshColumns();
            }
          }
        );
      }
    }
  }

  void _header_clickHandler(FrameworkEvent event) {
    final HeaderData headerData = event.relatedObject as HeaderData;

    /*if (event.relatedObject['isAscSort'] == null) event.relatedObject['isAscSort'] = true;

    final bool isAscSort = event.relatedObject['isAscSort'];*/
    
    presentationHandler = (dynamic itemA, dynamic itemB) => _list_dynamicSortHandler(itemA, itemB, headerData.field, /*isAscSort*/true);

    //event.relatedObject['isAscSort'] = !isAscSort;
  }
  
  @override
  void _updateLayout() {
    if (
        (_list != null) &&
        (_columns != null)
    ) {
      DataGridColumn column;
      int i = _columns.length;
      int w = 0;
      int tw = 0;
      int remainingWidth = 0;
      double procCount = .0;

      while (i > 0) {
        column = _columns[--i];
        
        if (column._isActive) {
          if (column.percentWidth > .0) {
            procCount += column.percentWidth;

            tw += column.minWidth;
          } else if (column.width > .0) {
            w += column.width + ((i > 0) ? _columnSpacing : 0);
          }
        }
      }

      i = _columns.length;

      tw += w;

      remainingWidth = _width - w;

      remainingWidth = (remainingWidth < 0) ? 0 : remainingWidth;

      if (procCount > .0) {
        while (i > 0) {
          column = _columns[--i];

          if (
              column._isActive &&
              (column.percentWidth > .0)
          ) {
            w += max(column.minWidth, (remainingWidth * column.percentWidth ~/ procCount));
          }
        }
      }

      _list.rowHeight = _rowHeight;
      _list.colWidth = w;
      _list.horizontalScrollPolicy = (tw > _width) ? ScrollPolicy.AUTO : ScrollPolicy.NONE;

      if (_headerContainer != null) {
        _headerContainer.width = w;
        _headerContainer.height = _headerHeight;
      }
    }

    super._updateLayout();
  }

  void _list_rendererAddedHandler(FrameworkEvent event) {
    final DataGridItemRenderer renderer = event.relatedObject as DataGridItemRenderer
      ..gap = _columnSpacing
      ..columns = _columns
      .._grid = this
      ..onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler);
    
    invalidateProperties();
    
    notify(
      new FrameworkEvent(
        'rendererAdded',
        relatedObject: renderer
      )
    );
  }
  
  void _list_selectedItemChangedHandler(FrameworkEvent event) {
    selectedItem = event.relatedObject;
    selectedIndex = _list.selectedIndex;
  }
  
  void _list_headerScrollChangedHandler(FrameworkEvent event) {
    final String newValue = (_headerContainer.x - _list._headerScrollPosition).toString() + 'px';
    
    if (_headerContainer._control.style.left != newValue) _headerContainer._control.style.left = newValue;
  }
  
  int _list_dynamicSortHandler(dynamic itemA, dynamic itemB, Symbol propertySymbol, bool isAscSort) {
    if (sortHandler != null) {
      String strA = sortHandler(itemA, propertySymbol);
      String strB = sortHandler(itemB, propertySymbol);
      
      strA = (strA == null) ? '' : strA;
      strB = (strB == null) ? '' : strB;
      
      return isAscSort ? strA.compareTo(strB) : strB.compareTo(strA);
    }
    
    dynamic pvA = itemA[propertySymbol];
    dynamic pvB = itemB[propertySymbol];
    dynamic valA = (pvA is bool) ? pvA ? 1 : 0 : pvA;
    dynamic valB = (pvB is bool) ? pvB ? 1 : 0 : pvB;
    
    if (valA == null && valB == null) {
      return 0;
    } else if (valB == null) {
      return -1;
    } else if (valA == null) {
      return 1;
    }
    
    return isAscSort ? valA.toString().compareTo(valB.toString()) : valB.toString().compareTo(valA.toString());
  }

  void _columns_collectionChangedHandler(List<ChangeRecord> changes) {
    _isColumnsChanged = true;

    invalidateProperties();
  }
  
  @override
  void _dataProvider_collectionChangedHandler(List<ChangeRecord> changes) {
    super._dataProvider_collectionChangedHandler(changes);

    if (_list != null) _list._updateVisibleItemRenderers();
  }
  
  @override
  void _updateScrollPolicy() {
    if (_list != null) {
      _list.horizontalScrollPolicy = _horizontalScrollPolicy;
      _list.verticalScrollPolicy = _verticalScrollPolicy;
    }
  }
  
  void _invalidateHeaderHoverHandlers() {
    if (_headerItemRenderers != null) {
      _headerItemRenderers.forEach(
        (ItemRenderer header) {
          if (_headerMouseOutHandler != null) {
            header.onMouseOut.listen(
                (FrameworkEvent event) => _headerMouseOutHandler(event.currentTarget as IItemRenderer)
            );
          }
          
          if (_headerMouseOverHandler != null) {
            header.onMouseOver.listen(
                (FrameworkEvent event) => _headerMouseOverHandler(event.currentTarget as IItemRenderer)    
            );
          }
        }
      );
    }
  }
  
  void _renderer_dataPropertyChangedHandler(FrameworkEvent event) {
    IItemRenderer itemRenderer = event.relatedObject as IItemRenderer;
    
    itemRenderer.control.scrollIntoView(ScrollAlignment.CENTER);
  }
}