part of dart_flex;

class SkinnableComponent extends Group {
  
  static const EventHook<FrameworkEvent<IUIWrapper>> onSkinPartAddedEvent = const EventHook<FrameworkEvent<IUIWrapper>>('skinPartAdded');
  Stream<FrameworkEvent<IUIWrapper>> get onSkinPartAdded => SkinnableComponent.onSkinPartAddedEvent.forTarget(this);
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SkinnableComponent() : super() {
    setSkinStates();
    
    onSkinPartAdded.listen(_event_partAdded);
  }
  
  void partAdded(IUIWrapper part) {}
  
  void setSkinStates() {}
  
  void _event_partAdded(FrameworkEvent<IUIWrapper> E) => partAdded(E.relatedObject);
}