part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  static final ReflowManager _instance = new ReflowManager._construct();
  
  final Map<dynamic, List<_MethodInvokationMap>> _scheduledHandlers = new Map<dynamic, List<_MethodInvokationMap>>();
  final Map<Element, _ElementCSSMap> _elements = <Element, _ElementCSSMap>{};
  final Map<Element, CssStyleDeclaration> _cssStyles = <Element, CssStyleDeclaration>{};
  
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
  
  Future get invocationFrame {
    if (_invocationFrameCompleter != null) return _invocationFrameCompleter.future;
    
    _invocationFrameCompleter = new Completer();
    
    new Timer(
      new Duration(milliseconds: (_currentPeformance < 40.0) ? 40 : (_currentPeformance > 120.0) ? 120 : _currentPeformance.toInt()),
      _invocationFrameCompleter.complete
    );
    
    final Future result = _invocationFrameCompleter.future;
    
    result.whenComplete(() => _invocationFrameCompleter = null);
    
    return result;
  }
  
  //---------------------------------
  // animationFrame
  //---------------------------------
  
  Completer _animationFrameCompleter;
  
  Future get animationFrame {
    if (_animationFrameCompleter != null) return _animationFrameCompleter.future;
    
    _animationFrameCompleter = new Completer();
    
    final double perf = getPerformanceNow();
    
    window.requestAnimationFrame(
        (_) {
          _currentPeformance = perf - getPerformanceNow();
          
          _animationFrameCompleter.complete();
        }
    );
    
    final Future result = _animationFrameCompleter.future;
    
    result.whenComplete(() => _animationFrameCompleter = null);
    
    return result;
  }
  
  //---------------------------------
  // layoutFrame
  //---------------------------------
  
  Completer _layoutFrameCompleter;
  
  Future get layoutFrame {
    if (_layoutFrameCompleter != null) return _layoutFrameCompleter.future;
    
    _layoutFrameCompleter = new Completer();
    
    Future.wait(
        <Future>[
            invocationFrame,
            animationFrame
        ]
    ).whenComplete(_layoutFrameCompleter.complete);
    
    final Future result = _layoutFrameCompleter.future;
    
    result.whenComplete(() => _layoutFrameCompleter = null);
    
    return result;
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  //---------------------------------
  // Singleton
  //---------------------------------

  ReflowManager._construct();

  factory ReflowManager() => _instance;

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
    return .0;
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
      
      animationFrame.then(
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
  final List<String> _dirtyProperties = <String>[];
  final List<String> _dirtyValues = <String>[];
  
  CssStyleDeclaration _detachedElement;
  
  _ElementCSSMap(this._element) {
    final CssStyleDeclaration matchCSS = ReflowManager._instance._cssStyles[_element];
    
    if (matchCSS == null) _detachedElement = ReflowManager._instance._cssStyles[_element] = new CssStyleDeclaration()..cssText = _element.style.cssText;
    else _detachedElement = matchCSS..cssText = _element.style.cssText;
  }
  
  void finalize() {
    if (_element.style.cssText != _detachedElement.cssText) {
      int i = _dirtyProperties.length;
      String propertyName, leftValue, rightValue;
      String oldDisplayStyle = _element.style.display;
      
      while (i > 0) {
        propertyName = _dirtyProperties[--i];
        
        leftValue = _element.style.getPropertyValue(propertyName);
        rightValue = _dirtyValues[i];
        
        if (leftValue != rightValue) _element.style.setProperty(propertyName, rightValue, _PRIORITY);
      }
    }
  }
  
  void setProperty(String propertyName, String value) {
    int index = _dirtyProperties.indexOf(propertyName);
    
    if (index == -1) {
      _dirtyProperties.add(propertyName);
      _dirtyValues.add(value);
    } else _dirtyValues[index] = value;
    
    _detachedElement.setProperty(propertyName, value, _PRIORITY);
  }
}