part of dartflex;

class LabelItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  RichText _label;

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

  LabelItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false) {
    layout = new HorizontalLayout();
  }

  static LabelItemRenderer construct() {
    return new LabelItemRenderer();
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
    _label = new RichText()
    ..percentWidth = 100.0
    ..height = 18
    ..paddingLeft = 5
    ..text = itemToLabel();

    addComponent(_label);
  }

  void invalidateData() {
    if (_label != null) {
      _label.text = itemToLabel();
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
}