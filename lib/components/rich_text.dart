part of dartflex;

class RichText extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  bool _isWidthAutoScaled = false;
  bool _isHeightAutoScaled = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // text
  //---------------------------------

  static const EventHook<FrameworkEvent> onTextChangedEvent = const EventHook<FrameworkEvent>('textChanged');
  Stream<FrameworkEvent> get onTextChanged => RichText.onTextChangedEvent.forTarget(this);
  String _text;

  String get text => _text;
  set text(String value) {
    if (value != _text) {
      _text = value;

      notify(
        new FrameworkEvent(
          'textChanged'
        )
      );

      _commitText();
    }
  }

  //---------------------------------
  // align
  //---------------------------------

  static const EventHook<FrameworkEvent> onAlignChangedEvent = const EventHook<FrameworkEvent>('alignChanged');
  Stream<FrameworkEvent> get onAlignChanged => RichText.onAlignChangedEvent.forTarget(this);
  String _align = 'left';

  String get align => _align;
  set align(String value) {
    if (value != _align) {
      _align = value;

      notify(
        new FrameworkEvent(
          'alignChanged'
        )
      );

      _commitTextAlign();
    }
  }
  
  //---------------------------------
  // verticalAlign
  //---------------------------------

  static const EventHook<FrameworkEvent> onVerticalAlignChangedEvent = const EventHook<FrameworkEvent>('verticalAlignChanged');
  Stream<FrameworkEvent> get onVerticalAlignChanged => RichText.onVerticalAlignChangedEvent.forTarget(this);
  String _verticalAlign = 'text-top';

  String get verticalAlign => _verticalAlign;
  set verticalAlign(String value) {
    if (value != _verticalAlign) {
      _verticalAlign = value;

      notify(
        new FrameworkEvent(
          'verticalAlignChanged'
        )
      );

      _commitTextVerticalAlign();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  RichText({String elementId: null}) : super(elementId: elementId) {
  	_className = 'RichText';
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
    
    LabelElement label = new LabelElement();
    
    _autoSize = false;

    _setControl(label);

    _commitTextAlign();
    _commitTextVerticalAlign();
    _commitText();

    _reflowManager.invalidateCSS(_control, 'overflow', 'hidden');
  }

  void _commitTextAlign() {
    if (_control != null) {
      _reflowManager.invalidateCSS(_control, 'text-align', _align);
    }
  }
  
  void _commitTextVerticalAlign() {
    if (_control != null) {
      _reflowManager.invalidateCSS(_control, 'vertical-align', _verticalAlign);
    }
  }

  void _commitText() {
    if (_control != null) {
      _reflowManager.scheduleMethod(this, _commitTextOnReflow, []);
    }
  }
  
  void _commitTextOnReflow() {
    final String newText = (_text != null) ? _text : '';
    
    if (newText == _control.text) {
      return;
    }
    
    _control.text = newText;
    
    if (
        _isWidthAutoScaled ||
        (
          (_width == 0) &&
          (_percentWidth == .0)
        )
    ) {
      _isWidthAutoScaled = true;
      
      _reflowManager.scheduleMethod(this, _updateWidth, [_control.client.width]);
    }
    
    if (
        _isHeightAutoScaled ||
        (
          (_height == 0) &&
          (_percentHeight == .0)
        )
    ) {
      _isHeightAutoScaled = true;
      
      _reflowManager.scheduleMethod(this, _updateHeight, [_control.client.height]);
    }
  }
  
  void _updateWidth(int newSize) {
    final int newWidth = newSize;
    
    if (newWidth > 0) {
      if (newWidth != _width) {
        width = newWidth;
      
        _owner.invalidateProperties();
      }
    } else {
      _reflowManager.scheduleMethod(this, _updateWidth, [_control.client.width]);
    }
  }
  
  void _updateHeight(int newSize) {
    final int newHeight = newSize;
    
    if (newHeight > 0) {
      if (newHeight != _height) {
        height = newHeight;
        
        _owner.invalidateProperties();
      }
    } else {
      _reflowManager.scheduleMethod(this, _updateHeight, [_control.client.height]);
    }
  }
}



