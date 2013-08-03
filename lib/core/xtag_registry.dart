part of dartflex;

class XTagRegistry extends FrameworkEventDispatcher {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  static XTagRegistry _instance;
  
  List<XTagMap> _xTagMaps = new List<XTagMap>();
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onPartAddedEvent = const EventHook<FrameworkEvent>('partAdded');
  Stream<FrameworkEvent> get onPartAdded => XTagRegistry.onPartAddedEvent.forTarget(this);

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  //---------------------------------
  // Singleton
  //---------------------------------

  XTagRegistry._construct();

  factory XTagRegistry() {
    if (_instance == null) {
      _instance = new XTagRegistry._construct();
    }

    return _instance;
  }

  //-----------------------------------
  //
  // Public methods
  //
  //-----------------------------------
  
  void registerXTag(IUIWrapper element, String id) {
    XTagMap xTagMap;
    int i = _xTagMaps.length;
    
    while (i > 0) {
      xTagMap = _xTagMaps[--i];
      
      if (xTagMap.xtagId == id) {
        return;
      }
    }
    
    xTagMap = new XTagMap();
    
    xTagMap.xtagElement = element;
    xTagMap.xtagId = id;
    
    _xTagMaps.add(xTagMap);
    
    notify(
      new FrameworkEvent('partAdded', relatedObject: xTagMap)    
    );
  }
  
  String getXTagId(IUIWrapper element) {
    XTagMap xTagMap;
    int i = _xTagMaps.length;
    
    while (i > 0) {
      xTagMap = _xTagMaps[--i];
      
      if (xTagMap.xtagElement == element) {
        return xTagMap.xtagId;
      }
    }
    
    return null;
  }
  
  IUIWrapper getXTag(String id) {
    XTagMap xTagMap;
    int i = _xTagMaps.length;
    
    while (i > 0) {
      xTagMap = _xTagMaps[--i];
      
      if (xTagMap.xtagId == id) {
        return xTagMap.xtagElement;
      }
    }
    
    return null;
  }
}

class XTagMap {

  IUIWrapper xtagElement;
  String xtagId;

}
