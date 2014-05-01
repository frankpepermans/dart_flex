part of dart_flex;

class Slider extends UIWrapper {
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  RangeInputElement _handle;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // value
  //---------------------------------

  static const EventHook<FrameworkEvent> onValueChangedEvent = const EventHook<FrameworkEvent>('valueChanged');
  Stream<FrameworkEvent> get onValueChanged => Slider.onValueChangedEvent.forTarget(this);
  num _value = 0;

  num get value => _value;
  set value(num value) {
    if (value != _value) {
      _value = value;

      notify(
        new FrameworkEvent(
          'valueChanged'
        )
      );
      
      _commit();
    }
  }
  
  //---------------------------------
  // min
  //---------------------------------

  static const EventHook<FrameworkEvent> onMinChangedEvent = const EventHook<FrameworkEvent>('minChanged');
  Stream<FrameworkEvent> get onMinChanged => Slider.onMinChangedEvent.forTarget(this);
  num _min = 0;

  num get min => _min;
  set min(num value) {
    if (value != _min) {
      _min = value;

      notify(
        new FrameworkEvent(
          'minChanged'
        )
      );
      
      _commit();
    }
  }
  
  //---------------------------------
  // max
  //---------------------------------

  static const EventHook<FrameworkEvent> onMaxChangedEvent = const EventHook<FrameworkEvent>('maxChanged');
  Stream<FrameworkEvent> get onMaxChanged => Slider.onMaxChangedEvent.forTarget(this);
  num _max = 0;

  num get max => _max;
  set max(num value) {
    if (value != _max) {
      _max = value;

      notify(
        new FrameworkEvent(
          'maxChanged'
        )
      );
      
      _commit();
    }
  }
  
  //---------------------------------
  // step
  //---------------------------------

  static const EventHook<FrameworkEvent> onStepChangedEvent = const EventHook<FrameworkEvent>('stepChanged');
  Stream<FrameworkEvent> get onStepChanged => Slider.onStepChangedEvent.forTarget(this);
  num _step = 0;

  num get step => _step;
  set step(num value) {
    if (value != _step) {
      _step = value;

      notify(
        new FrameworkEvent(
          'stepChanged'
        )
      );
      
      _commit();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Slider({String elementId: null}) : super(elementId: elementId) {
    _className = 'Slider';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _handle = new RangeInputElement()
    ..value = _value.toString()
    ..min = _min.toString()
    ..max = _max.toString()
    ..step = _step.toString();
    
    _handle.onChange.listen(_handle_changeHandler);
    
    _setControl(_handle);
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _commit() {
    if (_control != null)
      _reflowManager.scheduleMethod(this, _commitOnReflow, []);
  }
  
  void _commitOnReflow() {
    if (_handle != null) {
      _handle.step = _step.toString();
      _handle.min = _min.toString();
      _handle.max = _max.toString();
      _handle.value = _value.toString();
    }
  }
  
  void _handle_changeHandler(Event event) {
    value = double.parse(_handle.value);
  }
}

