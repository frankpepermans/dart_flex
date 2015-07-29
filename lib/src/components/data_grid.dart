part of dart_flex;

typedef int CompareHandler(dynamic dataA, dynamic dataB);
typedef void HeaderMouseHandler(IItemRenderer header);
typedef IItemRenderer ItemRendererHandler(DataGridItemRenderer rowRenderer, DataGridColumn column, int index, Function defaultHandler);

class DataGrid extends ListBase {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  List<IHeaderItemRenderer> _headerItemRenderers;
  
  List<IHeaderItemRenderer> get headerItemRenderers => _headerItemRenderers;

  VGroup _gridContainer;
  HGroup _headerBounds, _headerContainer;
  ListRenderer _list;
  bool _isSelectedIndexUpdateRequired = false;
  
  ListRenderer get list => _list;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onRendererAddedEvent = const EventHook<FrameworkEvent>('rendererAdded');
  Stream<FrameworkEvent> get onRendererAdded => DataGrid.onRendererAddedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onRendererRemovedEvent = const EventHook<FrameworkEvent>('rendererRemoved');
  Stream<FrameworkEvent> get onRendererRemoved => DataGrid.onRendererRemovedEvent.forTarget(this);

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
      _columns = value;
      _isColumnsChanged = true;

      if (value != null) _streamSubscriptionManager.add(
          'data_grid_columnsChange', 
          value.listChanges.listen(_columns_collectionChangedHandler),
          flushExisting: true
      );

      notify(
        new FrameworkEvent(
          'columnsChanged'
        )
      );

