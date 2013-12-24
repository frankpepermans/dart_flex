part of dart_flex;

class EditableTextArea extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  TextAreaElement label;

  //---------------------------------
  // text
  //---------------------------------

  static const EventHook<FrameworkEvent> onTextChangedEvent = const EventHook<FrameworkEvent>('textChanged');
  Stream<FrameworkEvent> get onTextChanged => EditableTextArea.onTextChangedEvent.forTarget(this);
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
  Stream<FrameworkEvent> get onAlignChanged => EditableTextArea.onAlignChangedEvent.forTarget(this);
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
  Stream<FrameworkEvent> get onVerticalAlignChanged => EditableTextArea.onVerticalAlignChangedEvent.forTarget(this);
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

  EditableTextArea({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableTextArea';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    label = new TextAreaElement()
    ..style.resize = 'none'
    ..readOnly = !_enabled;
    
    label.onInput.listen(_label_inputHandler);
    
    _autoSize = true;

    _setControl(label);

    _commitTextAlign();
    _commitTextVerticalAlign();
    _commitText();
  }
  
  @override
  void updateEnabledStatus() {
    super.updateEnabledStatus();
    
    if (label != null) label.readOnly = !_enabled;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

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
    final TextAreaElement controlCast = _control as TextAreaElement;
    
    if (newText == controlCast.value) {
      return;
    }
    
    controlCast.value = newText;
  }
  
  void _label_inputHandler(Event event) {
    final TextAreaElement label = _control as TextAreaElement;
    
    text = label.value;
  }
}