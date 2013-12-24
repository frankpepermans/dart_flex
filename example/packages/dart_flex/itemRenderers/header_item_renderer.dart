part of dart_flex;

class HeaderItemRenderer extends ItemRenderer {
  
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
  
  HeaderData get headerData => _data as HeaderData;

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
    ..percentHeight = 100.0
    ..onButtonClick.listen(_button_buttonClickHandler);

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
        new FrameworkEvent<HeaderData>(
            'buttonClick',
            relatedObject: headerData
        )
    );
  }
}

class HeaderData {
  
  final String label, labelLong, identifier;
  final Symbol field;
  
  const HeaderData(this.identifier, this.field, this.label, this.labelLong);
}