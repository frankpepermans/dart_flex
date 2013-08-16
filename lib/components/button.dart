part of dart_flex;

class Button extends UIWrapper {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // label
  //---------------------------------

  static const EventHook<FrameworkEvent> onLabelChangedEvent = const EventHook<FrameworkEvent>('labelChanged');
  Stream<FrameworkEvent> get onLabelChanged => Button.onLabelChangedEvent.forTarget(this);
  String _label;

  String get label => _label;
  set label(String value) {
    if (value != _label) {
      _label = value;

      notify(
        new FrameworkEvent(
          'labelChanged'
        )
      );

      _commitLabel();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Button({String elementId: null}) : super(elementId: elementId) {
    _className = 'Button';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onButtonClickEvent = const EventHook<FrameworkEvent>('buttonClick');
  Stream<FrameworkEvent> get onButtonClick => Button.onButtonClickEvent.forTarget(this);

  void _createChildren() {
    if (_control == null) {
      ButtonElement element = new ButtonElement();

      element.onClick.listen(
        (Event event) => notify(
          new FrameworkEvent(
            'buttonClick'
          )
        )
      );
      
      element.onTouchLeave.listen(
          (Event event) => notify(
              new FrameworkEvent(
                  'buttonClick'
              )
          )
      );

      _setControl(element);
    }

    super._createChildren();
  }

  void _commitLabel() {
    if (_control != null) {
      _reflowManager.scheduleMethod(this, _updateElementText, [_label]);
    } else {
      later > _commitLabel;
    }
  }
  
  void _updateElementText(String label) {
    ButtonElement element = _control as ButtonElement;
    
    element.innerHtml = label;
  }
}



