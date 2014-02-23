part of dart_flex;

class EditableInt extends UIWrapper {
  
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
  
  StreamSubscription _labelChangeListener;

  //---------------------------------
  // value
  //---------------------------------

  static const EventHook<FrameworkEvent> onValueChangedEvent = const EventHook<FrameworkEvent>('valueChanged');
  Stream<FrameworkEvent> get onValueChanged => EditableInt.onValueChangedEvent.forTarget(this);
  static const EventHook<FrameworkEvent> onInputEvent = const EventHook<FrameworkEvent>('input');
  Stream<FrameworkEvent> get onInput => EditableInt.onInputEvent.forTarget(this);
  
  int _value;

  int get value => _value;
  set value(int newValue) {
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
  Stream<FrameworkEvent> get onMinChanged => EditableInt.onMinChangedEvent.forTarget(this);
  int _min = 0;

  int get min => _min;
  set min(int value) {
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
  Stream<FrameworkEvent> get onMaxChanged => EditableInt.onMaxChangedEvent.forTarget(this);
  int _max = 100;

  int get max => _max;
  set max(int value) {
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

  EditableInt({String elementId: null}) : super(elementId: elementId) {
    _className = 'EditableInt';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    label = new NumberInputElement()..readOnly = !_enabled;
    
    _labelChangeListener = label.onInput.listen(_label_inputHandler);
    
    _autoSize = true;

    _setControl(label);

    _commitValue();
  }
  
  @override
  void updateEnabledStatus() {
    super.updateEnabledStatus();
    
    if (label != null) label.readOnly = !_enabled;
  }
  
  @override
  void flushHandler() {
    super.flushHandler();
    
    if (_labelChangeListener != null) _labelChangeListener.cancel();
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
    final int intValue = _valueAsNumber(label.value);
    
    if (
        (intValue != null) &&
        !intValue.isNaN
    ) value = _valueAsNumber(label.value);
    else value = null;
  
    _commitValue();
    
    notify(
        new FrameworkEvent(
            'input'
        )
    );
  }
  
  int _valueAsNumber(String value) => int.parse(value, onError: (_) => 0);
}