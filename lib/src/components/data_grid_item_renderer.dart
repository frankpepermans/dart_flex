part of dart_flex;

class DataGridItemRenderer<D> extends ItemRenderer {

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

  ObservableList<DataGridColumn> get columns => _columns;
  set columns(ObservableList<DataGridColumn> value) {
    if (value != _columns) {
      _columns = value;
      _isColumnsChanged = true;

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
  
  IItemRenderer createItemRenderer(DataGridColumn column, int index) {
    final IItemRenderer renderer = column.columnItemRendererFactory.immediateInstance()
      ..index = index
      ..data = _data
      ..enableHighlight = true
      ..field = column._field
      ..fields = column._fields
      ..inactiveHandler = _inactiveHandler
      ..labelHandler = column.labelHandler
      ..height = _grid.rowHeight;
    
    return renderer;
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
  
  void _updateItemRenderers() {
    if (_grid != null && _columns != null) {
      int rendererIndex = 0;
      
      if (_itemRendererInstances != null) {
        _itemRendererInstances.forEach(
            (ItemRenderer renderer) => removeComponent(renderer)
        );
      } else _itemRendererInstances = new List<IItemRenderer>();
      
      _streamSubscriptionManager.flushIdent('data_grid_item_renderer_rendererColumnChanges');
      _streamSubscriptionManager.flushIdent('data_grid_item_renderer_rendererDataPropertyChanged');
      
      _columns.forEach(
        (DataGridColumn column) {
          if (column._isActive) {
            ItemRenderer renderer = createItemRenderer(column, rendererIndex++);
            
            renderer.cssClasses = _concat_css(column, renderer);
            
            if (column.percentWidth > .0) renderer.percentWidth = column.percentWidth;
            else renderer.width = column.width;
            
            _streamSubscriptionManager.add(
                'data_grid_item_renderer_rendererColumnChanges', 
                renderer.onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler)
            );
            
            _streamSubscriptionManager.add(
                'data_grid_item_renderer_rendererDataPropertyChanged', 
                renderer.onDataPropertyChanged.listen(_renderer_dataPropertyChangedHandler)
            );

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
  
  void _renderer_dataPropertyChangedHandler(FrameworkEvent event) {
    IItemRenderer itemRenderer = event.currentTarget as IItemRenderer;
    
    notify(
        new FrameworkEvent<IItemRenderer>('dataPropertyChanged', relatedObject: itemRenderer)
    );
  }
}