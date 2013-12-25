part of dart_flex;

class Toggle extends UIWrapper {
  
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

  static const EventHook<FrameworkEvent> onIsToggledChangedEvent = const EventHook<FrameworkEvent>('isToggledChanged');
  Stream<FrameworkEvent> get onIsToggledChanged => Toggle.onIsToggledChangedEvent.forTarget(this);
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
    if (_control != null) {
      _reflowManager.scheduleMethod(this, _commitIsToggledOnReflow, []);
    }
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

