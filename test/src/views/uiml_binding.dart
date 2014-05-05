part of dart_flex_test;

class UIMLBinding extends VGroup {
  
  EditableText text01, text02;
  
  @Skin('dart_flex|test/src/views/uiml_binding.xml')
  UIMLBinding({String elementId: null}) : super(elementId: elementId) {}
  
}