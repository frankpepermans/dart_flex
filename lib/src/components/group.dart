part of dart_flex;

enum ScrollPolicy {
  DISABLED,
  NONE,
  AUTO,
  ON
}

class Group extends Component {
  
  @event Stream<FrameworkEvent> onHorizontalScrollPolicyChanged;
  @event Stream<FrameworkEvent> onVerticalScrollPolicyChanged;

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  bool _isScrollPolicyInvalid = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // horizontalScrollPolicy
  //---------------------------------

  ScrollPolicy _horizontalScrollPolicy = ScrollPolicy.NONE;

  ScrollPolicy get horizontalScrollPolicy => _horizontalScrollPolicy;
  set horizontalScrollPolicy(ScrollPolicy value) {
    if (value != _horizontalScrollPolicy) {
      _horizontalScrollPolicy = value;

      _isScrollPolicyInvalid = true;

      notify('horizontalScrollPolicyChanged');

      invalidateProperties();
    }
  }

  //---------------------------------
  // verticalScrollPolicy
  //---------------------------------
  
  ScrollPolicy _verticalScrollPolicy = ScrollPolicy.NONE;

  ScrollPolicy get verticalScrollPolicy => _verticalScrollPolicy;
  set verticalScrollPolicy(ScrollPolicy value) {
    if (value != _verticalScrollPolicy) {
      _verticalScrollPolicy = value;

      _isScrollPolicyInvalid = true;

      notify('verticalScrollPolicyChanged');

      invalidateProperties();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Group({String elementId: null}) : super(elementId: elementId) {
  	_className = 'Group';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    if (_control == null) _setControl(new DivElement());

    super.createChildren();
  }
  
  @override
  void commitProperties() {
    super.commitProperties();

    if (_control != null) {
      if (_isScrollPolicyInvalid) {
        _isScrollPolicyInvalid = false;

        _updateScrollPolicy();
      }
    }
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _setControl(Element element) {
    super._setControl(element);

    _isScrollPolicyInvalid = true;
  }

  void _updateScrollPolicy() {
    switch (_horizontalScrollPolicy) {
      case ScrollPolicy.NONE:
        _reflowManager.invalidateCSS(_control, 'overflow-x', 'hidden');   break;
      case ScrollPolicy.AUTO:
        _reflowManager.invalidateCSS(_control, 'overflow-x', 'auto');     break;
      case ScrollPolicy.ON:
        _reflowManager.invalidateCSS(_control, 'overflow-x', 'scroll');   break;
      case ScrollPolicy.DISABLED:
        _reflowManager.invalidateCSS(_control, 'overflow-x', 'visible');  break;
    }
    
    switch (_verticalScrollPolicy) {
      case ScrollPolicy.NONE:
        _reflowManager.invalidateCSS(_control, 'overflow-y', 'hidden');   break;
      case ScrollPolicy.AUTO:
        _reflowManager.invalidateCSS(_control, 'overflow-y', 'auto');     break;
      case ScrollPolicy.ON:
        _reflowManager.invalidateCSS(_control, 'overflow-y', 'scroll');   break;
      case ScrollPolicy.DISABLED:
        _reflowManager.invalidateCSS(_control, 'overflow-y', 'visible');  break;
    }
  }
}

