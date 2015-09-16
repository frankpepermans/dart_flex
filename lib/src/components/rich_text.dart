part of dart_flex;

typedef String TitleHandler(String S);
 
class RichText extends Component {
  
  @event Stream<FrameworkEvent> onClick;
  @event Stream<FrameworkEvent> onTextChanged;
  @event Stream<FrameworkEvent> onRichTextChanged;
  @event Stream<FrameworkEvent> onAlignChanged;
  @event Stream<FrameworkEvent> onVerticalAlignChanged;
  @event Stream<FrameworkEvent> onAutoTruncateChanged;
  @event Stream<FrameworkEvent> onTitleHandlerChanged;
 
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
 
  //---------------------------------
  // label
  //---------------------------------
 
  Element _label;
 
  Element get label => _label;
 
  //---------------------------------
  // text
  //---------------------------------
 
  String _text;
 
  String get text => _text;
  set text(String value) {
    if (value != _text) {
      _text = value;
      _richText = null;
 
      notify('textChanged');
 
      _commitText();
    }
  }
 
  //---------------------------------
  // richText
  //---------------------------------
  
  String _richText;
 
  String get richText => _richText;
  set richText(String value) {
    if (value != _richText) {
      _text = null;
      _richText = value;
 
      notify('richTextChanged');
 
      _commitText();
    }
  }
 
  //---------------------------------
  // align
  //---------------------------------
  
  String _align = 'left';
 
  String get align => _align;
  set align(String value) {
    if (value != _align) {
      _align = value;
 
      notify('alignChanged');
 
      _commitTextAlign();
    }
  }
 
  //---------------------------------
  // verticalAlign
  //---------------------------------
 
  String _verticalAlign = 'text-top';
 
  String get verticalAlign => _verticalAlign;
  set verticalAlign(String value) {
    if (value != _verticalAlign) {
      _verticalAlign = value;
 
      notify('verticalAlignChanged');
 
      _commitTextVerticalAlign();
    }
  }
 
  //---------------------------------
  // autoTruncate
  //---------------------------------
 
  bool _autoTruncate = false;
 
  bool get autoTruncate => _autoTruncate;
  set autoTruncate(bool value) {
    if (value != _autoTruncate) {
       _autoTruncate = value;
 
      notify('autoTruncateChangedEvent');
 
      _commitTextAutoTruncate();
    }
  }
  
  //---------------------------------
  // titleHandler
  //---------------------------------
 
  TitleHandler _titleHandler;
 
  TitleHandler get titleHandler => _titleHandler;
  set titleHandler(TitleHandler value) {
    if (value != _titleHandler) {
       _titleHandler = value;
 
      notify('titleHandlerChangedEvent');
 
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
      ..onClick.listen((_) => notify('click'));
 
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