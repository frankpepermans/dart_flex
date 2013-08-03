part of dartflex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  static ReflowManager _instance;
  
  List<MethodInvokationMap> _scheduledHandlers = new List<MethodInvokationMap>();
  List<ElementCSSMap> _elements = new List<ElementCSSMap>();

  final HtmlElement _detachedElement = new HtmlElement();
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // animationFrame
  //---------------------------------
  
  Completer _animationFrameCompleter;
  
  Future<num> get animationFrame {
    if (_animationFrameCompleter != null) {
      return _animationFrameCompleter.future;
    }
    
    _animationFrameCompleter = new Completer();
    
    /*window.requestAnimationFrame(
      (num highResTimer) => _animationFrameCompleter.complete(highResTimer)
    );*/
    
    window.setImmediate(
        () => _animationFrameCompleter.complete()
    );
    
    final Future<num> currentFuture = _animationFrameCompleter.future;
    
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

  factory ReflowManager() {
    if (_instance == null) {
      _instance = new ReflowManager._construct();
    }

    return _instance;
  }

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------
  
  void scheduleMethod(dynamic owner, Function method, List arguments, {bool forceSingleExecution: false}) {
    //Function.apply(method, arguments); return;
    
    MethodInvokationMap invokation;
    bool hasOccurance = false;
    int i = _scheduledHandlers.length;
    
    if (forceSingleExecution) {
      while (i > 0) {
        invokation = _scheduledHandlers[--i];

        if (
            (invokation.owner == owner) &&
            FunctionEqualityUtil.equals(invokation.method, method)
        ) {
          hasOccurance = true;

          break;
        }
      }
    }
    
    if (!hasOccurance) {
      invokation = new MethodInvokationMap()
      ..owner = owner
      ..method = method
      ..arguments = arguments;

      _scheduledHandlers.add(invokation);
      
      animationFrame.then(
          (num highResTimer) {
            _scheduledHandlers.remove(invokation);
            
            Function.apply(invokation.method, invokation.arguments);
          }
      );
    }
    
    invokation.arguments = arguments;
  }

  void invalidateCSS(Element element, String property, String value) {
    if (element == null) {
      return;
    }

    ElementCSSMap elementCSSMap;
    bool hasOccurance = false;
    int i = _elements.length;
    
    while (i > 0) {
      elementCSSMap = _elements[--i];

      if (elementCSSMap.element == element) {
        hasOccurance = true;

        break;
      }
    }

    if (!hasOccurance) {
      elementCSSMap = new ElementCSSMap()
      ..element = element
      ..cssDecl = new Map();

      _elements.add(elementCSSMap);
      
      animationFrame.whenComplete(
          () {
            final String cssCache = elementCSSMap.element.style.cssText;
            
            _elements.remove(elementCSSMap);
            
            _detachedElement.style.cssText = cssCache;

            elementCSSMap.cssDecl.forEach(
                (String propertyName, String value) => _detachedElement.style.setProperty(propertyName, value, '')
            );
            
            if (cssCache != _detachedElement.style.cssText) {
              elementCSSMap.element.style.cssText = _detachedElement.style.cssText;
            }
          }    
      );
    }

    elementCSSMap.cssDecl[property] = value;
  }
}

class MethodInvokationMap {

  dynamic owner;
  Function method;
  List arguments;

}

class ElementCSSMap {

  Element element;
  Map cssDecl;

}
