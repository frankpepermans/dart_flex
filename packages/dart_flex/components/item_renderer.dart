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
  StreamSubscription _highlightElementChangesListener;
  StreamSubscription _dataPropertyChangesListener;

  //---------------------------------
  // index
  //---------------------------------

  int index = 0;

  //---------------------------------
  // data
  //---------------------------------

  dynamic _data;
  StreamSubscription _dataChangesListener;
  StreamSubscription _dataFieldsChangesListener;

  dynamic get data => _data;
  set data(dynamic value) {
    if (value != _data) {
      _data = value;
      
      if (_dataChangesListener != null) {
        _dataChangesListener.cancel();
        
        _dataChangesListener = null;
      }
      
      if (_dataFieldsChangesListener != null) {
        _dataFieldsChangesListener.cancel();
        
        _dataFieldsChangesListener = null;
      }
      
      dynamic dataToObserve = _getDataToObserve();
      
      if (value is Observable) _dataChangesListener = value.changes.listen(_data_changesHandler);
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
      
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
      
      if (_dataFieldsChangesListener != null) {
        _dataFieldsChangesListener.cancel();
        
        _dataFieldsChangesListener = null;
      }
      
      dynamic dataToObserve = _getDataToObserve();
      
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
      
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
      
      _highlightElementChangesListener = highlightElement.onTransitionEnd.listen(
          _highlightElement_transitionEndHandler
      );
    }
    
    highlightElement.style.opacity = '.75';
    
    highlightElement.className = 'item-renderer-highlight';
    
    reflowManager.invalidateCSS(highlightElement, 'opacity', '0');
    
    if (!_control.contains(highlightElement)) _control.append(highlightElement);
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
    if (_fields != null) {
      if (_dataFieldsChangesListener != null) {
        _dataFieldsChangesListener.cancel();
        
        _dataFieldsChangesListener = null;
      }
      
      dynamic dataToObserve = _getDataToObserve();
      
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
    }
    
    if (_enableHighlight) {
      PropertyChangeRecord propertyChangeRecord = changes.firstWhere(
          (ChangeRecord changeRecord) => (
              (changeRecord is PropertyChangeRecord) &&
              (
                  (changeRecord.changes(_field)) ||
                  (
                    (_fields != null) &&
                    _fields.contains(changeRecord.field)
                  )
              )
              
          ),
          orElse: () => null
      );
      
      if (propertyChangeRecord != null) {
        notify(
            new FrameworkEvent('dataPropertyChanged')    
        );
        
        later > highlight;
      }
    }
    
    later > _invalidateData;
  }
  
  dynamic _getDataToObserve() {
    if (_data == null) return null;
    
    if (_fields == null) return data;
    
    dynamic value;
    
    value = _data;
    
    _fields.forEach(
        (Symbol subField) {
          if (value != null) value = value[subField];
        }
    );
    
    return value;
  }
  
  void _highlightElement_transitionEndHandler(TransitionEvent event) {
    _control.children.remove(highlightElement);
    
    _highlightElementChangesListener.cancel();
    
    _highlightElementChangesListener = null;
    
    highlightElement = null;
  }
}

