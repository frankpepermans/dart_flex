part of dart_flex;

abstract class BaseComponent implements ComponentLifeCycle, ComponentLayout, EventDispatcher {
  
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
  Stream<FrameworkEvent<BaseComponent>> get onOwnerChanged;
  Stream<FrameworkEvent<List<SkinState>>> get onCurrentSkinStatesChanged;
  Stream<FrameworkEvent<List<SkinState>>> get onIncludeInChanged;
  Stream<FrameworkEvent<List<SkinState>>> get onExcludeFromChanged;
  Stream<FrameworkEvent> get onSkinPartAdded;
  Stream<FrameworkEvent> get onSkinPartRemoved;
  Stream<FrameworkEvent> get onClassNameChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  ReflowManager get reflowManager;
  
  StreamSubscriptionManager get streamSubscriptionManager;
  
  List<SkinState> get currentSkinStates;
  set currentSkinStates(List<SkinState> value);
  
  List<SkinState> get includeIn;
  set includeIn(List<SkinState> value);
    
  List<SkinState> get excludeFrom;
  set excludeFrom(List<SkinState> value);

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

  BaseComponent get owner;

  List<BaseComponent> get childWrappers;

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
  void addComponent(BaseComponent element, {bool prepend: false});
  void removeComponent(BaseComponent element);
  void onComponentAdded();
  void removeAll();
  void flushHandler();
  void transportComponents(BaseComponent target);
  void updateAfterSkinStateChanged(BaseComponent recursiveChildWrapper);

  void operator []=(String type, Function eventHandler) => observeEventType(type, eventHandler);

}

class Component extends Object with BaseComponentMixin, EventDispatcherMixin implements BaseComponent {
  
  @event Stream<FrameworkEvent> onInitializationComplete;
  @event Stream<FrameworkEvent> onSkinPartAdded;
  @event Stream<FrameworkEvent> onSkinPartRemoved;
  @event Stream<FrameworkEvent> onStylePrefixChanged;
  @event Stream<FrameworkEvent<List<SkinState>>> onCurrentSkinStatesChanged;
  @event Stream<FrameworkEvent<List<SkinState>>> onIncludeInChanged;
  @event Stream<FrameworkEvent<List<SkinState>>> onExcludeFromChanged;
  @event Stream<FrameworkEvent> onCSSClassesChanged;
  @event Stream<FrameworkEvent> onVisibleChanged;
  @event Stream<FrameworkEvent> onInheritsDefaultCSSChanged;
  @event Stream<FrameworkEvent<BaseComponent>> onOwnerChanged;
  @event Stream<FrameworkEvent> onClassNameChanged;
  @event Stream<FrameworkEvent<Element>> onControlChanged;
  
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
  
  bool awaitLayoutBeforeRendering = false;

  //---------------------------------
  // reflowManager
  //---------------------------------

  ReflowManager _reflowManager = new ReflowManager();

  ReflowManager get reflowManager => _reflowManager;
  
  //---------------------------------
  // streamSubscriptionManager
  //---------------------------------

  StreamSubscriptionManager _streamSubscriptionManager = new StreamSubscriptionManager();

  StreamSubscriptionManager get streamSubscriptionManager => _streamSubscriptionManager;
  
  //---------------------------------
  // stylePrefix
  //---------------------------------

  String _stylePrefix;

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
    bool newValue;
    
    try {
      newValue = (window.css.supports('${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)')) ? value : false;
    } catch (error) {
      newValue = false;
    }
    
