part of dart_flex;

class EditableDouble extends UIWrapper {
  
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
  
  NumberInputElement label;

  //---------------------------------
  // value
  //---------------------------------

  static const EventHook<FrameworkEvent> onValueChangedEvent = const EventHook<FrameworkEvent>('valueChanged');
  Stream<FrameworkEvent> get onValueChanged => EditableDouble.onValueChangedEvent.forTarget(this);
  double _value;

  double get value => _value;
  set value(double newValue) {
    if (newValue != _value) {
      _value = newValue;

      notify(
        new FrameworkEvent(
          'valueChanged'
        )
      );

      _commitValue();
    }
  }
  
  //---------------------------------
  // min
  //---------------------------------

  static const EventHook<FrameworkEvent> onMinChangedEvent = const EventHook<FrameworkEvent>('minChanged');
  Stream<FrameworkEvent> get onMinChanged => EditableDouble.onMinChangedEvent.forTarget(this);
  double _min = .0;

  double get min => _min;
  set min(double value) {
    if (value != _min) {
      _min = value;

      notify(
        new FrameworkEvent(
          'minChanged'
        )
      );

      _commitValue();
    }
  }
  
  //---------------------------------
  // max
  //---------------------------------

  static const EventHook<FrameworkEvent> onMaxChangedEvent = const EventHook<FrameworkEvent>('maxChanged');
  Stream<FrameworkEvent> get onMaxChanged => EditableDouble.onMaxChangedEvent.forTarget(this);
  double _max = 100.0;

  double get max => _max;
  set max(double value) {
    if (value != _max) {
      _max = value;

      notify(
        new FrameworkEvent(
          'maxChanged'
        )
      );

      _commitValue();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  EditableDouble({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableDouble';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    label = new NumberInputElement()
    ..step = '0.01'
    ..readOnly = !_enabled;
    
    label.onInput.listen(_label_inputHandler);
    
    _autoSize = true;

    _setControl(label);

    _commitValue();
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

  void _commitValue() {
    if (_control != null) _reflowManager.scheduleMethod(this, _commitValueOnReflow, []);
  }
  
  void _commitValueOnReflow() {
    final NumberInputElement controlCast = _control as NumberInputElement;
    
    controlCast.min = _min.toString();
    controlCast.max = max.toString();
    
    if (_value == _valueAsNumber(controlCast.value)) return;
    
    controlCast.value = (_value != null) ? _value.toString() : null;
  }
  
  void _label_inputHandler(Event event) {
    final NumberInputElement label = _control as NumberInputElement;
    final num doubleValue = _valueAsNumber(label.value);
    
    if (
        (doubleValue != null) &&
        !doubleValue.isNaN
    ) value = _valueAsNumber(label.value);
    else value = null;
  
    _commitValue();
  }
  
  double _valueAsNumber(String value) => double.parse(value, (_) => .0);
}