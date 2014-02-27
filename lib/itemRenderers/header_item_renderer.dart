part of dart_flex;

abstract class IHeaderItemRenderer extends IItemRenderer {
  
  Stream<FrameworkEvent> get onButtonClick;
  
  bool isSortedAsc;
  
  IHeaderData get headerData;
  
}

class HeaderItemRenderer extends ItemRenderer implements IHeaderItemRenderer {
  
  static const EventHook<FrameworkEvent> onButtonClickEvent = const EventHook<FrameworkEvent>('buttonClick');
  Stream<FrameworkEvent> get onButtonClick => HeaderItemRenderer.onButtonClickEvent.forTarget(this);

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
  
  bool isSortedAsc = true;
  
  IHeaderData get headerData => _data as IHeaderData;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false);

  static HeaderItemRenderer construct() => new HeaderItemRenderer();

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
}

class DynamicHeaderData implements IHeaderData {
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data;
  
  const DynamicHeaderData(this.identifier, this.field, this.label, this.labelLong, this.data);
}