    if (newValue != _useMatrixTransformations) {
      _useMatrixTransformations = newValue;
      
      if (_childWrappers != null) _childWrappers.forEach(
        (BaseComponent W) => W.useMatrixTransformations = value    
      );
      
      _updateControl(1);
      _updateControl(2);
    }
  }
  
  final List<SkinState> _skinStates = <SkinState>[];
  
  //---------------------------------
  // currentSkinStates
  //---------------------------------
  
  List<SkinState> _currentSkinStates;
  
  List<SkinState> get currentSkinStates => _currentSkinStates;
  void set currentSkinStates(List<SkinState> value) {
    if (value != _currentSkinStates) {
      _currentSkinStates = value;
      
      notify(
        new FrameworkEvent(
            'currentSkinStatesChanged',
            relatedObject: value
        )
      );
    }
  }
  
  //---------------------------------
  // includeIn
  //---------------------------------
  
  List<SkinState> _includeIn;
  
  List<SkinState> get includeIn => _includeIn;
  void set includeIn(List<SkinState> value) {
    if (value != _includeIn) {
      _includeIn = value;
      
      notify(
        new FrameworkEvent(
            'includeInChanged',
            relatedObject: value
        )
      );
    }
  }
  
  //---------------------------------
  // excludeFrom
  //---------------------------------
  
  List<SkinState> _excludeFrom;
  
  List<SkinState> get excludeFrom => _excludeFrom;
  void set excludeFrom(List<SkinState> value) {
    if (value != _excludeFrom) {
      _excludeFrom = value;
      
      notify(
        new FrameworkEvent(
            'excludeFromChanged',
            relatedObject: value
        )
      );
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

  List<String> _cssClasses = <String>[];
  bool _isCSSClassesChanged = false;

  List<String> get cssClasses => _cssClasses;

  set cssClasses(List<String> value) {
    if (value != _cssClasses) {
      bool hasDelta = true;
      
      if (value != null && _cssClasses != null && value.length == _cssClasses.length) {
        final int len = value.length;
        
        hasDelta = false;
        
        for (int i=0; i<len; i++) {
          if (value[i] != _cssClasses[i]) {
            hasDelta = true;
            
            break;
          }
        }
      }
      
      if (hasDelta) {
        _cssClasses = value;
  
        notify(
          new FrameworkEvent('cssClassesChanged')
        );
  
        refreshStyle();
      }
    }
  }
  
  void refreshStyle() {
    _isCSSClassesChanged = true;

    invalidateProperties();
  }

  //---------------------------------
  // visible
  //---------------------------------
  
  bool _visible = true;

  bool get visible => _visible;

  set visible(bool value) {
    if (value != _visible) {
      _visible = value;

      notify(
        new FrameworkEvent('visibleChanged')
      );

      invokeLaterSingle('updateVisibility', updateVisibility);
    }
  }
  
  //---------------------------------
  // inheritsDefaultCSS
  //---------------------------------

  bool _inheritsDefaultCSS = true;

  bool get inheritsDefaultCSS => _inheritsDefaultCSS;
  set inheritsDefaultCSS(bool value) {
    if (value != _inheritsDefaultCSS) {
      _inheritsDefaultCSS = value;
      
      if (_isInitialized) invokeLaterSingle('updateDefaultClass', _updateDefaultClass);

      notify(
        new FrameworkEvent('inheritsDefaultCSSChanged')
      );
    }
  }

  //---------------------------------
  // addLaterElements
  //---------------------------------

  List<BaseComponent> _addLaterElements = <BaseComponent>[];

  //---------------------------------
  // isInitialized
  //---------------------------------

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //---------------------------------
  // owner
  //---------------------------------

  BaseComponent _owner;

  BaseComponent get owner => _owner;

  //---------------------------------
  // childWrappers
  //---------------------------------

  List<BaseComponent> _childWrappers = <BaseComponent>[];

  List<BaseComponent> get childWrappers => _childWrappers;

  //---------------------------------
  // elementId
  //---------------------------------

  String _elementId;

  String get elementId => _elementId;
  
  //---------------------------------
  // className
  //---------------------------------

  String _className = 'UIWrapper';

  String get className => _className;
  set className(String value) {
    if (value != _className) {
      _className = value;
      
      if (_isInitialized) invokeLaterSingle('updateDefaultClass', _updateDefaultClass);

      notify(
        new FrameworkEvent('classNameChanged')
      );
    }
  }

  //---------------------------------
  // control
  //---------------------------------

  Element _control;

  Element get control => _control;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Component({String elementId: null}) {
    _eventDispatcher = new EventDispatcherImpl(dispatcher: this);

    _elementId = elementId;

    _wrapDOMTarget();
  }

  //---------------------------------
  //
  // Operator overloads
  //
  //---------------------------------

  void operator []=(String type, Function eventHandler) => observeEventType(type, eventHandler);
  
  @override
  noSuchMethod(Invocation invocation) => null;

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void wrapTarget(Element target) => _wrapDOMTarget(target: target);
  
  void preInitialize(BaseComponent forOwner) {
    _owner = forOwner;
    
    notify(
        new FrameworkEvent<BaseComponent>(
            'ownerChanged',
            relatedObject: forOwner
        )
    );
    
    initialize();
  }
  
  void invalidateLayout() {
    _isLayoutUpdateRequired = _allowLayoutUpdate;

    invokeLaterSingle('commitProperties', commitProperties);
  }

  void invalidateProperties() {
    if (!_isInitialized) return;
    
    if (!_isLayoutUpdateRequired) invalidateLayout();
  }
  
  void invalidateSize(Event event) => invokeLaterSingle('updateSize', updateSize);

  void onComponentAdded() => _childWrappers.forEach((BaseComponent child) => child.onComponentAdded());
  
  void initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      
      createChildren();
      
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
  
  void updateAfterSkinStateChanged(BaseComponent recursiveChildWrapper) {
    if (_currentSkinStates == null || recursiveChildWrapper.includeIn == null) return;
    
    int lenA, i;
    SkinState sA;
    
    if (recursiveChildWrapper.includeIn != null) {
      lenA = recursiveChildWrapper.includeIn.length;
      
      for (i=0; i<lenA; i++) {
        sA = recursiveChildWrapper.includeIn[i];
        
        if (_currentSkinStates.contains(sA)) {
          recursiveChildWrapper.visible = recursiveChildWrapper.includeInLayout = recursiveChildWrapper.allowLayoutUpdate = true;
          
          return;
        }
      }
      
      if (recursiveChildWrapper.excludeFrom != null) {
        lenA = recursiveChildWrapper.excludeFrom.length;
        
        for (i=0; i<lenA; i++) {
          sA = recursiveChildWrapper.excludeFrom[i];
          
          if (_currentSkinStates.contains(sA)) {
            recursiveChildWrapper.visible = recursiveChildWrapper.includeInLayout = recursiveChildWrapper.allowLayoutUpdate = false;
            
            return;
          }
        }
      }
    }
    
    recursiveChildWrapper.visible = recursiveChildWrapper.includeInLayout = recursiveChildWrapper.allowLayoutUpdate = (recursiveChildWrapper.includeIn == null);
  }
  
  void commitProperties() {
    if (_isCSSClassesChanged) {
      _isCSSClassesChanged = false;
      
      if (_control != null) _updateDefaultClass();
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
  
  void registerSkinState(SkinState state) {
    _skinStates.add(state);
  }

  void addComponent(BaseComponent element, {bool prepend: false}) {
    if (_childWrappers.indexOf(element) >= 0) return;
    
    final Component elementCast = element as Component;
    
    elementCast._useMatrixTransformations = _useMatrixTransformations;

    if (_control == null) {
      prepend ? _addLaterElements.insert(0, element) : _addLaterElements.add(element);
    } else {
      if (elementCast._owner != this) {
        elementCast._owner = this;
        
        elementCast.notify(
            new FrameworkEvent<BaseComponent>(
                'ownerChanged',
                relatedObject: this
            )
        );
      }
      
      if (
          (_stylePrefix != null) &&
          (elementCast._stylePrefix == null)
      ) elementCast._stylePrefix = _stylePrefix;
      
      elementCast.initialize();
      
      if (element.control.id == null || element.control.id.length == 0) element.control.id = getNextGUID();
      
      if (_elementId != null) {
        prepend ? _prependControl(element.control) : _appendControl(element.control);
      } else {
        prepend ? 
          invokeLaterNonSingle('prependControl', _prependControl, arguments: [element.control]) :
          invokeLaterNonSingle('appendControl', _appendControl, arguments: [element.control]);
      }

      invalidateLayout();

      element.onComponentAdded();
      
      _childWrappers.add(element);
    }
  }

  void removeComponent(BaseComponent element, {bool flush: true}) {
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
    
    if (element is Component) element._owner = null;
    
    invalidateLayout();
  }

  void removeAll() {
    if (_disableRemoveComponents) return;
    
    int i = _childWrappers.length;
    
    while (i > 0) removeComponent(_childWrappers[--i]);
    
    _childWrappers = <BaseComponent>[];
  }
  
  void flushHandler() => _streamSubscriptionManager.flushAll();
  
  void forceInvalidateSize() => invalidateSize(null);
  
  void updateLayout() {
    if ( 
      _allowLayoutUpdate &&
      (_width > 0) &&
      (_height > 0)
    ) {
      if (_layout != null) {
        final int dw = _layout.layoutWidth;
        final int dh = _layout.layoutHeight;
        
        _layout.doLayout(
            _width,
            _height,
            _getPageItemSize(),
            _getPageOffset(),
            _getPageSize(),
            _childWrappers
        );
        
        if (_layout.layoutWidth != dw) notify(
          new FrameworkEvent('layoutWidthChanged')    
        );
        
        if (_layout.layoutHeight != dh) notify(
          new FrameworkEvent('layoutHeightChanged')    
        );
        
        if ((_layout.layoutWidth != dw || _layout.layoutHeight != dh) && owner != null) owner.invalidateLayout();
      } else _childWrappers.forEach(
          (ComponentLayout element) {
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
          reflowManager.invocationFrame.whenComplete(updateSize);
          
          return;
        }
          
        parentElement = parentElement.parent;
      }
      
      final Rectangle rect = _control.parent.client;
      
      if (
          (rect.width == 0) && 
          (rect.height == 0)
      ) reflowManager.invocationFrame.whenComplete(updateSize);
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
      
      _reflowManager.invalidateCSS(_control, 'visibility', (_visible ? 'visible' : 'hidden'));
    }
  }
  
  void updateEnabledStatus() {
    if (_control != null && _enabled != null) reflowManager.invalidateCSS(_control, 'pointer-events', (_enabled ? 'auto' : 'none'));
  }
  
  void transportComponents(BaseComponent target) {
    if (_childWrappers != null) {
      final List<BaseComponent> list = <BaseComponent>[];
      BaseComponent element;
      int i = _childWrappers.length;
      
      _disableRemoveComponents = false;
      
      while (i > 0) {
        element = _childWrappers[--i];
        
        removeComponent(element, flush: false);
        
        list.insert(0, element);
      }
      
      list.forEach(
        (BaseComponent wrapper) => target.addComponent(wrapper) 
      );
    }
  }
  
  void invokeLaterSingle(String id, Function handler, {List arguments: const []}) {
    new MethodInvoker.delayedSingle(this, id, handler, arguments);
  }
  
  void invokeLaterNonSingle(String id, Function handler, {List arguments: const []}) {
    new MethodInvoker.delayedNonSingle(this, id, handler, arguments);
  }
  

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  Node _prependControl(Element controlToPrepend) => _appendControl(controlToPrepend);
  
  Node _appendControl(Element controlToAppend) {
    if (awaitLayoutBeforeRendering) _updateElementDisplay(controlToAppend);
    
    return _control.append(controlToAppend);
  }
  
  Future<bool> _updateElementDisplay(Element control) async {
    if (control.client.width == 0 || control.client.height == 0) {
      control.style.display = 'none';
      
      await _reflowManager.invocationFrame;
      
      await _updateElementDisplay(control);
      
      return false;
    } else control.style.display = 'block';
    
    return true;
  }

  void _setControl(Element element) {
    _control = element;
    
    if (_inheritsDefaultCSS) invokeLaterSingle('addDefaultClass', _addDefaultClass);
    
    if (_cssClasses != null) invokeLaterSingle('addAllPendingClasses', _addAllPendingClasses);

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
    if (_control == null) return;
    if (_className == null) {
      _control.classes.clear();
      
      return;
    }
    
    final List<String> newClasses = <String>[];
    final List<String> cssList = _className.split(' ');
    
    cssList.forEach(
      (String C) {
        if (_inheritsDefaultCSS) newClasses.add(C);
      }
    );
    
    if (_cssClasses != null) newClasses.addAll(_cssClasses);
    
    bool areListsUnequal = (newClasses.length != _control.classes.length);
    
    if (!areListsUnequal) for (int i=0, len=newClasses.length; i<len; i++) {
      if (_control.classes.firstWhere((String cc) => (cc == newClasses[i]), orElse: () => null) == null) {
        areListsUnequal = true;
        
        break;
      }
    };
    
    if (areListsUnequal) {
      _control.classes.clear();
      _control.classes.addAll(newClasses);
    }
  }
  
  void _addDefaultClass() => _control.classes.addAll(_className.split(' '));
  
  void _addAllPendingClasses() {
    if (_cssClasses != null && _cssClasses.isNotEmpty) _control.classes.addAll(_cssClasses);
  } 

  void _updateControl(int type) {
    if (
        (_control != null) &&  
        (_elementId == null)
    ) {
      final Function I = _reflowManager.invalidateCSS;
      
      if (_useMatrixTransformations) {
        switch (type) {
          case 1 : case 2 : I(_control, '${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)');  break;
          case 3 : I(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : I(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            _reflowManager.batchInvalidateCSS(
                _control,
                [
                  '${Device.cssPrefix}transform', 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, ${_x}, ${_y}, 0, 1)',
                  'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')),
                  'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))
                ]
            );
            
            break;
        }
      } else {
        switch (type) {
          case 1 : I(_control, 'left', (_x.toString() + 'px'));                                    break;
          case 2 : I(_control, 'top', (_y.toString() + 'px'));                                     break;
          case 3 : I(_control, 'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')));    break;
          case 4 : I(_control, 'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))); break;
          case 5 :
            _reflowManager.batchInvalidateCSS(
                _control,
                [
                  'left', (_x.toString() + 'px'),
                  'top', (_y.toString() + 'px'),
                  'width', ((_width == 0) ? 'auto' : (_width.toString() + 'px')),
                  'height', ((_height == 0) ? 'auto' : (_height.toString() + 'px'))
                ]
            );

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
      
      _streamSubscriptionManager.add('windowResize', window.onResize.listen(invalidateSize), flushExisting: true);
      
      notify(
          new FrameworkEvent<Element>(
              'controlChanged',
              relatedObject: target
          )
      );
      
      initialize();
      
      invokeLaterSingle('updateSize', updateSize);
    }
  }

  void _addAllPendingElements() {
    final List<BaseComponent> listClone = new List<BaseComponent>.from(_addLaterElements, growable:false);
    
    _addLaterElements = <BaseComponent>[];
    
    listClone.forEach(
        (BaseComponent element) => addComponent(element)
    );
  }
}