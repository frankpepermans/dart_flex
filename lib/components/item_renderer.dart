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
  
  InactiveHandler get inactiveHandler;
  set inactiveHandler(InactiveHandler value);
  
  bool get inactive;
  
  bool get editable;
  set editable(bool value);
  
  bool get enableHighlight;
  set enableHighlight(bool value);

  dynamic get data;
  set data(dynamic value);
  
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

  void invalidateData();
  void invalidateDataChangesListener();
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
  
  static const EventHook<FrameworkEvent<dynamic>> onDataChangedEvent = const EventHook<FrameworkEvent<dynamic>>('dataChanged');
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
  
  static const EventHook<FrameworkEvent<dynamic>> onDataPropertyChangedEvent = const EventHook<FrameworkEvent<dynamic>>('dataPropertyChanged');
  Stream<FrameworkEvent> get onDataPropertyChanged => ItemRenderer.onDataPropertyChangedEvent.forTarget(this);
  
  //SpanElement highlightElement;
  StreamSubscription _dataPropertyChangesListener, _controlHighlightListener;

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
      
      dynamic dataToObserve = getDataToObserve();
      
      if (value is Observable) _dataChangesListener = value.changes.listen(_data_changesHandler);
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
      
      _inactive = (_inactiveHandler != null) ? _inactiveHandler(data) : false;
      
      className = 'ItemRenderer${_selected ? ' ItemRenderer-selected' : ''}${_inactive ? ' inactive' : ''}';
      
      notify(
        new FrameworkEvent<dynamic>('dataChanged', relatedObject: value)
      );

      later > invalidateData;
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
      
      later > invalidateData;
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
      
      dynamic dataToObserve = getDataToObserve();
      
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
      
      notify(
          new FrameworkEvent('fieldsChanged')    
      );
      
      later > invalidateData;
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
      
      later > invalidateData;
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

      later > updateAfterInteraction;
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
      
      className = 'ItemRenderer${_selected ? ' ItemRenderer-selected' : ''}${_inactive ? ' inactive' : ''}';

      later > updateAfterInteraction;
    }
  }
  
  //---------------------------------
  // inactiveHandler
  //---------------------------------

  InactiveHandler _inactiveHandler;

  InactiveHandler get inactiveHandler => _inactiveHandler;
  set inactiveHandler(InactiveHandler value) {
    if (value != _inactiveHandler) {
      _inactiveHandler = value;
      _inactive = (value != null) ? value(data) : false;
      
      className = 'ItemRenderer${_selected ? ' ItemRenderer-selected' : ''}${_inactive ? ' inactive' : ''}';
    }
  }
  
  //---------------------------------
  // inactive
  //---------------------------------

  bool _inactive = false;

  bool get inactive => _inactive;
  
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

      later > updateLayout;
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

  @override
  void createChildren() {
    super.createChildren();

    SpanElement container = new SpanElement();
    
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

    later > invalidateData;
  }

  void invalidateData() {}

  void updateAfterInteraction() {}
  
  void updateForEditable() {}
  
  void invalidateDataChangesListener() => _data_changesHandler(null);
  
  void highlight() {
    if (_control == null) return;
    
    _control.style.setProperty('background-color', '#ccffcc', 'important');
    _control.style.transition = 'background-color .5s ease-out';
    
    if (_controlHighlightListener != null) {
      _controlHighlightListener.cancel();
      
      _controlHighlightListener = null;
    }
    
    new Timer(
        new Duration(milliseconds: 250), 
        () {
          _control.style.removeProperty('background-color');
          
          _controlHighlightListener = _control.onTransitionEnd.listen(
            (_) {
              _control.style.removeProperty('transition');
              
              if (_controlHighlightListener != null) {
                _controlHighlightListener.cancel();
                
                _controlHighlightListener = null;
              }
            }
          );
        }
    );
  }
  
  dynamic getDataToObserve() {
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

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _data_changesHandler(List<ChangeRecord> changes) {
    if (_fields != null) {
      if (_dataFieldsChangesListener != null) {
        _dataFieldsChangesListener.cancel();
        
        _dataFieldsChangesListener = null;
      }
      
      dynamic dataToObserve = getDataToObserve();
      
      if (dataToObserve is Observable) _dataFieldsChangesListener = dataToObserve.changes.listen(_data_changesHandler);
    }
    
    if (_enableHighlight && (changes != null)) {
      PropertyChangeRecord propertyChangeRecord = changes.firstWhere(
          (ChangeRecord changeRecord) => (
              (changeRecord is PropertyChangeRecord) &&
              (
                  (changeRecord.name == _field) ||
                  (
                    (_fields != null) &&
                    _fields.contains(changeRecord.name)
                  )
              )
              
          ),
          orElse: () => null
      );
      
      if (propertyChangeRecord != null) {
        notify(
            new FrameworkEvent<dynamic>(
                'dataPropertyChanged',
                relatedObject: _data
            )
        );
        
        later > highlight;
      }
    }
    
    _inactive = (_inactiveHandler != null) ? _inactiveHandler(data) : false;
    
    className = 'ItemRenderer${_selected ? ' ItemRenderer-selected' : ''}${_inactive ? ' inactive' : ''}';
    
    later > invalidateData;
  }
}

