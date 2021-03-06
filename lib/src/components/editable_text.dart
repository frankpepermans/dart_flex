part of dart_flex;

class EditableText extends Component {
  
  @event Stream<FrameworkEvent> onTextChanged;
  @event Stream<FrameworkEvent> onInput;
  @event Stream<FrameworkEvent> onAlignChanged;
  @event Stream<FrameworkEvent> onPatternChanged;
  @event Stream<FrameworkEvent> onVerticalAlignChanged;
  @event Stream<FrameworkEvent> onDataChanged;
  @event Stream<FrameworkEvent> onDataFinalized;
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  bool _allowKeyStroke = true;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  TextInputElement input;

  //---------------------------------
  // text
  //---------------------------------
  
  String _text;

  String get text => _text;
  set text(String value) {
    if (value != _text) {
      _text = value;

      notify('textChanged');

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
  // pattern
  //---------------------------------

  String _pattern;

  String get pattern => _pattern;
  set pattern(String value) {
    if (value != _pattern) {
      _pattern = value;

      notify('patternChanged');

      _commitTextPattern();
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
  //
  // Constructor
  //
  //---------------------------------

  EditableText({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableText';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    input = new TextInputElement()..readOnly = !_enabled;
    
    input.onInput.listen(_inputHandler);
    
    _autoSize = true;

    _setControl(input);

    _commitTextAlign();
    _commitTextPattern();
    _commitTextVerticalAlign();
    _commitText();
  }
  
  @override
  void updateEnabledStatus() {
    super.updateEnabledStatus();
    
    if (input != null) input.readOnly = !_enabled;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _commitTextAlign() {
    if (_control != null) _reflowManager.invalidateCSS(_control, 'text-align', _align);
  }
  
  void _commitTextPattern() {
    if (input != null) input.pattern = (_pattern != null) ? _pattern : '';
  }
  
  void _commitTextVerticalAlign() {
    if (_control != null) _reflowManager.invalidateCSS(_control, 'vertical-align', _verticalAlign);
  }

  void _commitText() {
    if (_control != null) invokeLaterSingle('commitTextOnReflow', _commitTextOnReflow);
  }
  
  void _commitTextOnReflow() {
    final String newText = (_text != null) ? _text : '';
    
    if (newText == input.value) return;
    
    input.value = newText;
  }
  
  void _inputHandler(Event event) {
    text = input.value;
    
    notify('input');
  }
}

class EditableTextMask<T extends DateTime> extends EditableText {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  static const String DATA_MASKED = 'm';
  
  String _oldInputValue;
  int _selectedIndex = -1;
  int _selectedSubIndex = 0;
  bool _hasFocus = false;
  
  //---------------------------------
  // doubleCharSize
  //---------------------------------
  
  int _doubleCharSize = 20;
  
  int get doubleCharSize => _doubleCharSize;
  void set doubleCharSize(int value) {
    if (value != _doubleCharSize) {
      _doubleCharSize = value;
    }
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // mask
  //---------------------------------
  
  String _mask = '';
  
  String get mask => _mask;

  //---------------------------------
  // data
  //---------------------------------
  
  T _data;

  T get data => _data;
  set data(T value) {
    if (
        !_hasFocus &&
        (value != _data)
    ) {
      _data = value;

      notify('dataChanged');

      text = _formatToString(value);
      
      _oldInputValue = _text;
      
      _selectedIndex = -1;
      _selectedSubIndex = 0;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  EditableTextMask({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableTextMask';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    input.pattern = '[^]{${_mask.length}}';
    
    input.onBlur.listen(_input_blurHandler);
    
    input.onKeyDown.listen(_input_focusHandler);
    input.onFocus.listen(_input_focusHandler);
    input.onSelect.listen(_input_focusHandler);
    input.onSelectStart.listen(_input_focusHandler);
    input.onMouseDown.listen(_input_focusHandler);
    input.onMouseUp.listen(_input_focusHandler);
    input.onTouchStart.listen(_input_focusHandler);
    input.onTouchEnd.listen(_input_focusHandler);
    
    input.onDrag.listen(_input_preventEvent);
    input.onDragEnd.listen(_input_preventEvent);
    input.onDragEnter.listen(_input_preventEvent);
    input.onDragLeave.listen(_input_preventEvent);
    input.onDragOver.listen(_input_preventEvent);
    input.onDragStart.listen(_input_preventEvent);
  }
  
  String failSafeSubstring(String value, int startIndex, int endIndex) {
    if (
        (value == null) ||
        (startIndex == null) ||
        (endIndex == null) ||
        (startIndex >= endIndex) ||
        (endIndex > value.length) ||
        (startIndex < 0) ||
        (endIndex < 0)
    ) return null;
    
    return value.substring(startIndex, endIndex);
  }
  
  bool isValidEntry(String entry) => false;

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  @override
  void _inputHandler(Event event) {
    text = _applyInputMask(input.value);
    
    notify('input');
  }
  
  String _applyInputMask(String incoming) => null;
  
  void _input_blurHandler(Event event) {
    text = _formatToString(_data);
    
    _hasFocus = false;
    
    notify('dataFinalized');
  }
  
  void _input_preventEvent(Event event) {
    event.preventDefault();
    event.stopImmediatePropagation();
    event.stopPropagation();
  }
  
  void _input_focusHandler(Event event) {
    _hasFocus = true;
    
    if (!_allowKeyStroke && (event is KeyboardEvent)) {
      event.preventDefault();
      
      return;
    }
    
    if (event is KeyboardEvent) {
      _allowKeyStroke = const <int>[KeyCode.SHIFT, KeyCode.CTRL, KeyCode.ALT].contains(event.keyCode);
      
      if (input.selectionEnd - input.selectionStart > 2) {
        event.preventDefault();
        
        return;
      }
      
      if (event.keyCode == 9) {
        if (_selectedIndex == (_mask.length / 3).floor()) return;
        
        _updateSelection(true);
        
        event.preventDefault();
      } else {
        if (
            (event.keyCode == 8) ||
            (event.keyCode == 46) ||
            (
                (event.keyCode >= 48) &&
                (event.keyCode < 58) 
            ) ||
            (
                (event.keyCode >= 96) &&
                (event.keyCode < 106)
            )
        ) {
          if (
              (event.keyCode >= 37) &&
              (event.keyCode <= 40)
          ) _updateSelection(
              (event.keyCode == 38) ||
              (event.keyCode == 39)
          );
          else return;
        } else {
          event.preventDefault();
          
          return;
        }
      }
    }
    
    if (
        (event is MouseEvent) &&
        (_text != _mask)
    ) {
      final Point pos = event.offset;
      
      _selectedSubIndex = 0;
      _selectedIndex = (pos.x / _doubleCharSize).floor();
      
      if (_selectedIndex > _mask.length / 3) _selectedIndex = (_mask.length / 3).floor();
    } else if (_selectedIndex == -1) {
      _selectedIndex = 0;
    }
    
    invokeLaterSingle('setSelectionRange', _setSelectionRange);
  }
  
  void _updateSelection(bool isIncrease) {
    if (isIncrease) {
      if (_selectedSubIndex == 0) {
        _selectedSubIndex++;
      } else {
        _selectedSubIndex = 0;
        _selectedIndex++;
      }
    } else {
      if (_selectedSubIndex == 1) {
        _selectedSubIndex--;
      } else {
        _selectedSubIndex = 0;
        _selectedIndex--;
      }
    }
  }
  
  void _setSelectionRange() {
    final int selectionStart = _selectedIndex * 2 + _selectedIndex + _selectedSubIndex;
    
    input.setSelectionRange(selectionStart, (selectionStart + 2 - _selectedSubIndex));
    
    _allowKeyStroke = true;
  }
  
  String _getPlaceholder() => (_selectedSubIndex == 1) ? ' ' : '  ';
  
  String _getChange(String start, String end) {
    if (end == _mask) return DATA_MASKED;
    
    final int len = (start.length <= end.length) ? start.length : end.length;
    int i;
    
    for (i=0; i<len; i++) if (start[i] != end[i]) return end[i];
    
    return null;
  }
  
  String _formatToString(DateTime date) => null;
}