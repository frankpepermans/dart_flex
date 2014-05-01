part of dart_flex;

class Form extends VGroup {
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // tag
  //---------------------------------
  
  FormElement _tag;
  
  FormElement get tag => _tag;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Form({String elementId: null, int gap: 10}) : super(elementId: elementId, gap: gap) {
    _className = 'Form';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _tag = new FormElement();

    _setControl(_tag);
  }
  
  bool runValidation() => _tag.checkValidity();
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
}

