part of dart_flex;

class Button extends Component {
  
  @event Stream<FrameworkEvent> onButtonClick;
  @event Stream<FrameworkEvent> onLabelChanged;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  Event lastClickEvent;
  
  bool _allowClick = true;

  //---------------------------------
  // label
  //---------------------------------
  
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
    _className = 'button';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    if (_control == null) {
      ButtonElement element = new ButtonElement()
      ..type = 'button';
      
      _streamSubscriptionManager.add(
          'button_elementClick', 
          element.onClick.listen(_propagateClick)
      );
      
      _streamSubscriptionManager.add(
          'button_elementClick', 
          element.onTouchLeave.listen(_propagateClick)
      );

      _setControl(element);
    }

    super.createChildren();
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _commitLabel() {
    if (_control != null) invokeLaterSingle('', _updateElementText, arguments: [_label]);
    else invokeLaterSingle('', _commitLabel);
  }
  
  void _updateElementText(String label) => _control.setInnerHtml(label);
  
  void _propagateClick(Event event) {
    if (_allowClick) {
      _allowClick = false;
      
      lastClickEvent = event;
      
      notify(
          new FrameworkEvent(
              'buttonClick'
          )
      );
      
      new Timer(
        const Duration(milliseconds: 50),
        () => _allowClick = true
      );
    }
  }
}