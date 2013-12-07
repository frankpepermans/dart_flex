part of dart_flex;

class EditableLabelItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  EditableText textArea;

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

  static EditableLabelItemRenderer construct() => new EditableLabelItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
    textArea = new EditableText()
    ..percentWidth = 100.0
    ..height = 18
    ..paddingLeft = 5
    ..text = itemToLabel();
    
    textArea.onTextChanged.listen(textArea_onTextChangedHandler);

    addComponent(textArea);
  }

  void invalidateData() {
    if (textArea != null) textArea.text = itemToLabel();
  }
  
  String itemToLabel() {
    if (
        (_data != null) &&
        (_field != null)
    ) return _data[_field].toString();
    
    return '';
  }
  
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (
        (_data != null) &&
        (_field != null)
    ) _data[_field] = textArea.text;
  }
}