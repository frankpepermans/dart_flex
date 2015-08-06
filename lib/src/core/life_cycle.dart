part of dart_flex;

abstract class ComponentLifeCycle {
  
  bool get isInitialized;
  
  void invalidateLayout();
  void invalidateProperties();
  void invalidateOwnerProperties();
  void invalidateSize(Event event);
  void forceInvalidateSize();
  
  void commitProperties();
  
  void updateLayout();
  void updateSize();
  void updateVisibility();
  void updateEnabledStatus();
  
  void preInitialize(BaseComponent forOwner);
  void initialize();
  
  void createChildren();
  
}