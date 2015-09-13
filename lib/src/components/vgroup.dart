part of dart_flex;

class VGroup extends Group {
  
  @event Stream<FrameworkEvent> onGapChanged;
  @event Stream<FrameworkEvent> onAlignChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // gap
  //---------------------------------

  int get gap => _layout.gap;
  
  set gap(int value) {
    if (value != _layout.gap) {
      _layout.gap = value;

      notify('gapChanged');
    }
  }
  
  //---------------------------------
  // align
  //---------------------------------

  String get align => _layout.align;
  
  set align(String value) {
    if (value != _layout.align) {
      _layout.align = value;

      notify('alignChanged');
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  VGroup({String elementId: null, int gap: 10}) : super(elementId: elementId) {
  	_className = 'VGroup';
	
    _layout = new VerticalLayout();

    _layout.gap = gap;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

}

