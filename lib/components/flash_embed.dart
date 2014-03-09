part of dart_flex;

class FlashEmbed extends UIWrapper {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // source
  //---------------------------------

  static const EventHook<FrameworkEvent> onSourceChangedEvent = const EventHook<FrameworkEvent>('sourceChanged');
  Stream<FrameworkEvent> get onSourceChanged => FlashEmbed.onSourceChangedEvent.forTarget(this);
  String _source;

  String get source => _source;
  set source(String value) {
    if (value != _source) {
      _source = value;

      notify(
          new FrameworkEvent('sourceChanged')
      );

      later > _commitSource;
    }
  }

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  FlashEmbed({String elementId: null}) : super(elementId: elementId) {
    _className = 'FlashEmbed';
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    if (_control == null) {
      EmbedElement controlCast = new EmbedElement()
        ..type = 'application/x-shockwave-flash'
        ..src = _source;

      _setControl(controlCast);
    }

    super.createChildren();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _commitSource() {
    super.commitProperties();

    if (_control != null) {
      EmbedElement controlCast = _control as EmbedElement;

      controlCast.src = _source;
    }
  }
}

