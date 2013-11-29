part of dart_flex;

abstract class IUIWrapper implements IFrameworkEventDispatcher {
  
  //---------------------------------
  //
  // Events
  //
  //---------------------------------
  
  Stream<FrameworkEvent> get onStylePrefixChanged;
  Stream<FrameworkEvent> get onCSSClassesChanged;
  Stream<FrameworkEvent> get onIncludeInLayoutChanged;
  Stream<FrameworkEvent> get onAutoSizeChanged;
  Stream<FrameworkEvent> get onVisibleChanged;
  Stream<FrameworkEvent> get onXChanged;
  Stream<FrameworkEvent> get onYChanged;
  Stream<FrameworkEvent> get onWidthChanged;
  Stream<FrameworkEvent> get onPercentWidthChanged;
  Stream<FrameworkEvent> get onHeightChanged;
  Stream<FrameworkEvent> get onPercentHeightChanged;
  Stream<FrameworkEvent> get onPaddingLeftChanged;
  Stream<FrameworkEvent> get onPaddingRightChanged;
  Stream<FrameworkEvent> get onPaddingTopChanged;
  Stream<FrameworkEvent> get onPaddingBottomChanged;
  Stream<FrameworkEvent> get onLayoutChanged;
  Stream<FrameworkEvent> get onInheritsDefaultCSSChanged;
  Stream<FrameworkEvent> get onControlChanged;
  Stream<FrameworkEvent> get onInitializationComplete;
  Stream<FrameworkEvent> get onOwnerChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  bool get includeInLayout;
  set includeInLayout(bool value);
  
  bool get allowLayoutUpdate;
  set allowLayoutUpdate(bool value);

  bool get autoSize;
  set autoSize(bool value);

  bool get visible;
  set visible(bool value);
  
  bool get enabled;
  set enabled(bool value);

  int get x;
  set x(int value);

  int get y;
  set y(int value);

  int get width;
  set width(int value);

  double get percentWidth;
  set percentWidth(double value);

  int get height;
  set height(int value);

  double get percentHeight;
  set percentHeight(double value);

  int get paddingLeft;
  set paddingLeft(int value);

  int get paddingRight;
  set paddingRight(int value);

  int get paddingTop;
  set paddingTop(int value);

  int get paddingBottom;
  set paddingBottom(int value);
  
  bool get inheritsDefaultCSS;
  set inheritsDefaultCSS(bool value);

  ILayout get layout;
  set layout(ILayout value);
  
  //XTagRegistry get xTagRegistry;

  UpdateManager get later;

  bool get isInitialized;

  IUIWrapper get owner;

  List<IUIWrapper> get childWrappers;

  String get elementId;
  
  String get className;
  set className(String value);
  
  List<String> get cssClasses;
  set cssClasses(List<String> value);

  Element get control;
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void wrapTarget(Element target);
  void preInitialize(IUIWrapper forOwner);
  void invalidateLayout();
  void invalidateProperties();
  void addComponent(IUIWrapper element, {bool prepend: false});
  void removeComponent(IUIWrapper element);
  void removeAll();

  void operator []=(String type, Function eventHandler) => observeEventType(type, eventHandler);

}

class UIWrapper implements IUIWrapper {
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  FrameworkEventDispatcher _eventDispatcher;
  bool _isLayoutUpdateRequired = false;

  //---------------------------------
  // graphics
  //---------------------------------

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // reflowManager
  //---------------------------------

  ReflowManager _reflowManager;

  ReflowManager get reflowManager => _reflowManager;
  
  //---------------------------------
  // stylePrefix
  //---------------------------------

  static const EventHook<FrameworkEvent> onStylePrefixChangedEvent = const EventHook<FrameworkEvent>('stylePrefixChanged');
  Stream<FrameworkEvent> get onStylePrefixChanged => UIWrapper.onStylePrefixChangedEvent.forTarget(this);
  String _stylePrefix;
  bool _isStylePrefixChanged = false;

  String get stylePrefix => _stylePrefix;

