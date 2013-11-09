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
      new Duration(milliseconds: 1),
      _invocationFrameCompleter.complete
    );
    
    Future result = _invocationFrameCompleter.future;
    
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
    
    window.requestAnimationFrame(
        (_) => _animationFrameCompleter.complete()
    );
    
    Future result = _animationFrameCompleter.future;
    
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
    
    Future result = _layoutFrameCompleter.future;
    
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
      ..detachedCCSText = element.style.cssText
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

}

class _ElementCSSMap {

  static const String _PRIORITY = '';
  
  final Element _element;
  final HtmlHtmlElement _detachedElement = new HtmlHtmlElement();
  
  bool get isDirty => (_element.style.cssText != _detachedElement.style.cssText);
  
  String get detachedCCSText => _detachedElement.style.cssText;
  void set detachedCCSText(String value) {
    _detachedElement.style.cssText = value;
  }
  
  String get elementCCSText => _element.style.cssText;
  void set elementCCSText(String value) {
    _element.style.cssText = value;
  }
  
  _ElementCSSMap(this._element);
  
  void finalize() {
    if (_element.style.cssText != _detachedElement.style.cssText) _element.style.cssText = _detachedElement.style.cssText;
  }
  
  void setProperty(String propertyName, String value) => _detachedElement.style.setProperty(propertyName, value, _PRIORITY);

}
