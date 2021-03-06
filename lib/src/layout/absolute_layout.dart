part of dart_flex;

class AbsoluteLayout implements ILayout {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // useVirtualLayout
  //---------------------------------

  bool _useVirtualLayout = false;

  bool get useVirtualLayout => _useVirtualLayout;
  set useVirtualLayout(bool value) {
    if (value != _useVirtualLayout) _useVirtualLayout = value;
  }

  //---------------------------------
  // constrainToBounds
  //---------------------------------

  bool _constrainToBounds = true;

  bool get constrainToBounds => _constrainToBounds;
  set constrainToBounds(bool value) => _constrainToBounds = value;
  
  //---------------------------------
  // gap
  //---------------------------------

  int _gap = 0;

  int get gap => _gap;
  set gap(int value) => _gap = value;
  
  //---------------------------------
  // align
  //---------------------------------

  String _align = 'none';

  String get align => _align;
  set align(String value) => _align = value;
  
  //---------------------------------
  // layoutWidth
  //---------------------------------
  
  int _layoutWidth = 0;
  
  int get layoutWidth => _layoutWidth;
  
  //---------------------------------
  // layoutHeight
  //---------------------------------
  
  int _layoutHeight = 0;
  
  int get layoutHeight => _layoutHeight;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  AbsoluteLayout({bool constrainToBounds: true}) {
    _constrainToBounds = constrainToBounds;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

  void doLayout(int width, int height, int pageItemSize, int pageOffset, int pageSize, List<ComponentLayout> elements) {
    elements.forEach(
        (BaseComponent element) => element.reflowManager.invalidateCSS(element.control, 'position', 'absolute')
    );
  }

}



