part of dart_flex;

class ReflowManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  final FrameManager F = new FrameManager()..fps = 60;
  
  final Map<dynamic, Map<String, MethodInvoker>> _scheduledHandlers = new Map<dynamic, Map<String, MethodInvoker>>.identity();
  final Map<Element, _ElementCSSMap> _elements = new Map<Element, _ElementCSSMap>.identity();
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // invocationFrame
  //---------------------------------
  
  Future<Frame> _animationFrameFuture;
  StreamSubscription _nextFrameListener;
  
  Future<Frame> get invocationFrame {
    if (_animationFrameFuture != null) return _animationFrameFuture;
    
    final Completer<Frame> animationFrameCompleter = new Completer<Frame>.sync();
    
    _animationFrameFuture = animationFrameCompleter.future;
    
    _nextFrameListener = F.S.listen(
      (Frame f) {
        if (f is EnterFrame) {
          _animationFrameFuture = null;
          _nextFrameListener.cancel();
      
          animationFrameCompleter.complete(f);
        }
      }
    );
    
    return _animationFrameFuture;
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
  
  void scheduleMethod(MethodInvoker invoker, {bool forceSingleExecution: false}) {
    Map<String, MethodInvoker> ownerMap = _scheduledHandlers[invoker.owner];
    MethodInvoker existingInvoker;
    
    if (ownerMap == null) ownerMap = _scheduledHandlers[invoker.owner] = <String, MethodInvoker>{};
    
    if (forceSingleExecution) existingInvoker = ownerMap[invoker.id];
    
    if (existingInvoker == null) {
      if (forceSingleExecution) ownerMap[invoker.id] = invoker;
      
      invocationFrame.whenComplete(
        () {
          ownerMap[invoker.id] = null;
          
          invoker.invoke();
        }
      );
    } else existingInvoker.arguments = invoker.arguments;
  }

  void invalidateCSS(Element element, String property, String value) {
    if (element == null) return;
    
    _ElementCSSMap elementCSSMap = _elements[element];

    if (elementCSSMap == null) _elements[element] = elementCSSMap = new _ElementCSSMap(element);
    
    elementCSSMap.asyncUpdateCss(invocationFrame, property, value);
  }
  
  void batchInvalidateCSS(Element element, List<dynamic> list) {
    final int len = list.length;
    int i;
    
    _ElementCSSMap elementCSSMap = _elements[element];

    if (elementCSSMap == null) _elements[element] = elementCSSMap = new _ElementCSSMap(element);
    
    for (i=0; i<len; elementCSSMap.asyncUpdateCss(invocationFrame, list[i], list[i+1]), i+=2);
  }
}

class _ElementCSSMap {

  static const String _PRIORITY = '';
  
  final Element _element;
  final CssStyleDeclaration _decl = new CssStyleDeclaration();
  
  Future _currentWait;
  int _pending = 0;
  int _completed = 0;
  
  _ElementCSSMap(this._element) {
    _decl.cssText = _element.style.cssText;
  }
  
  void asyncUpdateCss(Future<Frame> F, String propertyName, String value) {
    if (_element.style.getPropertyValue(propertyName) != value) {
      if (F != _currentWait) {
        _pending++;
        
        _currentWait = F..then(_finalize);
      }
          
      _decl.setProperty(propertyName, value, _PRIORITY);
    }
  }
  
  void _finalize(Frame F) {
    if (++_completed == _pending) {
      _pending = _completed = 0;
      _currentWait = null;
      
      _element.style.cssText = _decl.cssText;
    }
  }
}