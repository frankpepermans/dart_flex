part of dart_flex_test;

class DateItemRenderer extends ItemRenderer {
  
  EditableDate input;

  static DateItemRenderer construct() => new DateItemRenderer();
  
  void createChildren() {
    super.createChildren();
    
    input = new EditableDate()
    ..percentWidth = 100.0
    ..autoSize = true
    ..onDataFinalized.listen(_input_dataChangedHandler);

    addComponent(input);
  }
  
  void invalidateData() {
    super.invalidateData();
    
    if (
        (input != null) &&
        (data != null) &&
        (field != null)
    ) input.data = data[field];
  }
  
  void _input_dataChangedHandler(FrameworkEvent event) {
    data[field] = input.data;
  }
}