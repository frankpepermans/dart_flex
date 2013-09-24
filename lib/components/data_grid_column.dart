part of dart_flex;

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

  Map<String, String> _headerData = new Map<String, String>();

  Map<String, String> get headerData => _headerData;

  set headerData(Map<String, String> value) {
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
  // fields
  //---------------------------------

  List<String> _fields;

  List<String> get fields => _fields;
  set fields(List<String> value) {
    if (value != _fields) {
      _fields = value;
    }
  }

  //---------------------------------
  // columnItemRendererFactory
  //---------------------------------

  ClassFactory<IItemRenderer> _columnItemRendererFactory;

  ClassFactory<IItemRenderer> get columnItemRendererFactory => _columnItemRendererFactory;
  set columnItemRendererFactory(ClassFactory value) {
    if (value != _columnItemRendererFactory) {
      _columnItemRendererFactory = value;
    }
  }

  //---------------------------------
  // headerItemRendererFactory
  //---------------------------------

  ClassFactory<IItemRenderer> _headerItemRendererFactory;

  ClassFactory<IItemRenderer> get headerItemRendererFactory => _headerItemRendererFactory;
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
  // isActive
  //---------------------------------

  bool _isActive = true;

  bool get isActive => _isActive;
  set isActive(bool value) {
    if (value != _isActive) {
      _isActive = value;
    }
  }
  
  //---------------------------------
  // labelHandler
  //---------------------------------

  Function _labelHandler;

  Function get labelHandler => _labelHandler;
  set labelHandler(Function value) {
    if (value != _labelHandler) {
      _labelHandler = value;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  DataGridColumn();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
}

