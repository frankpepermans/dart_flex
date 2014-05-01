part of dart_flex;

class ColorBox extends UIWrapper {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // color
  //---------------------------------

  static const EventHook<FrameworkEvent> onColorChangedEvent = const EventHook<FrameworkEvent>('colorChanged');
  Stream<FrameworkEvent> get onColorChanged => ColorBox.onColorChangedEvent.forTarget(this);
  String _color;

  String get color => _color;
  set color(String value) {
    if (value != _color) {
      _color = value;

      notify(
          new FrameworkEvent('colorChanged')
      );

      _commitColor();
    }
  }

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ColorBox({String elementId: null}) : super(elementId: elementId) {
    _className = 'ColorBox';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    if (_control == null) {
      DivElement controlCast = new DivElement();
      
      _reflowManager.invalidateCSS(controlCast, 'background-color', _color);

      _setControl(controlCast);
    }

    super.createChildren();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _commitColor() {
    super.commitProperties();

    if (_control != null && _reflowManager != null) {
      DivElement controlCast = _control as DivElement;

      _reflowManager.invalidateCSS(controlCast, 'background-color', _color);
    }
  }
}

