part of dart_flex;

typedef String TitleHandler(String S);
 
class RichText extends UIWrapper {
 
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
 
  static const EventHook<FrameworkEvent> onClickEvent = const EventHook<FrameworkEvent>('click');
  Stream<FrameworkEvent> get onClick => RichText.onClickEvent.forTarget(this);
 
  //---------------------------------
  // label
  //---------------------------------
 
  Element _label;
 
  Element get label => _label;
 
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
      _richText = null;
 
      notify(
        new FrameworkEvent(
          'textChanged'
        )
      );
 
      _commitText();
    }
  }
 
  //---------------------------------
  // richText
  //---------------------------------
 
  static const EventHook<FrameworkEvent> onRichTextChangedEvent = const EventHook<FrameworkEvent>('richTextChanged');
  Stream<FrameworkEvent> get onRichTextChanged => RichText.onRichTextChangedEvent.forTarget(this);
  String _richText;
 
  String get richText => _richText;
  set richText(String value) {
    if (value != _richText) {
      _text = null;
      _richText = value;
 
      notify(
        new FrameworkEvent(
          'richTextChanged'
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
  // autoTruncate
  //---------------------------------
 
  static const EventHook<FrameworkEvent> onAutoTruncateChangedEvent = const EventHook<FrameworkEvent>('autoTruncateChangedEvent');
  Stream<FrameworkEvent> get onAutoTruncateChanged => RichText.onAutoTruncateChangedEvent.forTarget(this);
  bool _autoTruncate = false;
 
  bool get autoTruncate => _autoTruncate;
  set autoTruncate(bool value) {
    if (value != _autoTruncate) {
       _autoTruncate = value;
 
      notify(
        new FrameworkEvent(
          'autoTruncateChangedEvent'
        )
      );
 
      _commitTextAutoTruncate();
    }
  }
  
  //---------------------------------
  // titleHandler
  //---------------------------------
 
  static const EventHook<FrameworkEvent> onTitleHandlerChangedEvent = const EventHook<FrameworkEvent>('titleHandlerChangedEvent');
  Stream<FrameworkEvent> get onTitleHandlerChanged => RichText.onTitleHandlerChangedEvent.forTarget(this);
  TitleHandler _titleHandler;
 
  TitleHandler get titleHandler => _titleHandler;
  set titleHandler(TitleHandler value) {
    if (value != _titleHandler) {
       _titleHandler = value;
 
      notify(
        new FrameworkEvent(
          'titleHandlerChangedEvent'
        )
      );
 
      _commitTextAutoTruncate();
    }
  }
 
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
 
  RichText({String elementId: null}) : super(elementId: elementId) {
       _className = 'RichText';
      
       _autoSize = false;
  }
 
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
 
  @override
  void createChildren() {
    super.createChildren();
   
    _label = new LabelElement()
      ..onClick.listen((_) => notify(new FrameworkEvent('click')));
 
    _setControl(_label);
 
    _commitTextAlign();
    _commitTextVerticalAlign();
    _commitTextAutoTruncate();
    _commitText();
  }
 
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
 
  void _commitTextAlign() {
    if (_label != null) _reflowManager.invalidateCSS(_control, 'text-align', _align);
  }
 
  void _commitTextVerticalAlign() {
    if (_label != null) _reflowManager.invalidateCSS(_control, 'vertical-align', _verticalAlign);
  }
 
  void _commitTextAutoTruncate() {
    if (_autoTruncate) {
      if (_label != null) _reflowManager.invalidateCSS(_control, 'text-overflow', 'ellipsis');
      if (_label != null) _reflowManager.invalidateCSS(_control, 'white-space', 'nowrap');
    } else {
      if (_label != null) _reflowManager.invalidateCSS(_control, 'text-overflow', 'clip');
      if (_label != null) _reflowManager.invalidateCSS(_control, 'white-space', 'normal');
    }
  }
 
  void _commitText() {
    if (_label != null) invokeLaterSingle('commitTextOnReflow', _commitTextOnReflow);
  }
 
  void _commitTextOnReflow() {
    final String newText = (_richText != null) ? _richText : (_text != null) ? _text : '';
    
    if (_richText != null) {
      _label.setInnerHtml(newText, treeSanitizer: new NullTreeSanitizer());
      
      control.title = (_titleHandler != null) ? _titleHandler(newText) : newText.replaceAll(new RegExp(r'<[^>]+>'), '');
    } else {
      _label.text = newText;
      
      control.title = (_titleHandler != null) ? _titleHandler(newText) : newText;
    }
  }
}