part of dart_flex_test;

// workaround to support ChangeNotifier mixin on the main component
class BaseClass extends VGroup {
  
  BaseClass() : super() {}
  
}

class UIMLBinding extends BaseClass {
  
  @Skin('dart_flex|test/src/views/uiml_binding.xml')
  UIMLBinding() : super();
}