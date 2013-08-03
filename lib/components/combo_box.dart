part of dartflex;

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
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    super._createChildren();

    _setControl(new SelectElement());

    _control.onChange.listen(_control_changeHandler);
  }

  void _createElement(Object item, int index) {
    String itemToString;

    if (_labelFunction != null) {
      itemToString = _labelFunction(item);
    } else {
      itemToString = item.toString();
    }

    _control.children.add(
        new OptionElement(
            itemToString, index.toString()
        )
    );
  }

  void _updateSelection() {
    SelectElement controlCast = _control as SelectElement;
    
    if (_selectedItem != null) {
      controlCast.selectedIndex = _dataProvider.indexOf(_selectedItem);
    } else {
      controlCast.selectedIndex = _selectedIndex;
    }
  }

  void _control_changeHandler(Event event) {
    SelectElement controlCast = _control as SelectElement;

    if (controlCast.selectedOptions.length > 0) {
      selectedIndex = controlCast.selectedIndex;
      selectedItem = _dataProvider[controlCast.selectedIndex];
    } else {
      selectedIndex = -1;
      selectedItem = null;
    }
  }
}

