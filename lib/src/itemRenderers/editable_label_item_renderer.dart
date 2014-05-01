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
  
  @override
  void createChildren() {
    super.createChildren();
    
    textArea = new EditableText()
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..text = itemToLabel();
    
    _streamSubscriptionManager.add(
        'editable_label_item_renderer_chainDataListChanges', 
        textArea.onTextChanged.listen(textArea_onTextChangedHandler)
    );

    addComponent(textArea);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
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