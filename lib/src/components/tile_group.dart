part of dart_flex;

class TileGroup extends Group {
  
  @event Stream<FrameworkEvent> onGapChanged;
  
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
  //
  // Constructor
  //
  //---------------------------------

  TileGroup({String elementId: null, int gap: 10}) : super(elementId: elementId) {
    _className = 'TileGroup';
  
    _layout = new TileLayout();

    _layout.gap = gap;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

}

