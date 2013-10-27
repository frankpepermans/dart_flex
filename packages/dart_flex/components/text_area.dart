part of dart_flex;

class TextArea extends RichText {
  
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

  TextArea({String elementId: null}) : super(elementId: elementId) {
    _className = 'TextArea';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    _label = new TextAreaElement();
    
    _autoSize = false;

    _setControl(_label);

    _commitTextAlign();
    _commitTextVerticalAlign();
    _commitText();
  }
}