      invalidateLayout();
    }
  }
  
  //---------------------------------
  // dataGridItemRendererFactory
  //---------------------------------

  static const EventHook<FrameworkEvent> onDataGridItemRendererFactoryChangedEvent = const EventHook<FrameworkEvent>('dataGridItemRendererFactoryChanged');
  Stream<FrameworkEvent> get onDataGridItemRendererFactoryChanged => DataGrid.onDataGridItemRendererFactoryChangedEvent.forTarget(this);
  ItemRendererFactory _dataGridItemRendererFactory = new ItemRendererFactory<DataGridItemRenderer>(constructorMethod: DataGridItemRenderer.construct);

  ItemRendererFactory get dataGridItemRendererFactory => _dataGridItemRendererFactory;
  set dataGridItemRendererFactory(ItemRendererFactory value) {
    if (value != _dataGridItemRendererFactory) {
      _dataGridItemRendererFactory = value;
      
      if (_list != null) _list.itemRendererFactory = value;
    }
  }
  
  //---------------------------------
  // listClasses
  //---------------------------------

  static const EventHook<FrameworkEvent> onListCSSClassesChangedEvent = const EventHook<FrameworkEvent>('listCssClassesChanged');
  Stream<FrameworkEvent> get onListCSSClassesChanged => DataGrid.onListCSSClassesChangedEvent.forTarget(this);
  List<String> _listCssClasses = <String>[];

  List<String> get listCssClasses => _listCssClasses;

  set listCssClasses(List<String> value) {
    if (value != _listCssClasses) {
      _listCssClasses = value;
      
      if (_list != null) _list.cssClasses = _listCssClasses;

      notify(
        new FrameworkEvent('listCssClassesChanged')
      );
    }
  }
  
  //---------------------------------
  // headless
  //---------------------------------

  bool _headless = false;

  bool get headless => _headless;
  set headless(bool value) {
    if (value != _headless) {
      _headless = value;
      
      if (_headerBounds != null) _headerBounds.visible = _headerBounds.includeInLayout = !value;
      if (_headerContainer != null) _headerContainer.visible = _headerContainer.includeInLayout = !value;

      if (_headerItemRenderers != null) {
        _headerItemRenderers.forEach(
          (IHeaderItemRenderer headerRenderer) => headerRenderer.visible = headerRenderer.includeInLayout = !value
        );
      }
    }
  }
  
  //---------------------------------
  // itemRendererHandler
  //---------------------------------

  ItemRendererHandler _itemRendererHandler;

  ItemRendererHandler get itemRendererHandler => _itemRendererHandler;
  set itemRendererHandler(ItemRendererHandler value) {
    if (value != _itemRendererHandler) {
      _itemRendererHandler = value;
      
      if (_list != null) _list._itemRenderers.forEach(
        (DataGridItemRenderer R) => R.refreshColumns()    
      );
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

      invokeLaterSingle('invalidateHeaderHoverHandlers', _invalidateHeaderHoverHandlers);
    }
  }
  
  //---------------------------------
  // allowHeaderColumnSorting
  //---------------------------------

  bool _allowHeaderColumnSorting = false;

  bool get allowHeaderColumnSorting => _allowHeaderColumnSorting;
  set allowHeaderColumnSorting(bool value) {
    _allowHeaderColumnSorting = value;
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
  // inactiveHandler
  //---------------------------------
  
  set inactiveHandler(InactiveHandler value) {
    super.inactiveHandler = value;
    
    if (_list != null) _list.inactiveHandler = value;
  }
  
  //---------------------------------
  // scrollPosition
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onListScrollPositionChangedEvent = const EventHook<FrameworkEvent>('listScrollPositionChanged');
  Stream<FrameworkEvent> get onListScrollPositionChanged => DataGrid.onListScrollPositionChangedEvent.forTarget(this);
  
  int get scrollPosition => (_list != null) ? _list.scrollPosition : 0;
  set scrollPosition(int value) {
    if (_list != null) _list.setScrollPositionExternally(value);
  }
  
  //---------------------------------
  // headerMouseOutHandler
  //---------------------------------

  HeaderMouseHandler _headerMouseOutHandler;

  HeaderMouseHandler get headerMouseOutHandler => _headerMouseOutHandler;
  set headerMouseOutHandler(HeaderMouseHandler value) {
    if (value != _headerMouseOutHandler) {
      _headerMouseOutHandler = value;

      invokeLaterSingle('invalidateHeaderHoverHandlers', _invalidateHeaderHoverHandlers);
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
  // autoManageScrollBars
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onAutoManageScrollBarsChangedEvent = const EventHook<FrameworkEvent>('autoManageScrollBarsChanged');
  Stream<FrameworkEvent> get onAutoManageScrollBarsChanged => DataGrid.onAutoManageScrollBarsChangedEvent.forTarget(this);

  bool _autoManageScrollBars = true;

  bool get autoManageScrollBars => _autoManageScrollBars;
  set autoManageScrollBars(bool value) {
    if (value != _autoManageScrollBars) {
      _autoManageScrollBars = value;
      
      if (_list != null) _list.autoManageScrollBars = value;

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
  Stream<FrameworkEvent> get onUseSelectionEffectsChanged => DataGrid.onUseSelectionEffectsChangedEvent.forTarget(this);
  
  bool _useSelectionEffects = true;

  bool get useSelectionEffects => _useSelectionEffects;
  set useSelectionEffects(bool value) {
    if (value != _useSelectionEffects) {
      _useSelectionEffects = value;
      
      if (_list != null) _list.useSelectionEffects = value;

      notify(
        new FrameworkEvent(
          'useSelectionEffectsChanged'
        )
      );

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

      if (_list != null) _list.autoScrollSelectionIntoView = value;
    }
  }
  
  //---------------------------------
  // autoScrollOnDataChange
  //---------------------------------

  bool _autoScrollOnDataChange = true;

  bool get autoScrollOnDataChange => _autoScrollOnDataChange;
  set autoScrollOnDataChange(bool value) {
    _autoScrollOnDataChange = value;
  }
  
  //---------------------------------
  // disableRecycling
  //---------------------------------
  
  bool _disableRecycling = false;
  
  bool get disableRecycling => _disableRecycling;
  set disableRecycling(bool value) {
    if (value != _disableRecycling) {
      _disableRecycling = value;
  
      if (_list != null) _list.disableRecycling = value;
    }
  }

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
  
  @override
  void commitProperties() {
    super.commitProperties();

    if (
        _isColumnsChanged &&
        (_headerContainer != null)
    ) {
      _isColumnsChanged = false;

      _updateColumnsAndHeaders();
    }
    
    if (_isSelectedIndexUpdateRequired) {
      _isSelectedIndexUpdateRequired = false;
      
      selectedIndex = (_selectedItem != null) ? _dataProvider.indexOf(_selectedItem) : -1;
    }
  }
  
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

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    final DivElement container = new DivElement();

    _gridContainer = new VGroup(gap: 0)
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..className = 'data-grid-container';

    _headerContainer = new HGroup(gap: _columnSpacing)
    ..visible = !_headless
    ..includeInLayout = !_headless
    ..percentWidth = 100.0
    ..height = _headerHeight
    ..autoSize = false
    ..className = 'data-grid-header-container';
    
    _headerBounds = new HGroup()
    ..percentWidth = 100.0
    ..height = _headerHeight
    ..visible = !_headless
    ..includeInLayout = !_headless
    ..addComponent(_headerContainer);

    _list = new ListRenderer(orientation: 'grid')
    ..cssClasses = _listCssClasses
    ..useEvenOdd = true
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..disableRecycling = _disableRecycling
    ..colPercentWidth = 100.0
    ..autoScrollSelectionIntoView = _autoScrollSelectionIntoView
    ..inactiveHandler = _inactiveHandler
    ..rowSpacing = _rowSpacing
    ..rowHeight = _rowHeight
    ..dataProvider = _dataProvider
    ..itemRendererFactory = _dataGridItemRendererFactory
    ..useSelectionEffects = _useSelectionEffects
    ..autoManageScrollBars = _autoManageScrollBars
    ..allowMultipleSelection = _allowMultipleSelection;
    
    _list._streamSubscriptionManager.add(
        'data_grid_listScrollPositionChange', 
        _list.onListScrollPositionChanged.listen(
          (FrameworkEvent event) => notify(
            new FrameworkEvent(
              'listScrollPositionChanged'
            )
          )
        )
    );

    _gridContainer.addComponent(_headerBounds);
    _gridContainer.addComponent(_list);

    addComponent(_gridContainer);

    _setControl(container);
    
    _list._streamSubscriptionManager.add(
        'data_grid_listRendererAdded', 
        _list.onRendererAdded.listen(_list_rendererAddedHandler)
    );
    
    _list._streamSubscriptionManager.add(
        'data_grid_listRendererRemoved', 
        _list.onRendererRemoved.listen(_list_rendererRemovedHandler)
    );
    
    _list._streamSubscriptionManager.add(
        'data_grid_listHeaderScrollPositionChanged', 
        _list.onHeaderScrollPositionChanged.listen(_list_headerScrollChangedHandler)
    );
    
    _list._streamSubscriptionManager.add(
        'data_grid_listSelectedItemChanged', 
        _list.onSelectedItemChanged.listen(_list_selectedItemChangedHandler)
    );
    
    invokeLaterSingle('updateScrollPolicy', _updateScrollPolicy);

    super.createChildren();
  }
  
  @override
  void _updatePresentation() {
    super._updatePresentation();
    
    if (_list != null) {
      _list._updateVisibleItemRenderers(ignorePreviousIndex: true);
      
      _list.invokeLaterSingle('invalidateLayout', _list.invalidateLayout);
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
    IHeaderItemRenderer header;
    int i, len;

    _removeAllElements();

    _headerItemRenderers = new List<IHeaderItemRenderer>();

    if (_columns != null) {
      len = _columns.length;
      
      for (i=0; i<len; i++) {
        column = _columns[i];
        
        if (column._isActive) {
          header = column.headerItemRendererFactory.immediateInstance()
            ..visible = !_headless
            ..includeInLayout = !_headless
            ..height = _headerHeight
            ..data =  column.headerData;
          
          header.streamSubscriptionManager.add(
              'data_grid_headerButtonClick', 
              header.onButtonClick.listen(_header_clickHandler)
          );

          if (column.width > 0) header.width = column.width;
          else header.percentWidth = column.percentWidth;
          
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
            
            if (renderer.columns != _columns) renderer.columns = _columns;
            else renderer.refreshColumns();
          }
        );
      }
    }
  }
  
  List<IHeaderItemRenderer> _sortHandlers = <IHeaderItemRenderer>[];

  void _header_clickHandler(FrameworkEvent<IHeaderData> event) {
    if (!_allowHeaderColumnSorting) return;
    
    final IHeaderItemRenderer renderer = event.currentTarget as IHeaderItemRenderer;
    IHeaderItemRenderer SH;
    
    if (renderer.lastClickEvent is MouseEvent) {
      final MouseEvent mouseEvent = renderer.lastClickEvent;
      
      if (!mouseEvent.ctrlKey) _sortHandlers.clear();
    } else _sortHandlers.clear();
    
    if (!_sortHandlers.contains(renderer)) _sortHandlers.add(renderer);
    
    final int maxLen = _sortHandlers.length;
    
    _headerItemRenderers.forEach((IHeaderItemRenderer H) => H.cssClasses = null);
    
    renderer.isSortedAsc = !renderer.isSortedAsc;
    
    if (_sortHandlers.length > 1) {
      for (int i=0; i<maxLen; i++) {
        SH = _sortHandlers[i];
        
        SH.cssClasses = <String>[SH.isSortedAsc ? 'sort-asc' : 'sort-desc', 'index_${i+1}'];
      }
    } else _sortHandlers.first.cssClasses = <String>[_sortHandlers.first.isSortedAsc ? 'sort-asc' : 'sort-desc'];
    
    presentationHandler = (dynamic a, dynamic b) {
      int i = 0, c = 0;
      
      while (c == 0 && i < maxLen) {
        IHeaderItemRenderer H = _sortHandlers[i++];
        
        c = H.isSortedAsc ? 
            H.sortHandler(a, b, _columns[_headerItemRenderers.indexOf(H)], H.data) :
           -H.sortHandler(a, b, _columns[_headerItemRenderers.indexOf(H)], H.data);
      }
      
      return c;
    };
  }
  
  @override
  void updateLayout() {
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
        
        if (column._isActive && column._isVisible) {
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
      
      if (_autoManageScrollBars) _list.horizontalScrollPolicy = (tw > _width) ? ScrollPolicy.AUTO : ScrollPolicy.NONE;
      else _list.horizontalScrollPolicy = _horizontalScrollPolicy;
      
      if (_headerBounds != null) {
        _headerBounds.width = w;
        _headerBounds.height = _headerHeight;
      }

      if (_headerContainer != null) {
        _headerContainer.width = w;
        _headerContainer.height = _headerHeight;
      }
    }

    super.updateLayout();
  }

  void _list_rendererAddedHandler(FrameworkEvent<DataGridItemRenderer> event) {
    final DataGridItemRenderer renderer = event.relatedObject
      ..gap = _columnSpacing
      ..columns = _columns
      ..grid = this;
    
    renderer._streamSubscriptionManager.add(
        'data_grid_rendererDataPropertyChanged', 
        renderer.onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler),
        flushExisting: true
    );
    
    invalidateProperties();
    
    notify(
      new FrameworkEvent<DataGridItemRenderer>(
        'rendererAdded',
        relatedObject: renderer
      )
    );
  }
  
  void _list_rendererRemovedHandler(FrameworkEvent<IUIWrapper> event) {
    if (event.relatedObject is DataGridItemRenderer) {
      final DataGridItemRenderer renderer = (event.relatedObject as DataGridItemRenderer)
          ..columns = null
          ..data = null
          ..field = null
          ..fields = null;
      
      notify(
          new FrameworkEvent<DataGridItemRenderer>(
              'rendererRemoved',
              relatedObject: renderer
          )
      );
    }
  }
  
  void _list_selectedItemChangedHandler(FrameworkEvent<dynamic> event) {
    selectedItem = event.relatedObject;
    selectedIndex = _list.selectedIndex;
  }
  
  void _list_headerScrollChangedHandler(FrameworkEvent event) {
    final String newValue = (_headerContainer.x - _list._headerScrollPosition).toString() + 'px';
    
    _reflowManager.invalidateCSS(_headerContainer._control, 'left', newValue);
  }

  void _columns_collectionChangedHandler(List<ListChangeRecord> changes) {
    _isColumnsChanged = true;

    invalidateProperties();
    
    invokeLaterSingle('updateSelection', _updateSelection);
  }
  
  @override
  void _updateSelection() {
    super._updateSelection();
    
    if (_list != null) {
      _list.selectedIndex = _selectedIndex;
      _list.selectedItem = _selectedItem;
    }
  }
  
  @override
  void _dataProvider_collectionChangedHandler(List<ListChangeRecord> changes) {
    super._dataProvider_collectionChangedHandler(changes);
    
    _isSelectedIndexUpdateRequired = true;
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
        (IHeaderItemRenderer header) {
          if (_headerMouseOutHandler != null) header.streamSubscriptionManager.add(
              'data_grid_headerMouseOut', 
              header.onMouseOut.listen(
                  (FrameworkEvent event) => _headerMouseOutHandler(event.currentTarget as IHeaderItemRenderer)
              ),
              flushExisting: true
          );
          else header.streamSubscriptionManager.flushIdent('data_grid_headerMouseOut');
          
          if (_headerMouseOverHandler != null) header.streamSubscriptionManager.add(
              'data_grid_headerMouseOver', 
              header.onMouseOver.listen(
                  (FrameworkEvent event) => _headerMouseOverHandler(event.currentTarget as IHeaderItemRenderer)    
              ),
              flushExisting: true
          );
          else header.streamSubscriptionManager.flushIdent('data_grid_headerMouseOver');
        }
      );
    }
  }
  
  void _renderer_dataPropertyChangedHandler(FrameworkEvent<IItemRenderer> event) {
    if (_autoScrollOnDataChange) event.relatedObject.control.scrollIntoView(ScrollAlignment.CENTER);
  }
}