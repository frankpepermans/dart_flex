part of dart_flex;

class EditableDate extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  DateInputElement _dateInput;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // date
  //---------------------------------

  static const EventHook<FrameworkEvent> onDateChangedEvent = const EventHook<FrameworkEvent>('dateChanged');
  Stream<FrameworkEvent> get onDateChanged => EditableDate.onDateChangedEvent.forTarget(this);
  DateTime _date;

  DateTime get date => _date;
  set date(DateTime value) {
    if (value != _date) {
      _date = value;

      notify(
        new FrameworkEvent(
          'dateChanged'
        )
      );

      _commitDate();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  EditableDate({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableDate';
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
    
    _dateInput = new DateInputElement();
    
    _dateInput.onInput.listen(_date_inputHandler);
    _dateInput.onReset.listen(_date_inputHandler);
    
    _autoSize = true;

    _setControl(_dateInput);

    _commitDate();
  }

  void _commitDate() {
    if (
        (_control != null) &&
        (_date != null)
    ) {
      _reflowManager.scheduleMethod(this, _commitDateOnReflow, []);
    }
  }
  
  void _commitDateOnReflow() {
    _dateInput.valueAsDate = _date;
  }
  
  void _date_inputHandler(Event event) {
    DateTime value = _dateInput.valueAsDate;
    
    if (value != null) {
      value = value.toUtc();
      
      _date = new DateTime.utc(
        value.year,
        value.month,
        value.day
      );
    } else {
      _date = null;
    }
    
    notify(
        new FrameworkEvent(
            'dateChanged'
        )
    );
  }
}