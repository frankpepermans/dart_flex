part of dartflex;

class DataGridColumn {

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
  // width
  //---------------------------------

  int _width = 0;

  int get width => _width;

  set width(int value) {
    if (value != _width) {
      _width = value;
    }
  }

  //---------------------------------
  // percentWidth
  //---------------------------------

  double _percentWidth = 0.0;

  double get percentWidth => _percentWidth;

  set percentWidth(double value) {
    if (value != _percentWidth) {
      _percentWidth = value;
    }
  }

  //---------------------------------
  // minWidth
  //---------------------------------

  int _minWidth = 0;

  int get minWidth => _minWidth;

  set minWidth(int value) {
    if (value != _minWidth) {
      _minWidth = value;
    }
  }

  //---------------------------------
  // headerData
  //---------------------------------

  Object _headerData = 0;

  Object get headerData => _headerData;

  set headerData(Object value) {
    if (value != _headerData) {
      _headerData = value;
    }
  }
  
  //---------------------------------
  // field
  //---------------------------------

  String _field;

  String get field => _field;
  set field(String value) {
    if (value != _field) {
      _field = value;
    }
  }

  //---------------------------------
  // columnItemRendererFactory
  //---------------------------------

  ClassFactory _columnItemRendererFactory;

  ClassFactory get columnItemRendererFactory => _columnItemRendererFactory;
  set columnItemRendererFactory(ClassFactory value) {
    if (value != _columnItemRendererFactory) {
      _columnItemRendererFactory = value;
    }
  }

  //---------------------------------
  // headerItemRendererFactory
  //---------------------------------

  ClassFactory _headerItemRendererFactory;

  ClassFactory get headerItemRendererFactory => _headerItemRendererFactory;
  set headerItemRendererFactory(ClassFactory value) {
    if (value != _headerItemRendererFactory) {
      _headerItemRendererFactory = value;
    }
  }

  //---------------------------------
  // property
  //---------------------------------

  String _property;

  String get property => _property;
  set property(String value) {
    if (value != _property) {
      _property = value;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  DataGridColumn() {
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
}

