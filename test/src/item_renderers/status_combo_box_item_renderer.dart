part of dart_flex_test;

class StatusComboBoxItemRenderer extends ItemRenderer {
  
  ComboBox input;

  static StatusComboBoxItemRenderer construct() => new StatusComboBoxItemRenderer();
  
  void createChildren() {
    super.createChildren();
    
    input = new ComboBox()
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..dataProvider = new ObservableList.from(const <String>['complete!', 'open'])
    ..onSelectedItemChanged.listen(_input_onSelectedItemChanged);

    addComponent(input);
  }
  
  void invalidateData() {
    super.invalidateData();
    
    if (
        (input != null) &&
        (data != null) &&
        (field != null)
    ) input.selectedItem = data[field];
  }
  
  void _input_onSelectedItemChanged(FrameworkEvent<String> event) {
    if (data[field] != event.relatedObject) {
      data[field] = event.relatedObject;
      
      notify(
          new FrameworkEvent<dynamic>(
              'dataPropertyChanged',
              relatedObject: data
          )
      );
    }
  }
}