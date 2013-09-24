part of dart_flex;

abstract class IItemRenderer implements IUIWrapper {

  int get index;
  set index(int value);

  String get state;
  set state(String value);

  bool get selected;
  set selected(bool value);

  Object get data;
  set data(Object value);
  
  String get field;
  set field(String value);
  
  List<String> get fields;
  set fields(List<String> value);

  Function get labelHandler;
  set labelHandler(Function value);

  bool get autoDrawBackground;
  set autoDrawBackground(bool value);

  int get gap;
  set gap(int value);

  String get interactionStyle;

  void createChildren();

  void invalidateData();

  void updateLayout();

  void updateAfterInteraction();

}

class ItemRenderer extends UIWrapper implements IItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onDataChangedEvent = const EventHook<FrameworkEvent>('dataChanged');
  Stream<FrameworkEvent> get onDataChanged => ItemRenderer.onDataChangedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onClickEvent = const EventHook<FrameworkEvent>('click');
  Stream<FrameworkEvent> get onClick => ItemRenderer.onClickEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onMouseOverEvent = const EventHook<FrameworkEvent>('mouseOver');
  Stream<FrameworkEvent> get onMouseOver => ItemRenderer.onMouseOverEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onMouseOutEvent = const EventHook<FrameworkEvent>('mouseOut');
  Stream<FrameworkEvent> get onMouseOut => ItemRenderer.onMouseOutEvent.forTarget(this);

  //---------------------------------
  // index
  //---------------------------------

  int _index = 0;

  int get index => _index;
  set index(int value) {
    if (value != _index) _index = value;
  }

  //---------------------------------
  // data
  //---------------------------------

  dynamic _data;

  dynamic get data => _data;
  set data(dynamic value) {
    if (value != _data) {
      _data = value;
      
      if (value is Observable) value.changes.listen(
        (List<ChangeRecord> changes) => _invalidateData()   
      );
      
      notify(
        new FrameworkEvent('dataChanged')    
      );

      later > _invalidateData;
    }
  }
  
  //---------------------------------
  // field
  //---------------------------------

  String _field;

  String get field => _field;
  set field(String value) {
    if (value != _field) {
      _field = value;
      
      later > _invalidateData;
    }
  }
  
  //---------------------------------
  // fields
  //---------------------------------

  List<String> _fields;

  List<String> get fields => _fields;
  set fields(List<String> value) {
    if (value != _fields) {
      _fields = value;
      
      later > _invalidateData;
    }
  }
  
  //---------------------------------
  // labelHandler
  //---------------------------------

  Function _labelHandler;

  Function get labelHandler => _labelHandler;
  set labelHandler(Function value) {
    if (value != _labelHandler) {
      _labelHandler = value;
      
      later > _invalidateData;
    }
  }

  //---------------------------------
  // state
  //---------------------------------

  String _state = 'mouseout';

  String get state => _state;
  set state(String value) {
    if (value != _state) {
      _state = value;

      later > _updateAfterInteraction;
    }
  }

  //---------------------------------
  // selected
  //---------------------------------

  bool _selected = false;

  bool get selected => _selected;
  set selected(bool value) {
    if (value != _selected) {
      _selected = value;
      
      className = value ? 'ItemRenderer ItemRenderer-selected' : 'ItemRenderer';

      later > _updateAfterInteraction;
    }
  }

  //---------------------------------
  // interactionStyle
  //---------------------------------

  String get interactionStyle {
    if (_selected) return 'selected_$_state';

    return _state;
  }

  //---------------------------------
  // autoDrawBackground
  //---------------------------------

  bool _autoDrawBackground;

  bool get autoDrawBackground => _autoDrawBackground;
  set autoDrawBackground(bool value) {
    if (value != _autoDrawBackground) _autoDrawBackground = value;
  }

  //---------------------------------
  // gap
  //---------------------------------

  int _gap = 0;

  int get gap => _gap;
  set gap(int value) {
    if (value != _gap) {
      _gap = value;

      later > _updateLayout;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ItemRenderer({String elementId: null, bool autoDrawBackground: true}) : super(elementId: null) {
  	_className = 'ItemRenderer';
	
    _autoDrawBackground = autoDrawBackground;
  }

  static ItemRenderer construct() {
    return new ItemRenderer();
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
  }

  void invalidateData() {
  }

  void updateLayout() {
  }

  void updateAfterInteraction() {
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    super._createChildren();

    DivElement container = new DivElement()..className = 'item-renderer-control';
    
    _setControl(container);
    
    container.onClick.listen(
        (MouseEvent event) => notify(
            new FrameworkEvent(
                'click'
            )
        )
    );
    
    container.onMouseOver.listen(
        (MouseEvent event) => notify(
            new FrameworkEvent(
                'mouseOver'
            )
        )
    );
    
    container.onMouseOut.listen(
        (MouseEvent event) => notify(
            new FrameworkEvent(
                'mouseOut'
            )
        )
    );

    createChildren();

    later > _invalidateData;
  }

  void _invalidateData() => invalidateData();

  void _updateLayout() {
    super._updateLayout();

    updateLayout();
  }

  void _updateAfterInteraction() => updateAfterInteraction();
}

