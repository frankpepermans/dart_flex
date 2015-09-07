part of dart_flex;

class FloatingWindow extends VGroup {
  
  @event Stream<FrameworkEvent> onClose;
  
  Group header, content, footer;
  Button closeButton;
  
  final List<BaseComponent> _pendingHeaderElements = <BaseComponent>[];
  final List<BaseComponent> _pendingContentElements = <BaseComponent>[];
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  FloatingWindow() : super() {
    _className = 'floating-window';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    header = new HGroup()
      ..className = 'floating-window-header'
      ..percentWidth = 100.0
      ..height = 32
      ..gap = 0
      ..onControlChanged.listen((FrameworkEvent<Element> event) => _addListeners(event.relatedObject));
    
    content = new VGroup()
      ..className = 'floating-window-content'
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    footer = new HGroup()
      ..className = 'floating-window-footer'
      ..percentWidth = 100.0
      ..gap = 0
      ..height = 24;
    
    closeButton = new Button()
      ..className = 'floating-window-close-button'
      ..width = 22
      ..percentHeight = 100.0
      ..label = 'x'
      ..onButtonClick.listen((_) => notify(new FrameworkEvent('close')));
    
    final VGroup resizeHandleGroup = new VGroup()
      ..width = 10
      ..percentHeight = 100.0;
    
    final Group resizeHandle = new Group()
      ..className = 'floating-window-resize-handler'
      ..width = 10
      ..height = 10
      ..onControlChanged.listen((FrameworkEvent<Element> event) => _addResizeListeners(event.relatedObject));
    
    if (_pendingHeaderElements.isNotEmpty) {
      _pendingHeaderElements.forEach((BaseComponent E) => header.addComponent(E));
      
      _pendingHeaderElements.clear();
    }
    
    if (_pendingContentElements.isNotEmpty) {
      _pendingContentElements.forEach((BaseComponent E) => content.addComponent(E));
      
      _pendingContentElements.clear();
    }
    
    resizeHandleGroup.addComponent(new Spacer()..percentHeight = 100.0..width = 1);
    resizeHandleGroup.addComponent(resizeHandle);
    
    header.addComponent(new Spacer()..percentWidth = 100.0..percentHeight = 100.0.._className = 'floating-window-header-spacing');
    header.addComponent(closeButton);
    
    footer.addComponent(new Spacer()..percentWidth = 100.0..percentHeight = 100.0);
    footer.addComponent(resizeHandleGroup);
    
    super.addComponent(header);
    super.addComponent(content);
    super.addComponent(footer);
  }
  
  @override
  void addComponent(BaseComponent element, {bool prepend: false}) {
    if (content == null) {
      _pendingContentElements.add(element);
      
      return;
    }
    
    content.addComponent(element);
  }
  
  void addHeaderComponent(BaseComponent element, {bool prepend: false}) {
    if (content == null) {
      _pendingHeaderElements.add(element);
      
      return;
    }
    
    header.addComponent(element, prepend: true);
  }
  
  void _addListeners(Element e) {
    streamSubscriptionManager.add('mouse-down', e.onMouseDown.listen(_startDrag));
  }
  
  void _addResizeListeners(Element e) {
    streamSubscriptionManager.add('resize-mouse-down', e.onMouseDown.listen(_startResize));
  }
  
  void _startDrag(MouseEvent event) {
    streamSubscriptionManager.add('mouse-up', document.onMouseUp.listen(_endDrag));
    streamSubscriptionManager.add('mouse-move', document.onMouseMove.listen(_doDrag));
    
    //event.preventDefault();
  }
  
  void _endDrag(MouseEvent event) {
    streamSubscriptionManager.flushIdent('mouse-up');
    streamSubscriptionManager.flushIdent('mouse-move');
    
    event.preventDefault();
  }
  
  void _doDrag(MouseEvent event) {
    x = paddingLeft += event.movement.x;
    y = paddingTop += event.movement.y;
    
    event.preventDefault();
  }
  
  void _startResize(MouseEvent event) {
    streamSubscriptionManager.add('resize-mouse-up', document.onMouseUp.listen(_endResize));
    streamSubscriptionManager.add('resize-mouse-move', document.onMouseMove.listen(_doResize));
    
    event.preventDefault();
  }
  
  void _endResize(MouseEvent event) {
    streamSubscriptionManager.flushIdent('resize-mouse-up');
    streamSubscriptionManager.flushIdent('resize-mouse-move');
    
    event.preventDefault();
  }
  
  void _doResize(MouseEvent event) {
    width += event.movement.x;
    height += event.movement.y;
    
    event.preventDefault();
  }
}