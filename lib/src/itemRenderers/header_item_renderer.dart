part of dart_flex;

typedef int SortHandler(dynamic a, dynamic b, DataGridColumn column, IHeaderData headerData);

abstract class IHeaderItemRenderer extends IItemRenderer {
  
  Event lastClickEvent;
  
  Stream<FrameworkEvent> get onButtonClick;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  IHeaderData get headerData;
  
}

class HeaderItemRenderer extends ItemRenderer implements IHeaderItemRenderer {
  
  @event Stream<FrameworkEvent> onButtonClick;

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  Button _button;
  
  Button get button => _button;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  Event lastClickEvent;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  IHeaderData get headerData => _data as IHeaderData;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null, SortHandler sortHandler}) : super(elementId: null, autoDrawBackground: false) {
    this.sortHandler = sortHandler;
  }

  static HeaderItemRenderer construct([SortHandler sortHandler= null]) => new HeaderItemRenderer(sortHandler: sortHandler);

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _button = new Button()
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
    
    _streamSubscriptionManager.add(
        'header_item_renderer_chainDataListChanges', 
        _button.onButtonClick.listen(_button_buttonClickHandler)
    );

    invalidateData();

    addComponent(_button);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
    if (
       (_button != null) &&
       (_data != null)
    ) _button.label = headerData.label;
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _button_buttonClickHandler(FrameworkEvent<dynamic> event) {
    lastClickEvent = _button.lastClickEvent;
    
    notify(
        new FrameworkEvent<IHeaderData>(
            'buttonClick',
            relatedObject: headerData
        )
    );
  }
}

abstract class IHeaderData {
  
  final String label = '', labelLong = '', identifier = '';
  final Symbol field = null;
  final dynamic data = null;
  
}

class HeaderData implements IHeaderData {
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data = null;
  
  const HeaderData(this.identifier, this.field, this.label, this.labelLong);
  
  static HeaderData createSimple(String simpleName) => new HeaderData(simpleName, new Symbol(simpleName), simpleName, simpleName);
  
  String toString() => '$label : $field';
}

class DynamicHeaderData implements IHeaderData {
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data;
  
  const DynamicHeaderData(this.identifier, this.field, this.label, this.labelLong, this.data);
  
  static DynamicHeaderData createSimple(String simpleName, dynamic simpleData) => new DynamicHeaderData(simpleName, new Symbol(simpleName), simpleName, simpleName, simpleData);
  
  String toString() => '$label : $field';
}