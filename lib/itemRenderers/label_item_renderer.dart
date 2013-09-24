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
  
  String obtainValue() {
    dynamic value;
    
    if (_data != null) {
      if (_fields != null) {
        value = _data;
        
        _fields.forEach(
          (String subField) {
            if (value != null) value = value[subField];
          }
        );
      } else if (_field != null) {
        value = _data[_field];
      }
      
      if (_labelHandler != null) return _labelHandler(value);
      
      return (value != null) ? value.toString() : '';
    }
    
    return '';
  }
  
  String itemToLabel() => obtainValue();
}