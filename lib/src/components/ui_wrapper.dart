part of dart_flex;

abstract class IUIWrapper implements IFlexLayout, IFrameworkEventDispatcher, ILifeCycle, ICallLater {
  
  //---------------------------------
  //
  // Events
  //
  //---------------------------------
  
  Stream<FrameworkEvent> get onStylePrefixChanged;
  Stream<FrameworkEvent> get onCSSClassesChanged;
  Stream<FrameworkEvent> get onVisibleChanged;
  Stream<FrameworkEvent> get onInheritsDefaultCSSChanged;
  Stream<FrameworkEvent<Element>> get onControlChanged;
  Stream<FrameworkEvent> get onInitializationComplete;
  Stream<FrameworkEvent> get onOwnerChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  ReflowManager get reflowManager;
  
  StreamSubscriptionManager get streamSubscriptionManager;

  bool get visible;
  set visible(bool value);
  
  bool get disableRemoveComponents;
  set disableRemoveComponents(bool value);
  
  bool get useMatrixTransformations;
  set useMatrixTransformations(bool value);
  
  bool get enabled;
  set enabled(bool value);
  
  bool get inheritsDefaultCSS;
  set inheritsDefaultCSS(bool value);

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
  void addComponent(IUIWrapper element, {bool prepend: false});
  void removeComponent(IUIWrapper element);
  void removeAll();
  void flushHandler();
  void transportComponents(IUIWrapper target);

  void operator []=(String type, Function eventHandler) => observeEventType(type, eventHandler);

}

class UIWrapper extends Object with FlexLayoutMixin, CallLaterMixin, FrameworkEventDispatcherMixin implements IUIWrapper {
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  bool _isLayoutUpdateRequired = false;
  
  int _getPageItemSize() => 0;
  int _getPageOffset() => 0;
  int _getPageSize() => 0;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onInitializationCompleteEvent = const EventHook<FrameworkEvent>('initializationComplete');
  Stream<FrameworkEvent> get onInitializationComplete => UIWrapper.onInitializationCompleteEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent<IUIWrapper>> onSkinPartAddedEvent = const EventHook<FrameworkEvent<IUIWrapper>>('skinPartAdded');
  Stream<FrameworkEvent<IUIWrapper>> get onSkinPartAdded => UIWrapper.onSkinPartAddedEvent.forTarget(this);

  //---------------------------------
  // reflowManager
  //---------------------------------

  ReflowManager _reflowManager;

  ReflowManager get reflowManager => _reflowManager;
  
  //---------------------------------
  // streamSubscriptionManager
  //---------------------------------

  StreamSubscriptionManager _streamSubscriptionManager = new StreamSubscriptionManager();

  StreamSubscriptionManager get streamSubscriptionManager => _streamSubscriptionManager;
  
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
  // useMatrixTransformations
  //---------------------------------
  
  bool _useMatrixTransformations = false;
  
