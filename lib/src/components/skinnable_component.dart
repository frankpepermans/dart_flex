part of dart_flex;

class SkinnableComponent extends UIWrapper {
  
  static const EventHook<FrameworkEvent<IUIWrapper>> onSkinPartAddedEvent = const EventHook<FrameworkEvent<IUIWrapper>>('skinPartAdded');
  Stream<FrameworkEvent<IUIWrapper>> get onSkinPartAdded => SkinnableComponent.onSkinPartAddedEvent.forTarget(this);
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SkinnableComponent() : super() {
    setSkinStates();
    
    onSkinPartAdded.listen(
      (FrameworkEvent<IUIWrapper> E) => partAdded(E.relatedObject)    
    );
  }
  
  void partAdded(IUIWrapper part) {}
  
  void setSkinStates() {}
}