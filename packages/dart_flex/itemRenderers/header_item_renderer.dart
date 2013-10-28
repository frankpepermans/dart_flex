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

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false);

  static HeaderItemRenderer construct() => new HeaderItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
    _button = new Button()
    ..percentWidth = 100.0
    ..percentHeight = 100.0
    ..onButtonClick.listen(
        (FrameworkEvent event) => notify(
            new FrameworkEvent<dynamic>(
                'buttonClick',
                relatedObject: data
            )
        )
    );

    invalidateData();

    addComponent(_button);
  }

  void invalidateData() {
    if (
       (_button != null) &&
       (data != null)
    ) _button.label = (data as HeaderData).label;
  }
}

class HeaderData {
  
  final String label, labelLong;
  final Symbol field;
  
  const HeaderData(this.field, this.label, this.labelLong);
}