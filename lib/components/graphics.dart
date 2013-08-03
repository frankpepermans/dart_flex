part of dartflex;

class Graphics extends UIWrapper {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // renderingObject
  //---------------------------------

  CanvasRenderingContext2D _context;

  CanvasRenderingContext2D get context => _context;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Graphics({String elementId: null}) : super(elementId: elementId) {
  	_className = 'Graphics';
	
    _includeInLayout = false;
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    super._createChildren();

    CanvasElement controlCast = new CanvasElement(width: _owner.width, height: _owner.height);

    _setControl(controlCast);

    _reflowManager.invalidateCSS(controlCast, 'position', 'absolute');
    _reflowManager.invalidateCSS(controlCast, 'left', '0px');
    _reflowManager.invalidateCSS(controlCast, 'top', '0px');

    _context = controlCast.getContext("2d");
  }

  void _updateLayout() {
    if (
      (_width > 0) &&
      (_height > 0)
    ) {
      if (_control != null) {
        CanvasElement controlCast = _control as CanvasElement;

        controlCast.width = _width;
        controlCast.height = _height;
      }

      super._updateLayout();
    }
  }
}





