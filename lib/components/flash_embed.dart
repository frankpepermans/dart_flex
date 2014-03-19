part of dart_flex;

class FlashEmbed extends UIWrapper {
  
  static final Random _RND = new Random(new DateTime.now().millisecondsSinceEpoch);
  
  String _currentId;
  Map<String, Function> _pendingCallbacks;
  
  final List<String> _callbacks = <String>[];

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // source
  //---------------------------------

  static const EventHook<FrameworkEvent> onSourceChangedEvent = const EventHook<FrameworkEvent>('sourceChanged');
  Stream<FrameworkEvent> get onSourceChanged => FlashEmbed.onSourceChangedEvent.forTarget(this);
  String _source;

  String get source => _source;
  set source(String value) {
    if (value != _source) {
      _source = value;

      notify(
          new FrameworkEvent('sourceChanged')
      );

      later > _commitSource;
    }
  }

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  ParamElement _movieParam;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  FlashEmbed({String elementId: null}) : super(elementId: elementId) {
    _currentId = _RND.nextInt(0xffffffff).toString();
    _className = 'FlashEmbed';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void initialize() {
    super.initialize();
    
    if (_pendingCallbacks != null) _pendingCallbacks.forEach(
      (String callbackMethod, Function callbackHandler) => addCallback(callbackMethod, callbackHandler)    
    );
  }
  
  @override
  void createChildren() {
    if (_control == null) {
      ObjectElement controlCast = new ObjectElement()
        ..type = 'application/x-shockwave-flash'
        ..name = '_iop_${_currentId}_embed'
        ..id = '_iop_${_currentId}_embed'
        ..append(
            new ParamElement()
              ..name = 'FlashVars'
              ..value = 'iop=$_currentId'
        )
        ..append(
            new ParamElement()
              ..name = 'quality'
              ..value = 'high'
        )
        ..append(
            new ParamElement()
              ..name = 'allowscriptaccess'
              ..value = 'always'
        )
        ..append(
            new ParamElement()
              ..name = 'wmode'
              ..value = 'opaque'
        );
      
      ScriptElement interopScript = new ScriptElement()
        ..type = 'text/javascript'
        ..innerHtml = _createScriptSource();

      _setControl(controlCast);
      
      document.head.append(interopScript);
      
      later > _commitSource;
    }

    super.createChildren();
  }
  
  void addCallback(String callbackMethod, void callbackHandler(String jsonData)) {
    if (_isInitialized) {
      if (!_callbacks.contains(callbackMethod)) {
        _callbacks.add(callbackMethod);
        
        _injectScript(callbackMethod);
              
        context['_iop_${_currentId}_$callbackMethod'] = (String value) => callbackHandler(value);
      }
    }
    else {
      if (_pendingCallbacks == null) _pendingCallbacks = <String, Function>{};
      
      _pendingCallbacks[callbackMethod] = callbackHandler;
    }
  }
  
  void send(String exposedFlashMethod, String value, {String callbackMethod, void callbackHandler(String jsonData)}) {
    final bool expectsCallback = ((callbackMethod != null) && (callbackHandler != null));
    
    if (expectsCallback) addCallback(
        callbackMethod,
        callbackHandler
    );
    
    try {
      context.callMethod('_iop_${_currentId}_writeExternal', [exposedFlashMethod, value]);
    } catch (error) {
      final Timer timer = new Timer(const Duration(seconds: 2), () => send(exposedFlashMethod, value));
    }
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _injectScript(String callbackMethod) {
    ScriptElement interopScript = new ScriptElement()
      ..type = 'text/javascript'
      ..innerHtml = '_iop_${_currentId}_$callbackMethod = function(value) { return value; }';
      
    document.head.append(interopScript);
  }
  
  String _createScriptSource() {
    return '_iop_${_currentId}_writeExternal = function(methodName, value) { document.getElementById("_iop_${_currentId}_embed")[methodName](value); }';
  }

  void _commitSource() {
    super.commitProperties();
    
    if (_control != null) {
      ObjectElement controlCast = _control as ObjectElement;
    
      if (_source != null) {
        if (_movieParam == null) {
          _movieParam = new ParamElement()..name = 'movie';
          
          controlCast.append(_movieParam);
        }
        
        _movieParam.value = _source;
      }
    }
  }
}

