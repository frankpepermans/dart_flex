part of dart_flex;

abstract class IItemRenderer implements IUIWrapper {
  
  Stream<FrameworkEvent> get onDataChanged;
  Stream<FrameworkEvent> get onFieldChanged;
  Stream<FrameworkEvent> get onFieldsChanged;
  Stream<FrameworkEvent> get onClick;
  Stream<FrameworkEvent> get onMouseOver;
  Stream<FrameworkEvent> get onMouseOut;
  Stream<FrameworkEvent> get onDataPropertyChanged;

  int get index;
  set index(int value);

  String get state;
  set state(String value);

  bool get selected;
  set selected(bool value);
  
  bool get editable;
  set editable(bool value);
  
  bool get enableHighlight;
  set enableHighlight(bool value);

  Object get data;
  set data(Object value);
  
  Symbol get field;
  set field(Symbol value);
  
  List<Symbol> get fields;
  set fields(List<Symbol> value);

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
  
  void highlight();

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
  
  static const EventHook<FrameworkEvent> onFieldChangedEvent = const EventHook<FrameworkEvent>('fieldChanged');
  Stream<FrameworkEvent> get onFieldChanged => ItemRenderer.onFieldChangedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onFieldsChangedEvent = const EventHook<FrameworkEvent>('fieldsChanged');
  Stream<FrameworkEvent> get onFieldsChanged => ItemRenderer.onFieldsChangedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onClickEvent = const EventHook<FrameworkEvent>('click');
  Stream<FrameworkEvent> get onClick => ItemRenderer.onClickEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onMouseOverEvent = const EventHook<FrameworkEvent>('mouseOver');
  Stream<FrameworkEvent> get onMouseOver => ItemRenderer.onMouseOverEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onMouseOutEvent = const EventHook<FrameworkEvent>('mouseOut');
  Stream<FrameworkEvent> get onMouseOut => ItemRenderer.onMouseOutEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent> onDataPropertyChangedEvent = const EventHook<FrameworkEvent>('dataPropertyChanged');
  Stream<FrameworkEvent> get onDataPropertyChanged => ItemRenderer.onDataPropertyChangedEvent.forTarget(this);
  
  DivElement highlightElement;

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
  StreamSubscription _dataChangesListener;

  dynamic get data => _data;
  set data(dynamic value) {
    if (value != _data) {
      _data = value;
      
      if (_dataChangesListener != null) {
        _dataChangesListener.cancel();
        
        _dataChangesListener = null;
      }
      
      if (value is Observable) _dataChangesListener = value.changes.listen(_data_changesHandler);
      
      notify(
        new FrameworkEvent('dataChanged')    
      );

      later > _invalidateData;
    }
  }
  
  //---------------------------------
  // field
  //---------------------------------

  Symbol _field;

  Symbol get field => _field;
  set field(Symbol value) {
    if (value != _field) {
      _field = value;
      
      notify(
          new FrameworkEvent('fieldChanged')    
      );
      
      later > _invalidateData;
    }
  }
  
  //---------------------------------
  // fields
  //---------------------------------

  List<Symbol> _fields;

  List<Symbol> get fields => _fields;
  set fields(List<Symbol> value) {
    if (value != _fields) {
      _fields = value;
      
      notify(
          new FrameworkEvent('fieldsChanged')    
      );
      
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
  // editable
  //---------------------------------

  bool _editable = false;

  bool get editable => _editable;
  set editable(bool value) {
    if (value != _editable) {
      _editable = value;

      later > updateForEditable;
    }
  }
  
  //---------------------------------
  // enableHighlight
  //---------------------------------

  bool _enableHighlight = false;

  bool get enableHighlight => _enableHighlight;
  set enableHighlight(bool value) {
    if (value != _enableHighlight) {
      _enableHighlight = value;
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

  static ItemRenderer construct() => new ItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {}

  void invalidateData() {}

  void updateLayout() {}

  void updateAfterInteraction() {}
  
  void updateForEditable() {}
  
  void highlight() {
    if (_control == null) return;
    
    if (highlightElement == null) {
      highlightElement = new DivElement();
      
      highlightElement.onTransitionEnd.listen(
          (_) {
            _control.children.remove(highlightElement);
            
            highlightElement = null;
          }
      );
    }
    
    highlightElement.style.opacity = '.5';
    
    highlightElement.className = 'item-renderer-highlight';
    
    reflowManager.invalidateCSS(highlightElement, 'opacity', '0');
    
    if (!_control.contains(highlightElement)) _control.append(highlightElement);
    
    notify(
        new FrameworkEvent('dataPropertyChanged')    
    );
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
  
  void _data_changesHandler(List<ChangeRecord> changes) {
    if (_enableHighlight) {
      PropertyChangeRecord propertyChangeRecord = changes.firstWhere(
          (ChangeRecord changeRecord) => (
              (changeRecord is PropertyChangeRecord) &&
              ((changeRecord as PropertyChangeRecord).changes(_field))
          ),
          orElse: () => null
      );
      
      if (propertyChangeRecord != null) later > highlight;
    }
    
    later > _invalidateData;
  }
}

