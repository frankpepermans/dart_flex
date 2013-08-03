part of dartflex;

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
  
  ObservableList _columns;
  bool _isColumnsChanged = false;

  ObservableList get columns => _columns;
  set columns(ObservableList value) {
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
  //
  // Constructor
  //
  //---------------------------------

  DataGrid() : super(elementId: null) {
	_className = 'DataGrid';
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

  void _createChildren() {
    final DivElement container = new DivElement();

    _gridContainer = new VGroup(gap: 0)
    ..percentWidth = 100.0
    ..percentHeight = 100.0;

    _headerContainer = new HGroup(gap: _columnSpacing)
    ..percentWidth = 100.0
    ..height = _headerHeight
    ..autoSize = false;

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
    _list.onScrollPositionChanged.listen(_list_scrollChangedHandler);

    super._createChildren();
  }

  void _commitProperties() {
    super._commitProperties();

    if (
        _isColumnsChanged &&
        (_headerContainer != null)
    ) {
      _isColumnsChanged = false;

      _updateColumnsAndHeaders();
    }
    
    if (_isUseSelectionEffectsChanged) {
      _isUseSelectionEffectsChanged = false;
      
      if (_list != null) {
        _list.useSelectionEffects = _useSelectionEffects;
      }
    }
  }

  void _removeAllElements() {
    if (_headerItemRenderers != null) {
      _headerItemRenderers.removeRange(0, _headerItemRenderers.length);
    }
    
    if (_headerContainer != null) {
      _headerContainer.removeAll();
    }
  }

  void _updateElements() {
    if (_list != null) {
      _list.dataProvider = _dataProvider;
    }
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
        column = _columns[i] as DataGridColumn;

        header = (column.headerItemRendererFactory.immediateInstance() as IItemRenderer)
          ..height = _headerHeight
          ..data =  column.headerData
          ..['buttonClick'] = _header_clickHandler;

        if (column.width > 0) {
          header.width = column.width;
        } else {
          header.percentWidth = column.percentWidth;
        }

        _headerContainer.addComponent(header);
      }

      if (
          (_list != null) &&
          (_list._itemRenderers != null)
      ) {
        _list._itemRenderers.forEach(
          (DataGridItemRenderer renderer) {
            renderer.gap = _columnSpacing;
            renderer.columns = _columns;
          }
        );
      }
    }
  }

  void _header_clickHandler(FrameworkEvent event) {
    final String property = event.relatedObject['property'];

    if (event.relatedObject['isAscSort'] == null) {
      event.relatedObject['isAscSort'] = true;
    }

    final bool isAscSort = event.relatedObject['isAscSort'];
    
    _dataProvider.sort(
        (dynamic itemA, dynamic itemB) {
          dynamic valA = (itemA[property] is bool) ? itemA[property] ? 1 : 0 : itemA[property];
          dynamic valB = (itemA[property] is bool) ? itemB[property] ? 1 : 0 : itemB[property];
          
          if (valA == null && valB == null) {
            return 0;
          } else if (valB == null) {
            return -1;
          } else if (valA == null) {
            return 1;
          }
          
          if (isAscSort) {
            return valA.toString().compareTo(valB.toString());
          } else {
            return valB.toString().compareTo(valA.toString());
          }
        }
    );

    event.relatedObject['isAscSort'] = !isAscSort;
  }

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

        if (column.percentWidth > .0) {
          procCount += column.percentWidth;

          tw += column.minWidth;
        } else if (column.width > .0) {
          w += column.width + ((i > 0) ? _columnSpacing : 0);
        }
      }

      i = _columns.length;

      tw += w;

      remainingWidth = _width - w;

      remainingWidth = (remainingWidth < 0) ? 0 : remainingWidth;

      if (procCount > .0) {
        while (i > 0) {
          column = _columns[--i];

          if (column.percentWidth > .0) {
            w += max(column.minWidth, (remainingWidth * column.percentWidth / procCount).toInt());
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
      ..columns = _columns;
    
    invalidateProperties();
    
    notify(
      new FrameworkEvent(
        'rendererAdded',
        relatedObject: renderer
      )
    );
  }

  void _list_scrollChangedHandler(FrameworkEvent event) {
    _reflowManager.scheduleMethod(this, _updateHeaderContainerPosition, []);
  }
  
  void _updateHeaderContainerPosition() {
    _headerContainer.x = -_list._control.scrollLeft;
  }

  void _columns_collectionChangedHandler(List<ChangeRecord> changes) {
    _isColumnsChanged = true;

    invalidateProperties();
  }

  void _dataProvider_collectionChangedHandler(List<ChangeRecord> changes) {
    super._dataProvider_collectionChangedHandler(changes);

    if (_list != null) {
      _list._updateVisibleItemRenderers();
    }
  }
}