part of dartflex;

class VGroup extends Group {
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // gap
  //---------------------------------

  static const EventHook<FrameworkEvent> onGapChangedEvent = const EventHook<FrameworkEvent>('gapChanged');
  Stream<FrameworkEvent> get onGapChanged => VGroup.onGapChangedEvent.forTarget(this);
  int get gap => _layout.gap;
  
  set gap(int value) {
    if (value != _layout.gap) {
      _layout.gap = value;

      notify(
        new FrameworkEvent(
          "gapChanged"
        )
      );
    }
  }
  
  //---------------------------------
  // align
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onAlignChangedEvent = const EventHook<FrameworkEvent>('alignChanged');
  Stream<FrameworkEvent> get onAlignChanged => HGroup.onAlignChangedEvent.forTarget(this);

  String get align => _layout.align;
  
  set align(String value) {
    if (value != _layout.align) {
      _layout.align = value;

      notify(
        new FrameworkEvent(
          "alignChanged"
        )
      );
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

