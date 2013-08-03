part of dartflex;

class Footer extends HGroup {
  
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

  Footer({String elementId: null}) : super(elementId: elementId, gap: 0) {
    _className = 'Footer';
    
    _layout.align = 'right';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void _createChildren() {
    super._createChildren();
  }
}