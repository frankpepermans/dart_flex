part of dart_flex;

class DataGridItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  List<IItemRenderer> _itemRendererInstances;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onRendererAddedEvent = const EventHook<FrameworkEvent>('rendererAdded');
  Stream<FrameworkEvent> get onRendererAdded => DataGridItemRenderer.onRendererAddedEvent.forTarget(this);

  //---------------------------------
  // itemRenderers
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onColumnsChangedEvent = const EventHook<FrameworkEvent>('columnsChanged');
  Stream<FrameworkEvent> get onColumnsChanged => DataGridItemRenderer.onColumnsChangedEvent.forTarget(this);

  ObservableList<DataGridColumn> _columns;
  bool _isColumnsChanged = false;
  StreamSubscription _columnsChangesListener;
  Map<DataGridColumn, StreamSubscription> _columnChangesListeners = <DataGridColumn, StreamSubscription>{};

  ObservableList<DataGridColumn> get columns => _columns;
  set columns(ObservableList<DataGridColumn> value) {
    if (value != _columns) {
      _columns = value;
      _isColumnsChanged = true;
      
      if (_columnsChangesListener != null) {
        _columnsChangesListener.cancel();
        
        _columnsChangesListener = null;
      }

      if (value != null) _columnsChangesListener = value.changes.listen(_itemRenderers_collectionChangedHandler);

      notify(
        new FrameworkEvent(
          'columnsChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // grid
  //---------------------------------
  
  DataGrid _grid;
  
  DataGrid get grid => _grid;
  
  //---------------------------------
  // selected
  //---------------------------------
  
  set selected(bool value) {
    super.selected = value;
    
    final String mainClassName = className.split(' ').first;
    
    className = '${mainClassName}${_selected ? ' ${mainClassName}-selected' : ''}${_inactive ? ' inactive' : ''}';
  }
  
  //---------------------------------
  // inactive
  //---------------------------------
  
  set inactiveHandler(InactiveHandler value) {
    final String mainClassName = className.split(' ').first;
    
    if (value != _inactiveHandler) className = '${mainClassName}${_selected ? ' ${mainClassName}-selected' : ''}${_inactive ? ' inactive' : ''}';
    
    super.inactiveHandler = value;
  }
  
  //---------------------------------
  // enableHighlight
  //---------------------------------
  
  set enableHighlight(bool value) => super.enableHighlight = false;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  DataGridItemRenderer({int gap: 0}) : super(elementId: null) {
  	_className = 'DataGridItemRenderer';
	
    _gap = gap;

    _layout = new HorizontalLayout();

    _layout.gap = gap;

    percentWidth = 100.0;
  }

  static DataGridItemRenderer construct() => new DataGridItemRenderer();

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void commitProperties() {
    super.commitProperties();

    if (_isColumnsChanged) {
      _isColumnsChanged = false;

      _updateItemRenderers();
    }
  }

  @override
  void invalidateData() {
    super.invalidateData();

    if (
        (_itemRendererInstances != null) &&
        (_itemRendererInstances.length > 0)
    ) _itemRendererInstances.forEach(
        (IItemRenderer renderer) => renderer.data = _data
    );
  }
  
  @override
  void updateLayout() {
    _layout.gap = _gap;
    
    super.updateLayout();
  }
  
  DataGridColumn getColumn(IItemRenderer renderer) {
    if (_columns == null) return null;
    
    final int len = _columns.length;
    
    DataGridColumn column;
    int i = _columns.length, rendererIndex = -1;
    
    for (i=0; i<len; i++) {
      column = _columns[i];
      
      if (column._isActive && (++rendererIndex == renderer.index)) return column;
    }
    
    return null;
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _refreshColumns() {
    _isColumnsChanged = true;

    notify(
      new FrameworkEvent(
        'columnsChanged'
      )
    );

    invalidateProperties();
  }

  void _updateItemRenderers() {
    if (_itemRendererInstances != null) {
      _itemRendererInstances.forEach(
          (ItemRenderer renderer) {
            renderer._dataPropertyChangesListener.cancel();
            
            removeComponent(renderer);
          }
      );
    }
    
    _itemRendererInstances = new List<IItemRenderer>();

    if (_columns != null) {
      int rendererIndex = 0;
      
      _columnChangesListeners.forEach(
        (_, StreamSubscription listener) => listener.cancel()
      );
      
      _columnChangesListeners = <DataGridColumn, StreamSubscription>{};
      
      _columns.forEach(
        (DataGridColumn column) {
          if (column._isActive) {
            ItemRenderer renderer = column.columnItemRendererFactory.immediateInstance()
                ..index = rendererIndex++
                ..data = _data
                ..enableHighlight = true
                ..field = column._field
                ..fields = column._fields
                ..inactiveHandler = _inactiveHandler
                ..labelHandler = column.labelHandler
                ..height = _grid.rowHeight;
            
            _columnChangesListeners[column] = renderer.onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler);
            
            renderer.cssClasses = _concat_css(column, renderer);
            
            renderer._dataPropertyChangesListener = renderer.onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler);

            if (column.percentWidth > .0) renderer.percentWidth = column.percentWidth;
            else renderer.width = column.width;

            _itemRendererInstances.add(renderer);

            addComponent(renderer);
            
            notify(
                new FrameworkEvent<IItemRenderer>(
                    'rendererAdded',
                    relatedObject: renderer
                )
            );
          }
        }
      );
    }
  }
  
  List<String> _concat_css(DataGridColumn column, ItemRenderer renderer) {
    if (renderer.cssClasses != null) {
      if (column.cssClasses != null) return renderer.cssClasses.toList(growable: true)..addAll(column.cssClasses);
      else return renderer.cssClasses;
    } else return column.cssClasses;
  }

  void _itemRenderers_collectionChangedHandler(List<ChangeRecord> changes) => _updateItemRenderers();
  
  void _renderer_dataPropertyChangedHandler(FrameworkEvent event) {
    IItemRenderer itemRenderer = event.currentTarget as IItemRenderer;
    
    notify(
        new FrameworkEvent<IItemRenderer>('dataPropertyChanged', relatedObject: itemRenderer)
    );
  }
}