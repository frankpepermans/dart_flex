part of dartflex;

class HeaderItemRenderer extends ItemRenderer {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  Button _button;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false) {
  }

  static HeaderItemRenderer construct() {
    return new HeaderItemRenderer();
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  void createChildren() {
    _button = new Button()
    ..percentWidth = 100.0
    ..percentHeight = 100.0;

    if (data != null) {
      _button.label = data['label'];
    }

    _button.onButtonClick.listen(
        (FrameworkEvent event) => notify(
            new FrameworkEvent(
                'buttonClick',
                relatedObject: data
            )
        )
    );

    addComponent(_button);
  }

  void invalidateData() {
    if (
       (_button != null) &&
       (data != null)
    ) {
      _button.label = data['label'];
    }
  }
}