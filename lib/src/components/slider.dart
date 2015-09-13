part of dart_flex;

class Slider extends Component {
  
  @event Stream<FrameworkEvent> onValueChanged;
  @event Stream<FrameworkEvent> onMinChanged;
  @event Stream<FrameworkEvent> onMaxChanged;
  @event Stream<FrameworkEvent> onStepChanged;
  
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

  num _value = 0;

  num get value => _value;
  set value(num value) {
    if (value != _value) {
      _value = value;

      notify('valueChanged');
      
      _commit();
    }
  }
  
  //---------------------------------
  // min
  //---------------------------------
  
  num _min = 0;

  num get min => _min;
  set min(num value) {
    if (value != _min) {
      _min = value;

      notify('minChanged');
      
      _commit();
    }
  }
  
  //---------------------------------
  // max
  //---------------------------------
  
  num _max = 0;

  num get max => _max;
  set max(num value) {
    if (value != _max) {
      _max = value;

      notify('maxChanged');
      
      _commit();
    }
  }
  
  //---------------------------------
  // step
  //---------------------------------

  num _step = 0;

  num get step => _step;
  set step(num value) {
    if (value != _step) {
      _step = value;

      notify('stepChanged');
      
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
    if (_control != null) invokeLaterSingle('commitOnReflow', _commitOnReflow);
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

