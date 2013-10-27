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

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    super._createChildren();
    
    NumberInputElement label = new NumberInputElement()
    ..step = '0.01';
    
    label.onInput.listen(_label_inputHandler);
    
    _autoSize = true;

    _setControl(label);

    _commitValue();
  }

  void _commitValue() {
    if (_control != null) {
      _reflowManager.scheduleMethod(this, _commitValueOnReflow, []);
    }
  }
  
  void _commitValueOnReflow() {
    final NumberInputElement controlCast = _control as NumberInputElement;
    
    controlCast.min = _min.toString();
    controlCast.max = max.toString();
    
    if (_value == controlCast.valueAsNumber) {
      return;
    }
    
    controlCast.value = (_value != null) ? _value.toDouble().toString() : null;
  }
  
  void _label_inputHandler(Event event) {
    final NumberInputElement label = _control as NumberInputElement;
    
    if (!label.valueAsNumber.isNaN) {
      value = label.valueAsNumber.toDouble();
    } else {
      value = null;
    }
  
    _commitValue();
  }
}