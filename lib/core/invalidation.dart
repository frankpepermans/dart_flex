part of dart_flex;

abstract class ILifeCycle {
  
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
  
  void preInitialize(IUIWrapper forOwner);
  void initialize();
  
  void createChildren();
  
}