part of dart_flex;

class EventHook<T extends FrameworkEvent> {
  final String _eventType;

  const EventHook(this._eventType);

  Stream<T> forTarget(IFrameworkEventDispatcher e) => new _EventStream(e, _eventType);
  
  String getEventType(IFrameworkEventDispatcher target) => _eventType;
}

class _EventStream<T extends FrameworkEvent> extends Stream<T> {
  final IFrameworkEventDispatcher _target;
  final String _eventType;

  _EventStream(this._target, this._eventType);

  // DOM events are inherently multi-subscribers.
  Stream<T> asBroadcastStream(
    {
      void onListen(StreamSubscription<T> subscription),
      void onCancel(StreamSubscription<T> subscription)
    }
  ) => this;
  
  bool get isBroadcast => true;

  StreamSubscription<T> listen(
      void onData(T event),
      { 
        void onError(Error error),
        void onDone(),
        bool unsubscribeOnError,
        bool cancelOnError
      }
  ) {
    return new _EventStreamSubscription<T>(
        this._target, 
        this._eventType, 
        onData
    );
  }
}

class _EventStreamSubscription<T extends FrameworkEvent> extends StreamSubscription<T> {
  int _pauseCount = 0;
  IFrameworkEventDispatcher _target;
  final String _eventType;
  var _onData;

  _EventStreamSubscription(this._target, this._eventType, this._onData) {
    _tryResume();
  }

  Future cancel() {
    if (_canceled) throw new StateError("Subscription has been canceled.");

    _unlisten();
    // Clear out the target to indicate this is complete.
    _target = null;
    _onData = null;
    
    return null;
  }

  bool get _canceled => (_target == null);

  void onData(void handleData(T event)) {
    if (_canceled) throw new StateError("Subscription has been canceled.");
    // Remove current event listener.
    _unlisten();

    _onData = handleData;
    
    _tryResume();
  }

  /// Has no effect.
  void onError(void handleError(error)) {}

  /// Has no effect.
  void onDone(void handleDone()) {}

  void pause([Future resumeSignal]) {
    if (_canceled) throw new StateError("Subscription has been canceled.");
    
    ++_pauseCount;
    
    _unlisten();

    if (resumeSignal != null) resumeSignal.whenComplete(resume);
  }

  bool get _paused => _pauseCount > 0;
  bool get isPaused => _paused;

  void resume() {
    if (_canceled) throw new StateError("Subscription has been canceled.");
    
    if (!_paused) throw new StateError("Subscription is not paused.");
    
    --_pauseCount;
    
    _tryResume();
  }

  void _tryResume() {
    if (_onData != null && !_paused) _target.observeEventType(_eventType, _onData);
  }

  void _unlisten() {
    if (_onData != null) _target.ignoreEventType(_eventType, _onData);
  }
  
  Future asFuture([var futureValue]) {
    // We just need a future that will never succeed or fail.
    Completer completer = new Completer();
    
    return completer.future;
  }
}