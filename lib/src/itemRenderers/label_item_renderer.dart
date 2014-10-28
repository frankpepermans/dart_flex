part of dart_flex;

class LabelItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  bool _useHtmlText = false;

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

  static LabelItemRenderer construct() => new LabelItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _label = new RichText()
    ..percentWidth = 100.0
    ..autoSize = true
    ..className = 'item-renderer-label';
    
    _useHtmlText ? _label.richText = itemToLabel() : _label.text = itemToLabel();

    addComponent(_label);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
    if (_label != null) _useHtmlText ? _label.richText = itemToLabel() : _label.text = itemToLabel();;
  }
  
  String obtainValue() {
    dynamic value = _data;
    
    if (value != null) {
      if (_fields != null) {
        _fields.forEach(
          (Symbol subField) {
            if (value != null) value = value[subField];
          }
        );
      }
      
      if (value != null) value = (_field != null) ? value[_field] : value;
      
      if (_labelHandler != null) return _labelHandler(value) as String;
      
      return (value != null) ? value.toString() : '';
    }
    
    return '';
  }
  
  String itemToLabel() => obtainValue();
}

class HTMLLabelItemRenderer extends LabelItemRenderer {
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  HTMLLabelItemRenderer({String elementId: null}) : super(elementId: null) {
    _useHtmlText = true;
  }
  
  static HTMLLabelItemRenderer construct() => new HTMLLabelItemRenderer();
  
}