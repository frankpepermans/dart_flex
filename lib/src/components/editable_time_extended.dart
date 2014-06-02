part of dart_flex;

class EditableTimeExtended<T extends DateTime> extends EditableTextMask {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  static const String DATE_MASK = 'dd-HH:MM';
  static const String DATE_MASK_DAY = 'd';
  static const String DATE_MASK_HOUR = 'H';
  static const String DATE_MASK_MINUTE = 'M';

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  EditableTimeExtended({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableTimeExtended';
    
    text = DATE_MASK;
    
    _mask = _oldInputValue = _text;
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // data
  //---------------------------------
  
  set data(T value) {
    super.data = value;
    
    if (!_hasFocus && value == null) text = DATE_MASK;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  bool isValidEntry(String value) {
    final List<String> datePartsA = value.split(':');
    final List<String> datePartsB = datePartsA.first.split('-');
    
    if (datePartsA.length != 2 || datePartsB.length != 2) return false;
    
    return true;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  @override
  void _inputHandler(Event event) {
    super._inputHandler(event);
    
    input.value = _text;
    
    String char = _getChange(_oldInputValue, _text);
    
    bool isDel = (char == DATE_MASK_DAY || char == DATE_MASK_HOUR || char == DATE_MASK_MINUTE);
    
    _oldInputValue = _text;
    
    _updateSelection(!isDel);
    
    _data = _toDateTime(_text);
    
    notify(
      new FrameworkEvent(
        'dataChanged'
      )
    );
    
    later > _setSelectionRange;
  }
  
  @override
  String _formatToString(DateTime date) {
    if (date == null) return input.value;
    
    List<String> list = <String>[];
    final int actualDays = date.day - 1;
    
    if (actualDays < 10) {
      list.add('0$actualDays');
    } else {
      list.add(actualDays.toString());
    }
    
    list.add('-');
    
    if (date.hour < 10) {
      list.add('0${date.hour}');
    } else {
      list.add(date.hour.toString());
    }
    
    list.add(':');
    
    if (date.minute < 10) {
      list.add('0${date.minute}');
    } else {
      list.add(date.minute.toString());
    }
    
    return list.join('');
  }
  
  @override
  void _updateSelection(bool isIncrease) {
    if (isIncrease) {
      if (_selectedSubIndex == 0) {
        _selectedSubIndex++;
      } else {
        _selectedSubIndex = 0;
        _selectedIndex++;
      }
      
      if (_selectedIndex > 2) {
        _selectedSubIndex = 1;
        _selectedIndex = 2;
      }
    } else {
      if (_selectedSubIndex == 1) {
        _selectedSubIndex--;
      } else {
        _selectedSubIndex = 0;
        _selectedIndex--;
      }
      
      if (_selectedIndex < 0) {
        _selectedSubIndex = 0;
        _selectedIndex = 0;
      }
    }
  }
  
  @override
  String _applyInputMask(String incoming) {
    final int incomingLen = incoming.length;
    final int selectionStart = _selectedIndex * 2 + _selectedIndex + _selectedSubIndex;
    final int selectionEnd = (selectionStart + 2 - _selectedSubIndex);
    final int actualSelectionEnd = (selectionEnd > incomingLen) ? incomingLen : selectionEnd;
    final String substr = failSafeSubstring(incoming, selectionStart, actualSelectionEnd);
    final String currentInput = (substr == null) ? _getPlaceholder() : substr;
    
    if (
        !isValidEntry(incoming) ||
        (
            (selectionStart != 0) && 
            failSafeSubstring(incoming, 0, selectionStart) == null
        )
    ) {
      _selectedIndex = -1;
      _selectedSubIndex = 0;
      
      return DATE_MASK;
    }
    
    final List<int> codeUnits = new List<int>.from(currentInput.codeUnits, growable: false);
    final StringBuffer buffer = new StringBuffer(incoming.substring(0, selectionStart));
    final int len = currentInput.length;
    bool hasNumericValue = false;
    int i, codeUnit;
    
    for (i=0; i<len; i++) {
      codeUnit = codeUnits[i];
      
      if (codeUnit < 48 || codeUnit >= 58) {
        codeUnits[i] = 32;
      } else {
        hasNumericValue = true;
      }
      
      if (hasNumericValue) {
        buffer.writeCharCode((codeUnit < 48 || codeUnit >= 58) ? 32 : codeUnits[i]);
      } else {
        buffer.write((_selectedIndex == 0) ? DATE_MASK_DAY : (_selectedIndex == 1) ? DATE_MASK_HOUR : DATE_MASK_MINUTE);
      }
    }
    
    if (_selectedIndex < 2) buffer.write(incoming.substring(incomingLen + buffer.length - _mask.length));
    
    return buffer.toString();
  }
  
  String _getPlaceholder() => (_selectedSubIndex == 1) ? ' ' : '  ';
  
  String _getChange(String start, String end) {
    if (end == DATE_MASK) return DATE_MASK_DAY;
    
    final int len = (start.length <= end.length) ? start.length : end.length;
    int i;
    
    for (i=0; i<len; i++) if (start[i] != end[i]) return end[i];
    
    return null;
  }
  
  DateTime _toDateTime(String value) {
    if (
        (value == DATE_MASK) ||
        value.contains(DATE_MASK_DAY) ||
        value.contains(DATE_MASK_HOUR) ||
        value.contains(DATE_MASK_MINUTE)
    ) return null;
    
    final List<String> datePartsA = value.split(':');
    final List<String> datePartsB = datePartsA.first.split('-');
    
    if (!isValidEntry(value)) return null;
    
    final int minutes = int.parse(datePartsA.last, onError: (_) => 0);
    final int hours = int.parse(datePartsB.last, onError: (_) => 0);
    final int days = int.parse(datePartsB.first, onError: (_) => 0);
    
    return new DateTime.utc(2013, DateTime.APRIL, (days + 1), hours, minutes);
  }
}