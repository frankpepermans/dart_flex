part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  final Map<dynamic, List<_MethodInvokationMap>> _scheduledHandlers = new Map<dynamic, List<_MethodInvokationMap>>();
  final Map<Element, _ElementCSSMap> _elements = <Element, _ElementCSSMap>{};
  
  double _currentPeformance = .0;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // invocationFrame
  //---------------------------------
  
  Completer _invocationFrameCompleter;
  Timer _invocationTimer;
  Future _invocationFuture;
  
  Future get invocationFrame {
    if (_invocationTimer == null || !_invocationTimer.isActive) {
      _invocationFrameCompleter = new Completer();
      
      _invocationTimer = new Timer(
        new Duration(milliseconds: (_currentPeformance > 120.0) ? 120 : _currentPeformance.ceil()),
        _invocationFrameCompleter.complete
      );
      
      _invocationFuture = _invocationFrameCompleter.future;
    }
    
    return _invocationFuture;
  }
  
  //---------------------------------
  // animationFrame
  //---------------------------------
  
  Completer _animationFrameCompleter;
  Future _animationFrameFuture;
  
  Future get animationFrame {
    if (_animationFrameCompleter != null) return _animationFrameFuture;
    
    _animationFrameCompleter = new Completer();
    
    final double perf = getPerformanceNow();
    
    window.requestAnimationFrame(
        (_) {
          _currentPeformance = getPerformanceNow() - perf;
          
          _animationFrameCompleter.complete();
          
          _animationFrameCompleter = null;
        }
    );
    
    _animationFrameFuture = _animationFrameCompleter.future;
    
    return _animationFrameFuture;
  }
  
  //---------------------------------
  // layoutFrame
  //---------------------------------
  
  Completer _layoutFrameCompleter;
  Future _layoutFuture;
  
  Future get layoutFrame {
    if (_layoutFrameCompleter != null) return _layoutFuture;
    
    _layoutFrameCompleter = new Completer();
    
    Future.wait(
        <Future>[
            invocationFrame,
            animationFrame
        ]
    ).whenComplete(
      () {
        _layoutFrameCompleter.complete();
        
        _layoutFrameCompleter = null;
      }
    );
    
    _layoutFuture = _layoutFrameCompleter.future;
    
    return _layoutFuture;
  }
  
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
  
  double getPerformanceNow() {
    if (
      (window.performance != null) &&
      (window.performance.now != null)
    ) return window.performance.now();
    return 10.0;
  }
  
  void scheduleMethod(dynamic owner, Function method, List arguments, {bool forceSingleExecution: false}) {
    List<_MethodInvokationMap> ownerMap = _scheduledHandlers[owner];
    
    if (ownerMap == null) ownerMap = _scheduledHandlers[owner] = <_MethodInvokationMap>[];
    
    _MethodInvokationMap invokation;
    
    if (forceSingleExecution) invokation = ownerMap.firstWhere(
        (_MethodInvokationMap tmpInvokation) => FunctionEqualityUtil.equals(tmpInvokation._method, method),
        orElse: () => null
    );
    
    if (invokation == null) {
      invokation = new _MethodInvokationMap(owner, method)
        .._arguments = arguments;

      ownerMap.add(invokation);
      
      invocationFrame.then(
          (_) {
            ownerMap.remove(invokation);
            
            if (ownerMap.length == 0) _scheduledHandlers.remove(owner);
            
            invokation.invoke();
          }
      );
    } else invokation._arguments = arguments;
  }

  void invalidateCSS(Element element, String property, String value) {
    if (element == null) return;
    
    _ElementCSSMap elementCSSMap = _elements[element];

    if (elementCSSMap == null) {
      elementCSSMap = new _ElementCSSMap(element)
      ..setProperty(property, value);

      _elements[element] = elementCSSMap;
      
      layoutFrame.then(
          (_) {
            _elements.remove(element);
            
            elementCSSMap.finalize();
          }
      );
    } else elementCSSMap.setProperty(property, value);
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
  
  Map<String, String> _dirtyProperties;
  
  _ElementCSSMap(this._element) {
    _dirtyProperties = <String, String>{};
  }
  
  void finalize() {
    _dirtyProperties.forEach(
      (String propertyName, String propertyValue) => _element.style.setProperty(propertyName, propertyValue, _PRIORITY)
    );
    
    _dirtyProperties = <String, String>{};
  }
  
  void setProperty(String propertyName, String value) {
    if (_element.style.getPropertyValue(propertyName) != value) _dirtyProperties[propertyName] = value;
  }
  
  String toString() => '$_element $_dirtyProperties';
}