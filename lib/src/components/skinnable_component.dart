part of dart_flex;

class SkinnableComponent extends Group {
  
  @event Stream<FrameworkEvent> onSkinPartAdded;
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SkinnableComponent() : super() {
    setSkinStates();
    
    onSkinPartAdded.listen(_event_partAdded);
  }
  
  void partAdded(BaseComponent part) {}
  
  void setSkinStates() {}
  
  void _event_partAdded(FrameworkEvent<BaseComponent> E) => partAdded(E.relatedObject);
}