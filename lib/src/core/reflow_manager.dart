part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  final Map<dynamic, List<_MethodInvokationMap>> _scheduledHandlers = new Map<dynamic, List<_MethodInvokationMap>>();
  final Map<Element, _ElementCSSMap> _elements = <Element, _ElementCSSMap>{};
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // invocationFrame
  //---------------------------------
  
  Future _invocationFuture;
  
  Future get invocationFrame {
    if (_invocationFuture != null) return _invocationFuture;
    // 60fps => 1000 / 60 = 16
    _invocationFuture = new Future.delayed(const Duration(milliseconds: 16))
      ..whenComplete(
        () => _invocationFuture = null 
      );
    
    return _invocationFuture;
  }
  
  //---------------------------------
  // animationFrame
  //---------------------------------
  
  Future _animationFrameFuture;
  
  Future get animationFrame {
    if (_animationFrameFuture != null) return _animationFrameFuture;
    
    final Completer animationFrameCompleter = new Completer.sync();
    
    _animationFrameFuture = animationFrameCompleter.future;
    
    window.requestAnimationFrame(
        (_) {
          _animationFrameFuture = null;
      
          animationFrameCompleter.complete();
        }
    );
    
    return _animationFrameFuture;
  }
  
  //---------------------------------
  // layoutFrame
  //---------------------------------
  
  Future _layoutFuture;
  
  Future get layoutFrame {
    if (_layoutFuture != null) return _layoutFuture;
    
    _layoutFuture = Future.wait(
        <Future>[
            invocationFrame,
            animationFrame
        ]
    ).whenComplete(_resetLayoutFuture);
    
    return _layoutFuture;
  }
  void _resetLayoutFuture() => _layoutFuture = null;
  
  //---------------------------------
  //
  // Singleton Constructor
  //
  //---------------------------------
  
  ReflowManager._internal();

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  static final ReflowManager _reflowManager = new ReflowManager._internal();

  factory ReflowManager() => _reflowManager;

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------
  
  void scheduleMethod(dynamic owner, Function method, List arguments, {bool forceSingleExecution: false}) {
    List<_MethodInvokationMap> ownerMap = _scheduledHandlers[owner];
    
    if (ownerMap == null) ownerMap = _scheduledHandlers[owner] = <_MethodInvokationMap>[];
    
    _MethodInvokationMap invocation;
    
    if (forceSingleExecution) invocation = ownerMap.firstWhere(
        (_MethodInvokationMap I) => FunctionEqualityUtil.equals(I._method, method),
        orElse: () => null
    );
    
    if (invocation == null) {
      invocation = new _MethodInvokationMap(owner, method)
        .._arguments = arguments;

      ownerMap.add(invocation);
      
      invocationFrame.then(
          (_) {
            if (ownerMap.remove(invocation) && (ownerMap.length == 0)) _scheduledHandlers.remove(owner);
            
            invocation.invoke();
          }
      );
    } else invocation._arguments = arguments;
  }

  void invalidateCSS(Element element, String property, String value) {
    if (element == null) return;
    
    _ElementCSSMap elementCSSMap = _elements[element];

    if (elementCSSMap == null) _elements[element] = elementCSSMap = new _ElementCSSMap(element);
    
    elementCSSMap.asyncUpdateCss(layoutFrame, property, value);
  }
  
  void batchInvalidateCSS(Element element, List<dynamic> list) {
    final int len = list.length;
    int i;
    
    _ElementCSSMap elementCSSMap = _elements[element];

    if (elementCSSMap == null) _elements[element] = elementCSSMap = new _ElementCSSMap(element);
    
    for (i=0; i<len; i+=2) elementCSSMap.asyncUpdateCss(layoutFrame, list[i], list[i+1]);
  }
}

class _MethodInvokationMap {

  final dynamic _owner;
  final Function _method;
  
  List _arguments;
  
  _MethodInvokationMap(this._owner, this._method);
  
  dynamic invoke() => Function.apply(_method, _arguments);

  String toString() => '$_owner $_method $_arguments';
}

class _ElementCSSMap {

  static const String _PRIORITY = '';
  
  final Element _element;
  
  Future _currentWait;
  Map<String, String> _dirtyProperties;
  bool _isDirty = false;
  
  _ElementCSSMap(this._element);
  
  void asyncUpdateCss(Future await, String propertyName, String value) {
    if (await != _currentWait) _currentWait = await..then(_finalize);
    
    if (_element.style.getPropertyValue(propertyName) != value) {
      if (_dirtyProperties == null) _dirtyProperties = <String, String>{};
      
      _isDirty = true;
      _dirtyProperties[propertyName] = value;
    }
  }
  
  void _finalize(_) {
    if (!_isDirty) return;
    
    _dirtyProperties.forEach(
      (String N, String V) => _element.style.setProperty(N, V, _PRIORITY)
    );
    
    _isDirty = false;
    _dirtyProperties = null;
  }
  
  String toString() => '$_element $_dirtyProperties';
}