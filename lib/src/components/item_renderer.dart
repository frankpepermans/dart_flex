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
  
  InvalidHandler get validationHandler;
  set validationHandler(InvalidHandler value);
  
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
  
  Timer _highlightTimer;
  bool _isHighlightActivated = false;
  List<String> _dynamicListenerIdents;

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

  //---------------------------------
  // index
  //---------------------------------

  int index = 0;

  //---------------------------------
  // data
  //---------------------------------

  dynamic _data;

  dynamic get data => _data;
  set data(dynamic value) {
    if (value != _data) {
      _data = value;
      
      getDataToObserve();
      
      _inactive = (_inactiveHandler != null) ? _inactiveHandler(data) : false;
      
      _rebuildCSS();
      
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
      
      getDataToObserve();
      
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
      
      later > _rebuildCSS;

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
      
      later > _rebuildCSS;
    }
  }
  
  //---------------------------------
  // validationHandler
  //---------------------------------

  InvalidHandler _validationHandler;

  InvalidHandler get validationHandler => _validationHandler;
  set validationHandler(InvalidHandler value) {
    if (value != _validationHandler) {
      _validationHandler = value;
      
      later > invalidateData;
    }
  }
  
  //---------------------------------
  // inactive
  //---------------------------------

  bool _inactive = false;

  bool get inactive => _inactive;
  
  //---------------------------------
  // isInvalid
  //---------------------------------

  bool _isInvalid = false;

  bool get isInvalid => _isInvalid;
  
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

    final DivElement container = new DivElement();
    
    _setControl(container);
    
    _streamSubscriptionManager.add(
        'item_renderer_containerClick', 
        container.onClick.listen(
            (MouseEvent event) => notify(
                new FrameworkEvent(
                    'click'
                )
            )
        )
    );
    
    _streamSubscriptionManager.add(
        'item_renderer_containerMouseOver', 
        container.onMouseOver.listen(
            (MouseEvent event) => notify(
                new FrameworkEvent(
                    'mouseOver'
                )
            )
        )
    );
    
    _streamSubscriptionManager.add(
        'item_renderer_containerMouseOut', 
        container.onMouseOut.listen(
            (MouseEvent event) => notify(
                new FrameworkEvent(
                    'mouseOut'
                )
            )
        )
    );

    later > invalidateData;
  }

  void invalidateData() {
    _isInvalid = (_validationHandler != null) ? !_validationHandler(data) : false;
          
    later > _rebuildCSS;
  }

  void updateAfterInteraction() {}
  
  void updateForEditable() {}
  
  void invalidateDataChangesListener() => _data_changesHandler(null);
  
  void highlight() {
    if (
        (_control == null) ||
        _isHighlightActivated
    ) return;
    
    final String oldValue = _control.style.getPropertyValue('background-color');
    
    _reflowManager.invalidateCSS(_control, 'background-color', '#ccffcc');
    
    _isHighlightActivated = true;
    
    _reflowManager.layoutFrame.whenComplete(
      () => _highlightTimer = new Timer(
          new Duration(milliseconds: 350), 
          () {
            _control.style.setProperty('background-color', oldValue, 'important');
            
            _isHighlightActivated = false;
          }
      )     
    );
  }
  
  dynamic getDataToObserve({dynamic dataOverride: null}) {
    if (_dynamicListenerIdents != null) _dynamicListenerIdents.forEach(
      (String listenerIdent) => _streamSubscriptionManager.flushIdent(listenerIdent)
    );
    
    _dynamicListenerIdents = <String>[];
    
    if (_data == null) return null;
    
    dynamic value = _data;
    
    _addListeners(_data, 'item_renderer_dataChanges');
    
    if (dataOverride != null) {
      value = dataOverride;
      
      _addListeners(dataOverride, 'item_renderer_dataOverrideChanges');
    }
    
    if (_fields != null) {
      int cnt = 0;
      
      _fields.forEach(
          (Symbol subField) {
            if (value != null) value = value[subField];
            
            _addListeners(value, 'item_renderer_chainDataChanges_${cnt++}');
          }
      );
    }
    
    return value;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _addListeners(dynamic value, String ident) {
    final String singleIdent = '${ident}_single';
    final String listIdent = '${ident}_list';
    
    _dynamicListenerIdents.add(singleIdent);
    _dynamicListenerIdents.add(listIdent);
    
    if (value is Observable) _streamSubscriptionManager.add(
        singleIdent, 
        value.changes.listen(_data_changesHandler)
    );
    else if (value is ObservableList) _streamSubscriptionManager.add(
        listIdent, 
        value.listChanges.listen(_data_changesHandler)
    );
  }
  
  void _rebuildCSS() {
    final String mainClassName = className.split(' ').first;
          
    className = '${mainClassName}${_selected ? ' ${mainClassName}-selected' : ''}${_inactive ? ' inactive' : ''}${_isInvalid ? ' invalid' : ''}';
  }
  
  void _data_changesHandler(Iterable<dynamic> changes) {
    if (_enableHighlight && (changes != null)) {
      final dynamic bindableRecord = changes.firstWhere(
          (dynamic changeRecord) => (
              (changeRecord is ListChangeRecord) ||
              (
                  (changeRecord is PropertyChangeRecord) &&
                  (
                      (changeRecord.name == _field) ||
                      (
                          (_fields != null) &&
                          _fields.contains(changeRecord.name)
                      )
                  ) 
              )
          ),
          orElse: () => null
      );
      
      if (bindableRecord != null) {
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
    
    later > _rebuildCSS;
    
    later > invalidateData;
    
    getDataToObserve();
  }
}

