part of dart_flex;

typedef int SortHandler(dynamic a, dynamic b, DataGridColumn column, HeaderData headerData);

abstract class IHeaderItemRenderer<D extends HeaderData> extends IItemRenderer {
  
  Event lastClickEvent;
  
  Stream<FrameworkEvent<D>> get onButtonClick;
  Stream<FrameworkEvent<int>> get onHeaderResize;
  Stream<FrameworkEvent<bool>> get onResizeTargetHovered;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  D get headerData;
  
  bool get isResizeTargetHovered;
  void set isResizeTargetHovered(bool value);
  
}

class HeaderItemRenderer<D extends HeaderData> extends ItemRenderer<HeaderData> implements IHeaderItemRenderer<HeaderData> {
  
  @event Stream<FrameworkEvent<D>> onButtonClick;
  @event Stream<FrameworkEvent<int>> onHeaderResize;
  @event Stream<FrameworkEvent<bool>> onResizeTargetHovered;

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  Button _button;
  
  Button get button => _button;
  
  bool _isResizeTargetHovered = false;
  int _resizeStartOffset = 0;
  
  bool get isResizeTargetHovered => _isResizeTargetHovered;
  void set isResizeTargetHovered(bool value) {
    if (value != _isResizeTargetHovered) {
      _isResizeTargetHovered = value;
      
      if (value) streamSubscriptionManager.add('mouse-down', window.onMouseDown.listen(_mouseDown_handler));
      else _resizeEnd_handler(null);
      
      notify('resizeTargetHovered', value);
      
      invalidateData();
    }
  }
  

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  Event lastClickEvent;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  D get headerData => _data;
  
  @override
  void set data(D value) {
    streamSubscriptionManager.flushIdent('highlight-listener');
    
    super.data = value;
    
    if (value != null) streamSubscriptionManager.add('highlight-listener', value.onHighlightedChanged.listen((_) => invalidateData()));
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null, SortHandler sortHandler}) : super(elementId: null, autoDrawBackground: false) {
    this.sortHandler = sortHandler;
  }

  static HeaderItemRenderer construct([SortHandler sortHandler= null]) => new HeaderItemRenderer(sortHandler: sortHandler);

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _button = new Button()
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
    
    _streamSubscriptionManager.add(
        'header_item_renderer_chainDataListChanges', 
        _button.onButtonClick.listen(_button_buttonClickHandler)
    );

    invalidateData();
    
    streamSubscriptionManager.add('mouse-move', _control.onMouseMove.listen(_mouseMove_handler));

    addComponent(_button);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
    if (
       (_button != null) &&
       (_data != null)
    ) _button.label = headerData.label;
    
    cssClasses = _isResizeTargetHovered ? 
                    const <String>['header-highlighted', 'header-in-resize-mode'] : 
                    (
                      (headerData != null && headerData.highlighted) ? 
                        const <String>['header-highlighted'] : 
                        null
                    );
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _button_buttonClickHandler(FrameworkEvent<dynamic> event) {
    lastClickEvent = _button.lastClickEvent;
    
    notify('buttonClick', headerData);
  }
  
  void _mouseMove_handler(MouseEvent event) {
    _resizeStartOffset = width - event.offset.x;
    
    isResizeTargetHovered = (_resizeStartOffset <= 7);
  }
  
  void _mouseDown_handler(MouseEvent event) {
    streamSubscriptionManager.flushIdent('mouse-move');
    streamSubscriptionManager.flushIdent('mouse-down');
    streamSubscriptionManager.flushIdent('resize-mouse-end');
    streamSubscriptionManager.flushIdent('resize-mouse-move');
    
    if (event.target == _button._control) {
      streamSubscriptionManager.add('resize-mouse-end', window.onMouseUp.listen(_resizeEnd_handler));
      streamSubscriptionManager.add('resize-mouse-move', window.onMouseMove.listen(_resize_handler));
    }
  }
  
  void _resizeEnd_handler(MouseEvent event) {
    streamSubscriptionManager.flushIdent('mouse-move');
    streamSubscriptionManager.flushIdent('mouse-down');
    streamSubscriptionManager.flushIdent('resize-mouse-end');
    streamSubscriptionManager.flushIdent('resize-mouse-move');
    
    streamSubscriptionManager.add('mouse-move', _control.onMouseMove.listen(_mouseMove_handler));
  }
  
  void _resize_handler(MouseEvent event) {
    notify('headerResize', event.movement.x);
  }
}

abstract class HeaderData extends EventDispatcher {
  
  Stream<FrameworkEvent> onHighlightedChanged;
  
  bool get highlighted;
  void set highlighted(bool value);
  
  final String label = '', labelLong = '', identifier = '';
  final Symbol field = null;
  final dynamic data = null;
  
}

class HeaderDataImpl extends EventDispatcherImpl implements HeaderData {
  
  @event Stream<FrameworkEvent> onHighlightedChanged;
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data = null;
  
  //---------------------------------
  // highlighted
  //---------------------------------
  
  bool _highlighted = false;
  
  bool get highlighted => _highlighted;
  void set highlighted(bool value) {
    if (value != _highlighted) {
      _highlighted = value;
      
      notify('highlightedChanged', value);
    }
  }
  
  HeaderDataImpl(this.identifier, this.field, this.label, this.labelLong);
  
  static HeaderDataImpl createSimple(String simpleName) => new HeaderDataImpl(simpleName, new Symbol(simpleName), simpleName, simpleName);
  
  String toString() => '$label : $field';
}

class DynamicHeaderDataImpl extends HeaderDataImpl {
  
  final dynamic data;
  
  DynamicHeaderDataImpl(String identifier, Symbol field, String label, String labelLong, this.data) : super(identifier, field, label, labelLong);
  
  static DynamicHeaderDataImpl createSimple(String simpleName, dynamic simpleData) => new DynamicHeaderDataImpl(simpleName, new Symbol(simpleName), simpleName, simpleName, simpleData);
}