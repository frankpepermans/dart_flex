part of dart_flex;

abstract class EventDispatcher {

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------

  bool hasObserver(String type);
  void observeEventType(String type, Function eventHandler);
  void ignoreEventType(String type, Function eventHandler);
  void notify(String eventType, [dynamic relatedObject]);

}

class EventDispatcherMixin implements EventDispatcher {
  
  EventDispatcherImpl _eventDispatcher;
  
  bool hasObserver(String type) => _eventDispatcher.hasObserver(type);

  void observeEventType(String type, Function eventHandler) => _eventDispatcher.observeEventType(type, eventHandler);

  void ignoreEventType(String type, Function eventHandler) => _eventDispatcher.ignoreEventType(type, eventHandler);

  void notify(String eventType, [dynamic relatedObject]) => _eventDispatcher.notify(eventType, relatedObject);
  
}

class EventDispatcherImpl implements EventDispatcher {

  //-----------------------------------
  //
  // Private properties
  //
  //-----------------------------------

  EventDispatcher _dispatcher;

  Map<String, List<Function>> _observers = <String, List<Function>>{};

  //-----------------------------------
  //
  // Constructor
  //
  //-----------------------------------

  EventDispatcherImpl({EventDispatcher dispatcher: null}) {
    if (dispatcher == null) _dispatcher = this;
    else _dispatcher = dispatcher;
  }

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------

  bool hasObserver(String type) => (_observers[type] != null);

  void observeEventType(String type, Function eventHandler) {
    if (!hasObserver(type)) _observers[type] = <Function>[];

    _observers[type].add(eventHandler);
  }

  void ignoreEventType(String type, Function eventHandler) {
    int i;

    if (_observers.containsKey(type)) {
      final List<Function> handlers = _observers[type];

      i = handlers.length;

      while (i > 0) {
        if (handlers[--i] == eventHandler) {
          handlers.removeAt(i);

          return;
        }
      }
    }
  }
  
  void ignoreAllEventTypes() {
    _observers = <String, List<Function>>{};
  }

  void notify(String eventType, [dynamic relatedObject]) {
    final List<Function> list = _observers[eventType];
    
    if (list != null && list.isNotEmpty) {
      final FrameworkEvent event = new FrameworkEvent(eventType, relatedObject: relatedObject);
      int i = list.length;
      
      event.currentTarget = _dispatcher;
      
      while (i > 0) list[--i](event);
    }
  }
}