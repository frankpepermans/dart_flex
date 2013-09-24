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

  ObservableList<DataGridColumn> get columns => _columns;
  set columns(ObservableList<DataGridColumn> value) {
    if (value != _columns) {
      if (_columns != null) {
        //_columns.changes.
      }

      _columns = value;
      _isColumnsChanged = true;

      if (value != null) {
        value.changes.listen(_itemRenderers_collectionChangedHandler);
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
  // grid
  //---------------------------------
  
  DataGrid _grid;
  
  DataGrid get grid => _grid;
  
  //---------------------------------
  // selected
  //---------------------------------
  
  set selected(bool value) {
    super.selected = value;
    
    className = value ? 'DataGridItemRenderer DataGridItemRenderer-selected' : 'DataGridItemRenderer';
  }

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

  static DataGridItemRenderer construct() {
    return new DataGridItemRenderer();
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void invalidateData() {
  }
  
  void _refreshColumns() {
    _isColumnsChanged = true;

    notify(
      new FrameworkEvent(
        'columnsChanged'
      )
    );

    invalidateProperties();
  }

  void _commitProperties() {
    super._commitProperties();

    if (_isColumnsChanged) {
      _isColumnsChanged = false;

      _updateItemRenderers();
    }
  }

  void _updateItemRenderers() {
    removeAll();
    
    _itemRendererInstances = new List<IItemRenderer>();

    if (_columns != null) {
      _columns.forEach(
        (DataGridColumn column) {
          if (column._isActive) {
            IItemRenderer renderer = column.columnItemRendererFactory.immediateInstance()
                ..data = _data
                ..field = column._field
                ..fields = column._fields
                ..labelHandler = column.labelHandler
                ..height = _grid.rowHeight;

            if (column.percentWidth > .0) {
              renderer.percentWidth = column.percentWidth;
            } else {
              renderer.width = column.width;
            }

            _itemRendererInstances.add(renderer);

            addComponent(renderer);
            
            notify(
                new FrameworkEvent(
                    'rendererAdded',
                    relatedObject: renderer
                )
            );
          }
        }
      );
    }
  }

  void _invalidateData() {
    super._invalidateData();

    if (
        (_itemRendererInstances != null) &&
        (_itemRendererInstances.length > 0)
    ) _itemRendererInstances.forEach(
        (IItemRenderer renderer) => renderer.data = _data
    );
  }

  void _itemRenderers_collectionChangedHandler(List<ChangeRecord> changes) => _updateItemRenderers();

  void _itemRendererSizes_collectionChangedHandler() => _invalidateData();

  void _updateLayout() {
    _layout.gap = _gap;

    super._updateLayout();
  }
}