  bool get useMatrixTransformations => _useMatrixTransformations;
  set useMatrixTransformations(bool value) {
    final bool newValue = (window.css.supports('${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)')) ? value : false;
    
    if (newValue != _useMatrixTransformations) {
      _useMatrixTransformations = newValue;
      
      _updateControl(1);
      _updateControl(2);
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
  // disableRemoveComponents
  //---------------------------------
  
  bool _disableRemoveComponents = false;
  
  bool get disableRemoveComponents => _disableRemoveComponents;
  set disableRemoveComponents(bool value) {
    if (value != _disableRemoveComponents) {
      _disableRemoveComponents = value;
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

      later > updateVisibility;
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

  static const EventHook<FrameworkEvent<Element>> onControlChangedEvent = const EventHook<FrameworkEvent<Element>>('controlChanged');
  Stream<FrameworkEvent<Element>> get onControlChanged => UIWrapper.onControlChangedEvent.forTarget(this);
  Element _control;

  Element get control => _control;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  UIWrapper({String elementId: null}) {
    updateManager = new UpdateManager(this);
    
    _eventDispatcher = new FrameworkEventDispatcher(dispatcher: this);

    _elementId = elementId;

    _wrapDOMTarget();
  }

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
    
    initialize();
  }
  
  void invalidateLayout() {
    _isLayoutUpdateRequired = _allowLayoutUpdate;

    later > commitProperties;
  }

  void invalidateProperties() {
    if (!_isLayoutUpdateRequired) invalidateLayout();
  }
  
  void invalidateSize(Event event) => later > updateSize;
  
  void initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      
      createChildren();
      
      if (_control != null) later > updateVisibility;
      
      notify(
          new FrameworkEvent(
              'initializationComplete'
          )
      );

      invalidateProperties();
    }
  }
  
  void invalidateOwnerProperties() {
    if (_owner != null) _owner.invalidateProperties();
  }

  void createChildren() {}
  
  void commitProperties() {
    if (_isCSSClassesChanged) {
      _isCSSClassesChanged = false;
      
      if (_control != null) {
        _updateDefaultClass();
        
        if (_cssClasses != null) _cssClasses.forEach(
          (String cssClass) {
            if (!_control.classes.contains(cssClass)) _control.classes.add(cssClass);
          }
        );
      }
    }
    
    if (_isEnabledChanged) {
      _isEnabledChanged = false;
      
      updateEnabledStatus();
    }
    
    if (_isLayoutUpdateRequired) {
      _isLayoutUpdateRequired = false;

      updateLayout();
    }
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
      
      elementCast.initialize();
      
      if (_elementId != null) {
        prepend ? _prependControl(element.control) : _appendControl(element.control);
      } else {
        prepend ? 
          _reflowManager.scheduleMethod(this, _prependControl, [element.control]) :
          _reflowManager.scheduleMethod(this, _appendControl, [element.control]);
      }

      invalidateLayout();
      
      _childWrappers.add(element);
    }
  }

  void removeComponent(IUIWrapper element, {bool flush: true}) {
    if (_disableRemoveComponents) return;
    
    if (
        (_control != null) &&
        (element != null) &&
        (element.control != null) &&
        _control.contains(element.control)
    ) _control.children.remove(element.control);
    
    _childWrappers.remove(element);
    _addLaterElements.remove(element);
    
    if (flush) {
      element.flushHandler();
      
      element.removeAll();
    }
    
    invalidateLayout();
  }

  void removeAll() {
    if (_disableRemoveComponents) return;
    
    int i = _childWrappers.length;
    
    while (i > 0) removeComponent(_childWrappers[--i]);
    
    _childWrappers = <IUIWrapper>[];
  }
  
  void flushHandler() => _streamSubscriptionManager.flushAll();
  
  void forceInvalidateSize() => invalidateSize(null);
  
  void updateLayout() {
    if ( 
      _allowLayoutUpdate &&
      (_width > 0) &&
      (_height > 0)
    ) {
      if (_layout != null) _layout.doLayout(
          _width,
          _height,
          _getPageItemSize(),
          _getPageOffset(),
          _getPageSize(),
          _childWrappers
      );
      else _childWrappers.forEach(
          (IFlexLayout element) {
            element.x = element.paddingLeft;
            element.y = element.paddingRight;
            element.width = _width - element.paddingLeft - element.paddingRight;
            element.height = _height - element.paddingTop - element.paddingBottom;
          }
      );
    }
  }
  
  void updateSize() {
    if (_control != null) {
      Element parentElement = _control;
      
      while (parentElement != null) {
        if (
            (
              (parentElement.attributes.containsKey('aria-hidden')) &&
              (parentElement.attributes['aria-hidden'] == 'true') 
            ) ||
            (parentElement.style.display == 'none')
        ) {
          reflowManager.animationFrame.whenComplete(updateSize);
          
          return;
        }
          
        parentElement = parentElement.parent;
      }
      
      final Rectangle rect = _control.client;
      
      if (
          (rect.width == 0) && 
          (rect.height == 0)
      ) reflowManager.animationFrame.whenComplete(updateSize);
      else {
        width = rect.width;
        height = rect.height;
      }
    } else width = height = 0;
  }

  void updateVisibility() {
    if (
        (_control != null) &&
        (_reflowManager != null)
    ) {
      _control.hidden = !_visible;
      
      if (_control.style.display == 'none') _reflowManager.invalidateCSS(_control, 'display', (_visible ? 'block' : 'none'));
      
      _reflowManager.invalidateCSS(_control, 'visibility', (_visible ? 'visible' : 'hidden'));
    }
  }
  
