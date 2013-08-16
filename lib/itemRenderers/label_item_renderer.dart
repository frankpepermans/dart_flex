part of dart_flex;

class LabelItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // label
  //---------------------------------
  
  RichText _label;
  
  RichText get label => _label;
  set label(RichText value) => _label = value;

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
    ..autoSize = true
    ..text = itemToLabel()
    ..className = 'item-renderer-label';

    addComponent(_label);
  }

  void invalidateData() {
    if (_label != null) {
      _label.text = itemToLabel();
      
      //reflowManager.scheduleMethod(this, invalidateSize, [], forceSingleExecution:true);
    }
  }
  
  String itemToLabel() {
    if (
        (_data != null) &&
        (_field != null)
    ) {
      dynamic value = _data[_field];
      
      return (value != null) ? _data[_field].toString() : null;
    }
    
    return '';
  }
}