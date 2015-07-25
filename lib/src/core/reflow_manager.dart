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
    } else {
      if (invoker.arguments.isNotEmpty) {
        print(this);
      }
      existingInvoker.arguments = invoker.arguments;
    }
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
  
  Future _currentWait;
  Map<String, String> _dirtyProperties;
  bool _isDirty = false;
  
  _ElementCSSMap(this._element);
  
  void asyncUpdateCss(Future F, String propertyName, String value) {
    if (F != _currentWait) _currentWait = F..whenComplete(_finalize);
    
    if (_element.style.getPropertyValue(propertyName) != value) {
      if (_dirtyProperties == null) _dirtyProperties = <String, String>{};
      
      _isDirty = true;
      _dirtyProperties[propertyName] = value;
    }
  }
  
  void _finalize() {
    if (!_isDirty) return;
    
    _dirtyProperties.forEach(
      (String N, String V) => _element.style.setProperty(N, V, _PRIORITY)
    );
    
    _isDirty = false;
    _dirtyProperties = null;
  }
  
  String toString() => '$_element $_dirtyProperties';
}