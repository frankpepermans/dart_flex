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

  IHeaderData _headerData;

  IHeaderData get headerData => _headerData;

  set headerData(IHeaderData value) {
    if (value != _headerData) {
      _headerData = value;
    }
  }
  
  //---------------------------------
  // field
  //---------------------------------

  Symbol _field;

  Symbol get field => _field;
  set field(Symbol value) {
    if (value != _field) {
      _field = value;
    }
  }
  
  //---------------------------------
  // fields
  //---------------------------------

  List<Symbol> _fields;

  List<Symbol> get fields => _fields;
  set fields(List<Symbol> value) {
    if (value != _fields) {
      _fields = value;
    }
  }

  //---------------------------------
  // columnItemRendererFactory
  //---------------------------------

  ItemRendererFactory<IItemRenderer> _columnItemRendererFactory;

  ItemRendererFactory<IItemRenderer> get columnItemRendererFactory => _columnItemRendererFactory;
  set columnItemRendererFactory(ItemRendererFactory value) {
    if (value != _columnItemRendererFactory) {
      _columnItemRendererFactory = value;
    }
  }

  //---------------------------------
  // headerItemRendererFactory
  //---------------------------------

  ItemRendererFactory<IHeaderItemRenderer> _headerItemRendererFactory;

  ItemRendererFactory<IHeaderItemRenderer> get headerItemRendererFactory => _headerItemRendererFactory;
  set headerItemRendererFactory(ItemRendererFactory<IHeaderItemRenderer> value) {
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
  // cssClasses
  //---------------------------------

  List<String> _cssClasses;

  List<String> get cssClasses => _cssClasses;
  set cssClasses(List<String> value) {
    if (value != _cssClasses) {
      _cssClasses = value;
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

