part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  static final ReflowManager _instance = new ReflowManager._construct();
  
  final List<_MethodInvokationMap> _scheduledHandlers = new List<_MethodInvokationMap>();
  final List<_ElementCSSMap> _elements = new List<_ElementCSSMap>();
  
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
    
    /*Timer timer = new Timer(
      const Duration(milliseconds: 30),
      () => _animationFrameCompleter.complete()
    );*/
    
    final Future currentFuture = _animationFrameCompleter.future;
    
    currentFuture.whenComplete(
        () => _animationFrameCompleter = null 
    );

    return currentFuture;
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
          (_) {
            _scheduledHandlers.remove(invokation);
            
            Function.apply(invokation._method, invokation._arguments);
          }
      );
    } else invokation._arguments = arguments;
  }

  void invalidateCSS(Element element, String property, String value) {
    if (element == null) return;

    bool hasOccurance = true;
    
    _ElementCSSMap elementCSSMap = _elements.firstWhere(
      (_ElementCSSMap tmpElementCSSMap) => (tmpElementCSSMap._element == element),
      orElse: () {
        hasOccurance = false;
        
        return null;
      }
    );

    if (!hasOccurance) {
      elementCSSMap = new _ElementCSSMap(element)
      .._detachedElement.style.cssText = element.style.cssText
      .._detachedElement.style.setProperty(property, value, '');

      _elements.add(elementCSSMap);
      
      animationFrame.then(
          (_) {
            _elements.remove(elementCSSMap);
            
            if (elementCSSMap._element.style.cssText != elementCSSMap._detachedElement.style.cssText) elementCSSMap._element.style.cssText = elementCSSMap._detachedElement.style.cssText;
          }    
      );
    } else {
      elementCSSMap._detachedElement.style.setProperty(property, value, '');
    }
  }
}

class _MethodInvokationMap {

  final dynamic _owner;
  final Function _method;
  
  List _arguments;
  
  _MethodInvokationMap(this._owner, this._method);

}

class _ElementCSSMap {

  final Element _element;
  final HtmlElement _detachedElement = new HtmlElement();
  
  _ElementCSSMap(this._element);

}
