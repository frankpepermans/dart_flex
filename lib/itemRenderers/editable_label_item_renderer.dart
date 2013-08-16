part of dart_flex;

class EditableLabelItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  EditableText _textArea;

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

  EditableLabelItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false) {
    layout = new HorizontalLayout();
  }

  static EditableLabelItemRenderer construct() {
    return new EditableLabelItemRenderer();
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
    _textArea = new EditableText()
    ..percentWidth = 100.0
    ..height = 18
    ..paddingLeft = 5
    ..text = itemToLabel();
    
    _textArea.onTextChanged.listen(textArea_onTextChangedHandler);

    addComponent(_textArea);
  }

  void invalidateData() {
    if (_textArea != null) {
      _textArea.text = itemToLabel();
    }
  }
  
  String itemToLabel() {
    if (
        (_data != null) &&
        (_field != null)
    ) {
      return _data[_field].toString();
    }
    
    return '';
  }
  
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (
        (_data != null) &&
        (_field != null)
    ) {
      _data[_field] = _textArea.text;
    }
  }
}