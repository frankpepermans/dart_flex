part of dart_flex;

class ImageItemRenderer extends ItemRenderer {

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
  // image
  //---------------------------------
  
  Image _image;
  
  Image get image => _image;
  set image(Image value) => _image = value;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ImageItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false) {
    layout = new HorizontalLayout();
  }

  static ImageItemRenderer construct() => new ImageItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _image = new Image()
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..source = itemToLabel()
    ..className = 'item-renderer-image';

    addComponent(_image);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
    if (_image != null) _image.source = itemToLabel();
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