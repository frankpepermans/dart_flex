part of dart_flex;

class EditableDateTime<T extends DateTime> extends EditableTextMask {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  static const String DATE_TIME_MASK = 'dd/mm/yy HH:MM';
  static const String DATE_TIME_MASK_DAY = 'd';
  static const String DATE_TIME_MASK_MONTH = 'm';
  static const String DATE_TIME_MASK_YEAR = 'y';
  static const String DATE_TIME_MASK_HOUR = 'H';
  static const String DATE_TIME_MASK_MINUTE = 'M';

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

  EditableDateTime({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableDateTime';
    
    text = DATE_TIME_MASK;
    
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
    
    if (!_hasFocus && value == null) text = DATE_TIME_MASK;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  bool isValidEntry(String value) {
    final List<String> dateParts = value.split('/');
    final List<String> timeParts = value.split(':');
    
    if (
        (dateParts.length != 3) ||
        (timeParts.length != 2)
    ) return false;
    
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
    
    bool isDel = (char == DATE_TIME_MASK_DAY || char == DATE_TIME_MASK_MONTH || char == DATE_TIME_MASK_YEAR || char == DATE_TIME_MASK_HOUR || char == DATE_TIME_MASK_MINUTE);
    
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
    
    if (date.day < 10) {
      list.add('0${date.day}');
    } else {
      list.add(date.day.toString());
    }
    
    list.add('/');
    
    if (date.month < 10) {
      list.add('0${date.month}');
    } else {
      list.add(date.month.toString());
    }
    
    list.add('/');
    
    list.add(date.year.toString().substring(2));
    
    list.add(' ');
    
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
      
      if (_selectedIndex > 4) {
        _selectedSubIndex = 1;
        _selectedIndex = 4;
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
            (failSafeSubstring(incoming, 0, selectionStart) == null)
        )
    ) {
      _selectedIndex = -1;
      _selectedSubIndex = 0;
      
      return DATE_TIME_MASK;
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
        buffer.write((_selectedIndex == 0) ? DATE_TIME_MASK_DAY : (_selectedIndex == 1) ? DATE_TIME_MASK_MONTH : (_selectedIndex == 2) ? DATE_TIME_MASK_YEAR : (_selectedIndex == 3) ? DATE_TIME_MASK_HOUR : DATE_TIME_MASK_MINUTE);
      }
    }
    
    if (_selectedIndex < 4) buffer.write(incoming.substring(incomingLen + buffer.length - _mask.length));
    
    return buffer.toString();
  }
  
  String _getPlaceholder() => (_selectedSubIndex == 1) ? ' ' : '  ';
  
  String _getChange(String start, String end) {
    if (end == DATE_TIME_MASK) return DATE_TIME_MASK_DAY;
    
    final int len = (start.length <= end.length) ? start.length : end.length;
    int i;
    
    for (i=0; i<len; i++) if (start[i] != end[i]) return end[i];
    
    return null;
  }
  
  DateTime _toDateTime(String value) {
    if (
        (value == DATE_TIME_MASK) ||
        value.contains(DATE_TIME_MASK_DAY) ||
        value.contains(DATE_TIME_MASK_MONTH) ||
        value.contains(DATE_TIME_MASK_YEAR) ||
        value.contains(DATE_TIME_MASK_HOUR) ||
        value.contains(DATE_TIME_MASK_MINUTE)
    ) return null;
    
    final List<String> dateParts = value.split('/');
    final List<String> timeParts = value.split(':');
    
    if (
        (dateParts.length != 3)
    ) return null;
    
    if (!isValidEntry(value)) return null;
    
    final int yy = int.parse(dateParts.removeLast().substring(0, 2), onError: (_) => 0);
    final int mm = int.parse(dateParts.removeLast(), onError: (_) => 0);
    final int dd = int.parse(dateParts.removeLast(), onError: (_) => 0);
    
    final int thh = int.parse(timeParts.first.substring(timeParts.first.length - 2), onError: (_) => 0);
    final int tmm = int.parse(timeParts.last, onError: (_) => 0);
    
    return new DateTime.utc(
        (2000 + yy), 
        mm, 
        dd, 
        thh, 
        tmm
    );
  }
}