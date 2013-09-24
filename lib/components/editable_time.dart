part of dart_flex;

class EditableTime extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  TimeInputElement _timeInput;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // time
  //---------------------------------

  static const EventHook<FrameworkEvent> onTimeChangedEvent = const EventHook<FrameworkEvent>('timeChanged');
  Stream<FrameworkEvent> get onTimeChanged => EditableTime.onTimeChangedEvent.forTarget(this);
  DateTime _time;

  DateTime get time => _time;
  set time(DateTime value) {
    if (value != _time) {
      _time = value;

      notify(
        new FrameworkEvent(
          'timeChanged'
        )
      );

      _commitTime();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  EditableTime({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableTime';
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
    
    _timeInput = new TimeInputElement();
    
    _timeInput.onInput.listen(_time_inputHandler);
    _timeInput.onReset.listen(_time_inputHandler);
    
    _autoSize = true;

    _setControl(_timeInput);

    _commitTime();
  }

  void _commitTime() {
    if (
        (_control != null) &&
        (_time != null)
    ) {
      _reflowManager.scheduleMethod(this, _commitTimeOnReflow, []);
    }
  }
  
  void _commitTimeOnReflow() {
    _timeInput.value = _timeToString();
  }
  
  String _timeToString() {
    if (_time == null) {
      return null;
    }
    
    List<String> values = <String>[];
    
    if (_time.hour < 10) {
      values.add('0${_time.hour}');
    } else {
      values.add(_time.hour.toString());
    }
    
    if (_time.minute < 10) {
      values.add('0${_time.minute}');
    } else {
      values.add(_time.minute.toString());
    }
    
    return values.join(':');
  }
  
  void _time_inputHandler(Event event) {
    DateTime value = _timeInput.valueAsDate;
    
    if (value != null) {
      value = value.toUtc();
      
      _time = new DateTime.utc(
        2000,
        1,
        1,
        value.hour,
        value.minute
      );
    } else {
      _time = null;
    }
    
    notify(
        new FrameworkEvent(
            'timeChanged'
        )
    );
  }
}