  void updateEnabledStatus() {
    if (_control != null) reflowManager.invalidateCSS(_control, 'pointer-events', (_enabled ? 'auto' : 'none'));
  }
  
  void transportComponents(IUIWrapper target) {
    if (_childWrappers != null) {
      final List<IUIWrapper> list = <IUIWrapper>[];
      IUIWrapper element;
      int i = _childWrappers.length;
      
      _disableRemoveComponents = false;
      
      while (i > 0) {
        element = _childWrappers[--i];
        
        removeComponent(element, flush: false);
        
        list.insert(0, element);
      }
      
      list.forEach(
        (IUIWrapper wrapper) => target.addComponent(wrapper) 
      );
    }
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  Node _prependControl(Element controlToPrepend) => _appendControl(controlToPrepend);
  
  Node _appendControl(Element controlToAppend) => _control.append(controlToAppend);

  void _setControl(Element element) {
    _control = element;
    
    _control.style.visibility = 'none';
    
    if (_inheritsDefaultCSS) _reflowManager.scheduleMethod(this, _addDefaultClass, [], forceSingleExecution: true);
    
    if (_cssClasses != null) _reflowManager.scheduleMethod(this, _addAllPendingClasses, [], forceSingleExecution: true);

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
    
    if (_isInitialized) {
      _control.classes.removeWhere(
          (String classNameEntry) => !cssList.contains(classNameEntry)    
      );
    }
    
    cssList.forEach(
      (String css) {
        if (_inheritsDefaultCSS) {
          if (!_control.classes.contains(css)) _control.classes.add(css);
        } else _control.classes.remove(css);
      }
    );
  }
  
  bool _addDefaultClass() => _control.classes.add('_$_className');
  
  void _addAllPendingClasses() => _control.classes.addAll(_cssClasses);

  void _updateControl(int type) {
    if (
        (_control != null) &&  
        (_elementId == null)
    ) {
      final _ElementCSSMap cssMap = _reflowManager._elements[_control];
      
      if (_useMatrixTransformations) {
        if (cssMap != null) switch (type) {
          case 1 : case 2 : cssMap.setProperty('${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)');  break;
          case 3 : cssMap.setProperty('width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : cssMap.setProperty('height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            cssMap.setProperty('${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)');
            cssMap.setProperty('width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));
            cssMap.setProperty('height', ((_height == 0) ? 'auto' : (_height.toString() + 'px')));

            break;
        } else switch (type) {
          case 1 : case 2 : _reflowManager.invalidateCSS(_control, '${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)');  break;
          case 3 : _reflowManager.invalidateCSS(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : _reflowManager.invalidateCSS(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            _reflowManager.invalidateCSS(_control, '${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)');
            _reflowManager.invalidateCSS(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));
            _reflowManager.invalidateCSS(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px')));

            break;
        }
      } else {
        if (cssMap != null) switch (type) {
          case 1 : cssMap.setProperty('left', (_x.toString() + 'px'));                                    break;
          case 2 : cssMap.setProperty('top', (_y.toString() + 'px'));                                     break;
          case 3 : cssMap.setProperty('width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : cssMap.setProperty('height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            cssMap.setProperty('left', (_x.toString() + 'px'));
            cssMap.setProperty('top', (_y.toString() + 'px'));
            cssMap.setProperty('width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));
            cssMap.setProperty('height', ((_height == 0) ? 'auto' : (_height.toString() + 'px')));

            break;
        } else switch (type) {
          case 1 : _reflowManager.invalidateCSS(_control, 'left', (_x.toString() + 'px'));                                    break;
          case 2 : _reflowManager.invalidateCSS(_control, 'top', (_y.toString() + 'px'));                                     break;
          case 3 : _reflowManager.invalidateCSS(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : _reflowManager.invalidateCSS(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            _reflowManager.invalidateCSS(_control, 'left', (_x.toString() + 'px'));
            _reflowManager.invalidateCSS(_control, 'top', (_y.toString() + 'px'));
            _reflowManager.invalidateCSS(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));
            _reflowManager.invalidateCSS(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px')));

            break;
        }
      }
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
      
      _streamSubscriptionManager.add('windowResize', window.onResize.listen(invalidateSize), flushExisting: true);
      
      notify(
          new FrameworkEvent<Element>(
              'controlChanged',
              relatedObject: target
          )
      );
      
      initialize();
      
      later > updateSize;
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