  set stylePrefix(String value) {
    if (value != _stylePrefix) {
      _stylePrefix = value;

      notify(
        new FrameworkEvent('stylePrefixChanged')
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // enabled
  //---------------------------------
  
  bool _enabled = true;
  bool _isEnabledChanged = false;
  
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (value != _enabled) {
      _enabled = value;
      _isEnabledChanged = true;
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // classes
  //---------------------------------

  static const EventHook<FrameworkEvent> onCSSClassesChangedEvent = const EventHook<FrameworkEvent>('cssClassesChanged');
  Stream<FrameworkEvent> get onCSSClassesChanged => UIWrapper.onCSSClassesChangedEvent.forTarget(this);
  List<String> _cssClasses = <String>[];
  bool _isCSSClassesChanged = false;

  List<String> get cssClasses => _cssClasses;

  set cssClasses(List<String> value) {
    if (value != _cssClasses) {
      _cssClasses = value;
      _isCSSClassesChanged = true;

      notify(
        new FrameworkEvent('cssClassesChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // includeInLayout
  //---------------------------------

  static const EventHook<FrameworkEvent> onIncludeInLayoutChangedEvent = const EventHook<FrameworkEvent>('includeInLayoutChanged');
  Stream<FrameworkEvent> get onIncludeInLayoutChanged => UIWrapper.onIncludeInLayoutChangedEvent.forTarget(this);
  bool _includeInLayout = true;

  bool get includeInLayout => _includeInLayout;

  set includeInLayout(bool value) {
    if (value != _includeInLayout) {
      _includeInLayout = value;

      notify(
        new FrameworkEvent('includeInLayoutChanged')
      );

      if (_owner != null) _owner.invalidateProperties();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // allowLayoutUpdate
  //---------------------------------

  static const EventHook<FrameworkEvent> onAllowLayoutUpdateChangedEvent = const EventHook<FrameworkEvent>('allowLayoutUpdateChanged');
  Stream<FrameworkEvent> get onAllowLayoutUpdateChanged => UIWrapper.onAllowLayoutUpdateChangedEvent.forTarget(this);
  bool _allowLayoutUpdate = true;

  bool get allowLayoutUpdate => _allowLayoutUpdate;

  set allowLayoutUpdate(bool value) {
    if (value != _allowLayoutUpdate) {
      _allowLayoutUpdate = value;

      notify(
        new FrameworkEvent('allowLayoutUpdateChanged')
      );

      if (_owner != null) _owner.invalidateProperties();

      invalidateProperties();
    }
  }

  //---------------------------------
  // autoSize
  //---------------------------------

  static const EventHook<FrameworkEvent> onAutoSizeChangedEvent = const EventHook<FrameworkEvent>('autoSizeChanged');
  Stream<FrameworkEvent> get onAutoSizeChanged => UIWrapper.onAutoSizeChangedEvent.forTarget(this);
  bool _autoSize = true;

  bool get autoSize => _autoSize;

  set autoSize(bool value) {
    if (value != _autoSize) {
      _autoSize = value;

      notify(
        new FrameworkEvent('autoSizeChanged')
      );

      if (_owner != null) _owner.invalidateProperties();

      invalidateProperties();
    }
  }

  //---------------------------------
  // visible
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onVisibleChangedEvent = const EventHook<FrameworkEvent>('visibleChanged');
  Stream<FrameworkEvent> get onVisibleChanged => UIWrapper.onVisibleChangedEvent.forTarget(this);
  bool _visible = true;

  bool get visible => _visible;

  set visible(bool value) {
    if (value != _visible) {
      _visible = value;

      notify(
        new FrameworkEvent('visibleChanged')
      );

      _updateVisibility();
    }
  }

  //---------------------------------
  // x
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onXChangedEvent = const EventHook<FrameworkEvent>('xChanged');
  Stream<FrameworkEvent> get onXChanged => UIWrapper.onXChangedEvent.forTarget(this);
  int _x = 0;

  int get x => _x;

  set x(int value) {
    if (value != _x) {
      _x = value;

      notify(
        new FrameworkEvent('xChanged')
      );

      _updateControl(1);
    }
  }

  //---------------------------------
  // y
  //---------------------------------

  static const EventHook<FrameworkEvent> onYChangedEvent = const EventHook<FrameworkEvent>('yChanged');
  Stream<FrameworkEvent> get onYChanged => UIWrapper.onYChangedEvent.forTarget(this);
  int _y = 0;

  int get y => _y;

  set y(int value) {
    if (value != _y) {
      _y = value;

      notify(
        new FrameworkEvent('yChanged')
      );

      _updateControl(2);
    }
  }

  //---------------------------------
  // width
  //---------------------------------

  static const EventHook<FrameworkEvent> onWidthChangedEvent = const EventHook<FrameworkEvent>('widthChanged');
  Stream<FrameworkEvent> get onWidthChanged => UIWrapper.onWidthChangedEvent.forTarget(this);
  int _width = 0;

  int get width => _width;

  set width(int value) {
    if (value != _width) {
      _width = value;

      notify(
        new FrameworkEvent('widthChanged')
      );

      _updateControl(3);

      invalidateProperties();
    }
  }

  //---------------------------------
  // percentWidth
  //---------------------------------

  static const EventHook<FrameworkEvent> onPercentWidthChangedEvent = const EventHook<FrameworkEvent>('percentWidthChanged');
  Stream<FrameworkEvent> get onPercentWidthChanged => UIWrapper.onPercentWidthChangedEvent.forTarget(this);
  double _percentWidth = 0.0;

  double get percentWidth => _percentWidth;

  set percentWidth(double value) {
    if (value != _percentWidth) {
      _percentWidth = value;

      notify(
        new FrameworkEvent('percentWidthChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // height
  //---------------------------------

  static const EventHook<FrameworkEvent> onHeightChangedEvent = const EventHook<FrameworkEvent>('heightChanged');
  Stream<FrameworkEvent> get onHeightChanged => UIWrapper.onHeightChangedEvent.forTarget(this);
  int _height = 0;

  int get height => _height;

  set height(int value) {
    if (value != _height) {
      _height = value;

      notify(
        new FrameworkEvent('heightChanged')
      );

      _updateControl(4);

      invalidateProperties();
    }
  }

  //---------------------------------
  // percentHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onPercentHeightChangedEvent = const EventHook<FrameworkEvent>('percentHeightChanged');
  Stream<FrameworkEvent> get onPercentHeightChanged => UIWrapper.onPercentHeightChangedEvent.forTarget(this);
  double _percentHeight = 0.0;

  double get percentHeight => _percentHeight;

  set percentHeight(double value) {
    if (value != _percentHeight) {
      _percentHeight = value;

      notify(
        new FrameworkEvent('percentHeightChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingLeft
  //---------------------------------

  static const EventHook<FrameworkEvent> onPaddingLeftChangedEvent = const EventHook<FrameworkEvent>('paddingLeftChanged');
  Stream<FrameworkEvent> get onPaddingLeftChanged => UIWrapper.onPaddingLeftChangedEvent.forTarget(this);
  int _paddingLeft = 0;

  int get paddingLeft => _paddingLeft;

  set paddingLeft(int value) {
    if (value != _paddingLeft) {
      _paddingLeft = value;

      notify(
        new FrameworkEvent('paddingLeftChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingRight
  //---------------------------------

  static const EventHook<FrameworkEvent> onPaddingRightChangedEvent = const EventHook<FrameworkEvent>('paddingRightChanged');
  Stream<FrameworkEvent> get onPaddingRightChanged => UIWrapper.onPaddingRightChangedEvent.forTarget(this);
  int _paddingRight = 0;

  int get paddingRight => _paddingRight;

  set paddingRight(int value) {
    if (value != _paddingRight) {
      _paddingRight = value;

      notify(
        new FrameworkEvent('paddingRightChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingTop
  //---------------------------------

  static const EventHook<FrameworkEvent> onPaddingTopChangedEvent = const EventHook<FrameworkEvent>('paddingTopChanged');
  Stream<FrameworkEvent> get onPaddingTopChanged => UIWrapper.onPaddingTopChangedEvent.forTarget(this);
  int _paddingTop = 0;

  int get paddingTop => _paddingTop;

  set paddingTop(int value) {
    if (value != _paddingTop) {
      _paddingTop = value;

      notify(
        new FrameworkEvent('paddingTopChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingBottom
  //---------------------------------

  static const EventHook<FrameworkEvent> onPaddingBottomChangedEvent = const EventHook<FrameworkEvent>('paddingBottomChanged');
  Stream<FrameworkEvent> get onPaddingBottomChanged => UIWrapper.onPaddingBottomChangedEvent.forTarget(this);
  int _paddingBottom = 0;

  int get paddingBottom => _paddingBottom;

  set paddingBottom(int value) {
    if (value != _paddingBottom) {
      _paddingBottom = value;

      notify(
        new FrameworkEvent('paddingBottomChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // layout
  //---------------------------------

  static const EventHook<FrameworkEvent> onLayoutChangedEvent = const EventHook<FrameworkEvent>('layoutChanged');
  Stream<FrameworkEvent> get onLayoutChanged => UIWrapper.onLayoutChangedEvent.forTarget(this);
  ILayout _layout;

  ILayout get layout => _layout;
  set layout(ILayout value) {
    if (value != _layout) {
      _layout = value;

      notify(
        new FrameworkEvent('layoutChanged')
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // inheritsDefaultCSS
  //---------------------------------

  static const EventHook<FrameworkEvent> onInheritsDefaultCSSChangedEvent = const EventHook<FrameworkEvent>('inheritsDefaultCSSChanged');
  Stream<FrameworkEvent> get onInheritsDefaultCSSChanged => UIWrapper.onInheritsDefaultCSSChangedEvent.forTarget(this);
  bool _inheritsDefaultCSS = true;

  bool get inheritsDefaultCSS => _inheritsDefaultCSS;
  set inheritsDefaultCSS(bool value) {
    if (value != _inheritsDefaultCSS) {
      _inheritsDefaultCSS = value;
      
      if (_isInitialized) {
        later > _updateDefaultClass;
      }

      notify(
        new FrameworkEvent('inheritsDefaultCSSChanged')
      );
    }
  }

  //---------------------------------
  // addLaterElements
  //---------------------------------

  List<IUIWrapper> _addLaterElements = <IUIWrapper>[];

  //---------------------------------
  // later
  //---------------------------------

  UpdateManager _later;

  UpdateManager get later => _later;

  //---------------------------------
  // isInitialized
  //---------------------------------

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //---------------------------------
  // owner
  //---------------------------------

  static const EventHook<FrameworkEvent> onOwnerChangedEvent = const EventHook<FrameworkEvent>('ownerChanged');
  Stream<FrameworkEvent> get onOwnerChanged => UIWrapper.onOwnerChangedEvent.forTarget(this);
  IUIWrapper _owner;

  IUIWrapper get owner => _owner;

  //---------------------------------
  // childWrappers
  //---------------------------------

  List<IUIWrapper> _childWrappers = <IUIWrapper>[];

  List<IUIWrapper> get childWrappers => _childWrappers;

  //---------------------------------
  // elementId
  //---------------------------------

  String _elementId;

  String get elementId => _elementId;
  
  //---------------------------------
  // className
  //---------------------------------

  static const EventHook<FrameworkEvent> onClassNameChangedEvent = const EventHook<FrameworkEvent>('classNameChanged');
  Stream<FrameworkEvent> get onClassNameChanged => UIWrapper.onClassNameChangedEvent.forTarget(this);
  String _className = 'UIWrapper';

  String get className => _className;
  set className(String value) {
    if (value != _className) {
      if (_isInitialized) {
        _control.classes.removeWhere(
            (String classNameEntry) => true    
        );
      }
      
      _className = value;
      
      if (_isInitialized) later > _updateDefaultClass;

      notify(
        new FrameworkEvent('classNameChanged')
      );
    }
  }
  

  //---------------------------------
  // control
  //---------------------------------

  static const EventHook<FrameworkEvent> onControlChangedEvent = const EventHook<FrameworkEvent>('controlChanged');
  Stream<FrameworkEvent> get onControlChanged => UIWrapper.onControlChangedEvent.forTarget(this);
  Element _control;

  Element get control => _control;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  UIWrapper({String elementId: null}) {
    _later = new UpdateManager(this);
    _eventDispatcher = new FrameworkEventDispatcher(dispatcher: this);

    _elementId = elementId;

    _wrapDOMTarget();
  }

  //---------------------------------
  //
  // IFrameworkEventDispatcher
  //
  //---------------------------------

  bool hasObserver(String type) => _eventDispatcher.hasObserver(type);

  void observeEventType(String type, Function eventHandler) => _eventDispatcher.observeEventType(type, eventHandler);

  void ignoreEventType(String type, Function eventHandler) => _eventDispatcher.ignoreEventType(type, eventHandler);

  void notify(FrameworkEvent event) => _eventDispatcher.notify(event);

  //---------------------------------
  //
  // Operator overloads
  //
  //---------------------------------

  void operator []=(String type, Function eventHandler) => observeEventType(type, eventHandler);

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void wrapTarget(Element target) => _wrapDOMTarget(target: target);
  
  void preInitialize(IUIWrapper forOwner) {
    _reflowManager = new ReflowManager();
    _owner = forOwner;
    
    notify(
        new FrameworkEvent<IUIWrapper>(
            'ownerChanged',
            relatedObject: forOwner
        )
    );
    
    _initialize();
  }
  
  void invalidateLayout() {
    _isLayoutUpdateRequired = _allowLayoutUpdate;

    later > _commitProperties;
  }

  void invalidateProperties() {
    if (!_isLayoutUpdateRequired) invalidateLayout();
  }

  void addComponent(IUIWrapper element, {bool prepend: false}) {
    if (_childWrappers.indexOf(element) >= 0) return;
    
    final UIWrapper elementCast = element as UIWrapper;
    
    elementCast._reflowManager = _reflowManager;

    if (_control == null) {
      prepend ? _addLaterElements.insert(0, element) : _addLaterElements.add(element);
    } else {
      elementCast._owner = this;
      
      elementCast.notify(
          new FrameworkEvent<IUIWrapper>(
              'ownerChanged',
              relatedObject: this
          )
      );
      
      if (
          (_stylePrefix != null) &&
          (elementCast._stylePrefix == null)
      ) elementCast._stylePrefix = _stylePrefix;
      
      elementCast._initialize();
      
      if (_elementId != null) {
        prepend ? _control.children.insert(0, element.control) : _control.append(element.control);
      } else {
        prepend ? 
          _reflowManager.scheduleMethod(this, _prependControl, [element.control]) :
          _reflowManager.scheduleMethod(this, _appendControl, [element.control]);
      }

      invalidateLayout();
      
      _childWrappers.add(element);
    }
  }
  
  void _prependControl(Element controlToPrepend) => _control.children.insert(0, controlToPrepend);
  
  Node _appendControl(Element controlToAppend) => _control.append(controlToAppend);

  void removeComponent(IUIWrapper element, {bool flush: true}) {
    if (
        (_control != null) &&
        (element != null) &&
        (element.control != null) &&
        _control.contains(element.control)
    ) _control.children.remove(element.control);
    
    _childWrappers.remove(element);
    _addLaterElements.remove(element);
    
    if (flush) element.removeAll();
    
    invalidateLayout();
  }

  void removeAll() {
    int i = _childWrappers.length;
    
    while (i > 0) removeComponent(_childWrappers[--i]);
    
    _childWrappers = <IUIWrapper>[];
  }
  
  void propertiesInvalidated() {}

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _setControl(Element element) {
    _control = element;
    
    _updateVisibility();
    _updateEnabledStatus();
    
    if (_inheritsDefaultCSS)
      _reflowManager.scheduleMethod(this, _addDefaultClass, [], forceSingleExecution: true);
    
    if (_cssClasses != null)
      _reflowManager.scheduleMethod(this, _addAllPendingClasses, [], forceSingleExecution: true);

    _updateVisibility();
    _updateControl(5);

    notify(
      new FrameworkEvent<Element>(
          'controlChanged',
          relatedObject: element
      )
    );

    invalidateProperties();
    
    _addAllPendingElements();
  }
  
  void _updateDefaultClass() {
    final List<String> cssList = '_${_className}'.split(' ');
    
    cssList.forEach(
      (String css) {
        if (_inheritsDefaultCSS) {
          if (!_control.classes.contains(css)) _control.classes.add(css);
        } else {
          _control.classes.remove(css);
        }
      }
    );
  }
  
  bool _addDefaultClass() => _control.classes.add('_$_className');
  
  void _addAllPendingClasses() => _control.classes.addAll(_cssClasses);

  void _updateControl(int type) {
    if (_control != null) {
      if (_elementId == null) {
        final String cssX = '${_x}px';
        final String cssY = '${_y}px';
        final String cssWidth = (_width == 0) ? 'auto' : '${_width}px';
        final String cssHeight = (_height == 0) ? 'auto' : '${_height}px';

        switch (type) {
          case 1 : _reflowManager.invalidateCSS(_control, 'left', cssX);        break;
          case 2 : _reflowManager.invalidateCSS(_control, 'top', cssY);         break;
          case 3 : _reflowManager.invalidateCSS(_control, 'width', cssWidth);   break;
          case 4 : _reflowManager.invalidateCSS(_control, 'height', cssHeight); break;
          case 5 :
            _reflowManager.invalidateCSS(_control, 'left', cssX);
            _reflowManager.invalidateCSS(_control, 'top', cssY);
            _reflowManager.invalidateCSS(_control, 'width', cssWidth);
            _reflowManager.invalidateCSS(_control, 'height', cssHeight);

            break;
        }
      } /*else {
        width = _control.clientWidth;
        height = _control.clientHeight;
      }*/
    }
  }

  void _wrapDOMTarget({Element target: null}) {
    if (
        (target == null) &&
        (_elementId != null)
    ) target = querySelector(_elementId);
    
    if (target != null) {
      _control = target;
      
      _reflowManager = new ReflowManager();
      
      _updateVisibility();
      _updateEnabledStatus();

      window.onResize.listen(_invalidateSize);
      
      notify(
          new FrameworkEvent<Element>(
              'controlChanged',
              relatedObject: target
          )
      );
      
      _initialize();
      
      later > _updateSize;
    }
  }
  
  static const EventHook<FrameworkEvent> onInitializationCompleteEvent = const EventHook<FrameworkEvent>('initializationComplete');
  Stream<FrameworkEvent> get onInitializationComplete => UIWrapper.onInitializationCompleteEvent.forTarget(this);

  void _initialize() {
    if (!_isInitialized) {
      _isInitialized = true;

      _createChildren();
      
      notify(
          new FrameworkEvent(
              'initializationComplete'
          )
      );

      invalidateProperties();
    }
  }

  void _createChildren() {}

  void _commitProperties() {
    if (_isCSSClassesChanged) {
      _isCSSClassesChanged = false;
      
      if (_control != null) {
        _control.classes.removeWhere((_) => true);
        
        _updateDefaultClass();
        
        _cssClasses.forEach(
          (String cssClass) {
            if (!_control.classes.contains(cssClass)) _control.classes.add(cssClass);
          }
        );
      }
    }
    
    if (_isEnabledChanged) {
      _isEnabledChanged = false;
      
      _updateEnabledStatus();
    }
    
    if (_isLayoutUpdateRequired) {
      _isLayoutUpdateRequired = false;

      _updateLayout();
    }
    
    propertiesInvalidated();
  }
  
  void _updateEnabledStatus() {
    if (_control != null) reflowManager.invalidateCSS(_control, 'pointer-events', (_enabled ? 'auto' : 'none'));
  }

  void _updateLayout() {
    if ( 
      _allowLayoutUpdate &&
      (_width > 0) &&
      (_height > 0)
    ) {
      if (_layout != null) {
        _layout.doLayout(
           _width,
           _height,
           _getPageItemSize(),
           _getPageOffset(),
           _getPageSize(),
           _childWrappers
        );
      } else {
        IUIWrapper element;

        _childWrappers.forEach(
          (element) {
            element.x = element.paddingLeft;
            element.y = element.paddingRight;
            element.width = _width - element.paddingLeft - element.paddingRight;
            element.height = _height - element.paddingTop - element.paddingBottom;
          }
        );
      }
    }
  }

  int _getPageItemSize() => 0;
  int _getPageOffset() => 0;
  int _getPageSize() => 0;
  
  void forceInvalidateSize() => _invalidateSize(null);

  void _invalidateSize(Event event) => later > _updateSize;

  void _updateSize() {
    if (_control != null) {
      final Rectangle rect = _control.client;
      
      if (
          (rect.width == 0) && 
          (rect.height == 0)
      ) reflowManager.animationFrame.whenComplete(_updateSize);
      else {
        width = rect.width;
        height = rect.height;
      }
    } else {
      width = height = 0;
    }
  }

  void _updateVisibility() {
    if (
        (_control != null) &&
        (_reflowManager != null)
    ) {
      _control.hidden = !_visible;
      
      _reflowManager.invalidateCSS(_control, 'display', (_visible ? 'block' : 'none'));
    }
  }

  void _addAllPendingElements() {
    final List<IUIWrapper> listClone = new List<IUIWrapper>.from(_addLaterElements, growable:false);
    
    _addLaterElements = <IUIWrapper>[];
    
    listClone.forEach(
        (IUIWrapper element) => addComponent(element)
    );
  }
}