part of dart_flex;

abstract class IFrameworkEventDispatcher {

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------

  bool hasObserver(String type);
  void observeEventType(String type, Function eventHandler);
  void ignoreEventType(String type, Function eventHandler);
  void notify(FrameworkEvent event);

}

class FrameworkEventDispatcher implements IFrameworkEventDispatcher {

  //-----------------------------------
  //
  // Private properties
  //
  //-----------------------------------

  IFrameworkEventDispatcher _dispatcher;

  Map<String, List<Function>> _observers = new Map();

  //-----------------------------------
  //
  // Constructor
  //
  //-----------------------------------

  FrameworkEventDispatcher({IFrameworkEventDispatcher dispatcher: null}) {
    if (dispatcher == null) {
      _dispatcher = this;
    } else {
      _dispatcher = dispatcher;
    }
  }

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------

  bool hasObserver(String type) {
    return (_observers[type] != null);
  }

  void observeEventType(String type, Function eventHandler) {
    List<Function> handlers;

    if (!hasObserver(type)) {
      _observers[type] = new List<Function>();
    }

    handlers = _observers[type];

    if (handlers.length > 0) {
      ignoreEventType(type, eventHandler);
    }

    handlers.add(eventHandler);
  }

  void ignoreEventType(String type, Function eventHandler) {
    int i;

    if (_observers.containsKey(type)) {
      List<Function> handlers = _observers[type];

      i = handlers.length;

      while (i > 0) {
        if (FunctionEqualityUtil.equals(handlers[--i], eventHandler)) {
          handlers.removeAt(i);

          break;
        }
      }

      if (handlers.length == 0) {
        //_observers.remove(type);
      }
    }
  }
  
  void ignoreAllEventTypes() {
    _observers = new Map<String, List<Function>>();
  }

  void notify(FrameworkEvent event) {
    if (_observers.containsKey(event.type)) {
      final List<Function> list = _observers[event.type];
      Function handler;
      int i = list.length;
      
      event.currentTarget = _dispatcher;
      
      while (i > 0) {
        handler = list[--i];
        
        handler(event);
      }
    }
  }
}