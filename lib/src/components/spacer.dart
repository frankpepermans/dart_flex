part of dart_flex;

class Spacer extends Component {

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
  //
  // Constructor
  //
  //---------------------------------

  Spacer() : super() {
    _className = 'Spacer';
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
}

