part of dart_flex;

class Toggle extends Component {
  
  @event Stream<FrameworkEvent> onIsToggledChanged;
  
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
  // isToggled
  //---------------------------------

  bool _isToggled = false;

  bool get isToggled => _isToggled;
  set isToggled(bool value) {
    if (value != _isToggled) {
      _isToggled = value;

      notify(
        new FrameworkEvent(
          'isToggledChanged'
        )
      );
      
      _commitIsToggled();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Toggle({String elementId: null}) : super(elementId: elementId) {
    _className = 'Toggle';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    _handle = new RangeInputElement()
      ..value = _isToggled ? '1' : '0'
      ..min = '0'
      ..max = '1'
      ..step = '1';
      
    _handle.onChange.listen(_handle_changeHandler);
      
    _setControl(_handle);

    super.createChildren();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _commitIsToggled() {
    if (_control != null) invokeLaterSingle('commitIsToggledOnReflow', _commitIsToggledOnReflow);
  }
  
  void _commitIsToggledOnReflow() {
    if (_handle != null) {
      _handle.value = _isToggled ? '1' : '0';
    }
  }
  
  void _handle_changeHandler(Event event) {
    isToggled = (_handle.value == '1');
  }
}

