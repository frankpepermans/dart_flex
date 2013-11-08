part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  static final ReflowManager _instance = new ReflowManager._construct();
  
  final List<_MethodInvokationMap> _scheduledHandlers = <_MethodInvokationMap>[];
  final Map<Element, _ElementCSSMap> _elements = <Element, _ElementCSSMap>{};
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
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
    _MethodInvokationMap invokation;
    
    if (forceSingleExecution) invokation = _scheduledHandlers.firstWhere(
        (_MethodInvokationMap tmpInvokation) => (
            (tmpInvokation._owner == owner) &&
            FunctionEqualityUtil.equals(tmpInvokation._method, method)
        ),
        orElse: () => null
    );
    
    if (invokation == null) {
      invokation = new _MethodInvokationMap(owner, method)
        .._arguments = arguments;

      _scheduledHandlers.add(invokation);
      
      animationFrame.then(
          (_) => _scheduledHandlers.remove(invokation.invoke())
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
      
      animationFrame.then(
          (_) => _elements.remove(elementCSSMap.finalize())    
      );
    } else {
      elementCSSMap.setProperty(property, value);
    }
  }
}

class _MethodInvokationMap {

  final dynamic _owner;
  final Function _method;
  
  List _arguments;
  
  _MethodInvokationMap(this._owner, this._method);
  
  _MethodInvokationMap invoke() {
    Function.apply(_method, _arguments);
    
    return this;
  }

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
  
  Element finalize() {
    if (_element.style.cssText != _detachedElement.style.cssText) _element.style.cssText = _detachedElement.style.cssText;
    
    return _element;
  }
  
  void setProperty(String propertyName, String value) => _detachedElement.style.setProperty(propertyName, value, _PRIORITY);

}
