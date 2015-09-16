part of dart_flex;

class DataGridColumn extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent> onWidthChanged;
  @event Stream<FrameworkEvent> onPercentWidthChanged;
  @event Stream<FrameworkEvent> onMinWidthChanged;
  @event Stream<FrameworkEvent> onHeaderDataChanged;
  @event Stream<FrameworkEvent> onFieldChanged;
  @event Stream<FrameworkEvent> onFieldsChanged;
  @event Stream<FrameworkEvent> onColumnItemRendererFactoryChanged;
  @event Stream<FrameworkEvent> onHeaderItemRendererFactoryChanged;
  @event Stream<FrameworkEvent> onPropertyChanged;
  @event Stream<FrameworkEvent> onIsActiveChanged;
  @event Stream<FrameworkEvent> onIsVisibleChanged;
  @event Stream<FrameworkEvent> onLabelHandlerChanged;
  @event Stream<FrameworkEvent> onCssClassesChanged;

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
      
      notify('widthChanged');
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
      
      notify('percentWidthChanged');
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
      
      notify('minWidthChanged');
    }
  }

  //---------------------------------
  // headerData
  //---------------------------------

  HeaderData _headerData;

  HeaderData get headerData => _headerData;

  set headerData(HeaderData value) {
    if (value != _headerData) {
      _headerData = value;
      
      notify('headerDataChanged');
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
      
      notify('fieldChanged');
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
      
      notify('fieldsChanged');
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
      
      notify('columnItemRendererFactoryChanged');
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
      
      notify('headerItemRendererFactoryChanged');
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
      
      notify('propertyChanged');
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
      
      notify('isActiveChanged');
    }
  }
  
  //---------------------------------
  // isVisible
  //---------------------------------

  bool _isVisible = true;

  bool get isVisible => _isVisible;
  set isVisible(bool value) {
    if (value != _isVisible) {
      _isVisible = value;
      
      notify('isVisibleChanged');
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
      
      notify('labelHandlerChanged');
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
      
      notify('cssClassesChanged');
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
  
  dynamic getItemRendererData(dynamic data, int index) => data;
  
  String toString() => '$_property => $_headerData';
}

