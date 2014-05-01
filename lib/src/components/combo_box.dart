part of dart_flex;

class ComboBox extends ListBase {
  
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
  // selectedIndex
  //---------------------------------

  set selectedIndex(int value) {
    _selectedIndex = value;

    notify(
      new FrameworkEvent<int>(
          'selectedIndexChanged',
          relatedObject: value
        )
    );

    later > _updateSelection;
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ComboBox() : super(elementId: null) {
    _className = 'ComboBox';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();

    _setControl(new SelectElement());
    
    _streamSubscriptionManager.add(
        'combo_box_controlChange', 
        _control.onChange.listen(_control_changeHandler)
    );
    
    _updateSelection();
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _updateElements() {
    if (_dataProvider == null || _control == null) return;
    
    dynamic element;
    int maxElementToStringLen = 6, i, len = _dataProvider.length;
    String elementToString, dividerLabel = '';
    OptionElement divider = new OptionElement(data: '', value: '-1');

    _removeAllElements();

    for (i=0; i<len; i++) {
      element = _dataProvider[i];

      elementToString = _createElement(element, i);
      
      if (elementToString.length > maxElementToStringLen) maxElementToStringLen = elementToString.length;
    }
    
    maxElementToStringLen += maxElementToStringLen ~/ 3;
    
    for (i=0; i<maxElementToStringLen; i++) dividerLabel = '${dividerLabel}-';
    
    divider.label = dividerLabel;

    _updateSelection();
  }

  String _createElement(dynamic item, int index) {
    final SelectElement controlCast = _control as SelectElement;
    String itemToString;

    if (_labelFunction != null) itemToString = _labelFunction(item) as String;
    else if (_field != null) itemToString = (item as dynamic)[_field];
    else itemToString = item.toString();
    
    if (itemToString == null) throw new ArgumentError('ComboBox items cannot be null $_labelFunction $_field $item');

    _control.children.add(
        new OptionElement(
            data: itemToString, value: index.toString()
        )
    );
    
    return itemToString;
  }
  
  void _updateAfterScrollPositionChanged() => _updateElements();

  void _updateSelection() {
    final SelectElement controlCast = _control as SelectElement;
    
    if (_selectedItem != null) controlCast.selectedIndex = _dataProvider.indexOf(_selectedItem);
    else controlCast.selectedIndex = _selectedIndex;
  }

  void _control_changeHandler(Event event) {
    SelectElement controlCast = _control as SelectElement;
    
    if (
        (controlCast.selectedOptions.length > 0) &&
        (controlCast.selectedIndex >= 0)
    ) {
      selectedIndex = controlCast.selectedIndex;
      selectedItem = _dataProvider[selectedIndex];
      
      controlCast.selectedOptions.forEach(
        (OptionElement element) => element.selected = false    
      );
    } else {
      selectedIndex = -1;
      selectedItem = null;
    }
    
    controlCast.selectedIndex = 0;
  }
}

