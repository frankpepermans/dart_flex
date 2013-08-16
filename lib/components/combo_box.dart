part of dart_flex;

class ComboBox extends ListBase {

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
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // selectedIndex
  //---------------------------------

  set selectedIndex(int value) {
    _selectedIndex = value;

    notify(
      new FrameworkEvent(
          'selectedIndexChanged',
          relatedObject: value
        )
    );

    later > _updateSelection;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    super._createChildren();

    _setControl(new SelectElement());

    _control.onChange.listen(_control_changeHandler);
    
    _updateSelection();
  }
  
  void _updateElements() {
    if (_dataProvider == null) {
      return;
    }
    
    Object element;
    int maxElementToStringLen = 6;
    String elementToString, dividerLabel = '';
    OptionElement divider = new OptionElement('', '-1');
    int len = _dataProvider.length;
    int i;

    _removeAllElements();
    
    _control.children.add(
        new OptionElement(
            '', '-1'
        )
    );
    
    _control.children.add(divider);

    for (i=0; i<len; i++) {
      element = _dataProvider[i];

      elementToString = _createElement(element, i);
      
      if (elementToString.length > maxElementToStringLen) maxElementToStringLen = elementToString.length;
    }
    
    maxElementToStringLen += maxElementToStringLen ~/ 3;
    
    for (i=0; i<maxElementToStringLen; i++) {
      dividerLabel = '${dividerLabel}-';
    }
    
    divider.label = dividerLabel;

    _updateSelection();
  }

  String _createElement(Object item, int index) {
    final SelectElement controlCast = _control as SelectElement;
    String itemToString;

    if (_labelFunction != null) {
      itemToString = _labelFunction(item);
    } else if (_labelField != null) {
      itemToString = (item as dynamic)[_labelField];
    } else {
      itemToString = item.toString();
    }

    _control.children.add(
        new OptionElement(
            itemToString, index.toString()
        )
    );
    
    return itemToString;
  }
  
  void _updateAfterScrollPositionChanged() => _updateElements();

  void _updateSelection() {
    final SelectElement controlCast = _control as SelectElement;
    
    if (_selectedItem != null) {
      controlCast.selectedIndex = _dataProvider.indexOf(_selectedItem);
    } else {
      controlCast.selectedIndex = _selectedIndex;
    }
  }

  void _control_changeHandler(Event event) {
    SelectElement controlCast = _control as SelectElement;

    if (
        (controlCast.selectedOptions.length > 0) &&
        (controlCast.selectedIndex > 1)
    ) {
      selectedIndex = controlCast.selectedIndex - 2;
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

