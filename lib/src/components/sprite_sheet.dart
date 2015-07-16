part of dart_flex;

class SpriteSheet extends Group {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  bool _allowClick = true;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent<MouseEvent>> onButtonClickEvent = const EventHook<FrameworkEvent<MouseEvent>>('buttonClick');
  Stream<FrameworkEvent<MouseEvent>> get onButtonClick => SpriteSheet.onButtonClickEvent.forTarget(this);

  //---------------------------------
  // source
  //---------------------------------

  static const EventHook<FrameworkEvent> onSourceChangedEvent = const EventHook<FrameworkEvent>('sourceChanged');
  Stream<FrameworkEvent> get onSourceChanged => SpriteSheet.onSourceChangedEvent.forTarget(this);
  String _source;

  String get source => _source;
  set source(String value) {
    if (value != _source) {
      _source = value;

      notify(
        new FrameworkEvent(
          'sourceChanged'
        )
      );
      
      _updateIndex();
    }
  }

  //---------------------------------
  // index
  //---------------------------------

  static const EventHook<FrameworkEvent> onIndexChangedEvent = const EventHook<FrameworkEvent>('indexChanged');
  Stream<FrameworkEvent> get onIndexChanged => SpriteSheet.onIndexChangedEvent.forTarget(this);
  int _index = 0;

  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notify(
          new FrameworkEvent(
              'indexChanged'
          )
      );

      _updateIndex();
    }
  }

  //---------------------------------
  // columnSize
  //---------------------------------

  static const EventHook<FrameworkEvent> onColumnSizeChangedEvent = const EventHook<FrameworkEvent>('columnSizeChanged');
  Stream<FrameworkEvent> get onColumnSizeChanged => SpriteSheet.onColumnSizeChangedEvent.forTarget(this);
  int _columnSize = 0;

  int get columnSize => _columnSize;
  set columnSize(int value) {
    if (value != _columnSize) {
      _columnSize = value;
      width = value;

      notify(
          new FrameworkEvent(
              'columnSizeChanged'
          )
      );

      _updateIndex();
    }
  }

  //---------------------------------
  // rowSize
  //---------------------------------

  static const EventHook<FrameworkEvent> onRowSizeChangedEvent = const EventHook<FrameworkEvent>('rowSizeChanged');
  Stream<FrameworkEvent> get onRowSizeChanged => SpriteSheet.onRowSizeChangedEvent.forTarget(this);
  int _rowSize = 0;

  int get rowSize => _rowSize;
  set rowSize(int value) {
    if (value != _rowSize) {
      _rowSize = value;
      height = value;

      notify(
          new FrameworkEvent(
              'rowSizeChanged'
          )
      );

      _updateIndex();
    }
  }

  //---------------------------------
  // sheetWidth
  //---------------------------------

  static const EventHook<FrameworkEvent> onSheetWidthChangedEvent = const EventHook<FrameworkEvent>('sheetWidthChanged');
  Stream<FrameworkEvent> get onSheetWidthChanged => SpriteSheet.onSheetWidthChangedEvent.forTarget(this);
  int _sheetWidth = 0;

  int get sheetWidth => _sheetWidth;
  set sheetWidth(int value) {
    if (value != _sheetWidth) {
      _sheetWidth = value;

      notify(
          new FrameworkEvent(
              'sheetWidthChanged'
          )
      );

      _updateIndex();
    }
  }

  //---------------------------------
  // sheetHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onSheetHeightChangedEvent = const EventHook<FrameworkEvent>('sheetHeightChanged');
  Stream<FrameworkEvent> get onSheetHeightChanged => SpriteSheet.onSheetHeightChangedEvent.forTarget(this);
  int _sheetHeight = 0;

  int get sheetHeight => _sheetHeight;
  set sheetHeight(int value) {
    if (value != _sheetHeight) {
      _sheetHeight = value;

      notify(
          new FrameworkEvent(
              'sheetHeightChanged'
          )
      );

      _updateIndex();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SpriteSheet() : super() {
  	_className = 'SpriteSheet';
  	
  	onControlChanged.listen(
  	 (FrameworkEvent event) => _updateIndex()
  	);
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _streamSubscriptionManager.flushIdent('button_elementClick');
    
    _streamSubscriptionManager.add(
        'button_elementClick', 
        _control.onClick.listen(_propagateClick)
    );

    if (_source != null) _reflowManager.invalidateCSS(_control, 'background-image', 'url($_source)');
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _updateIndex() {
    if (
        (_control != null) &&
        (_sheetWidth > 0) &&
        (_sheetHeight > 0) &&
        (_columnSize > 0) &&
        (_rowSize > 0)
    ) {
      final String px = 'px';
      final int colsPerRow = _sheetWidth ~/ _columnSize;
      final int rows = _sheetHeight ~/ _rowSize;
      final int maxIndex = rows * colsPerRow;

      if (_index > maxIndex) throw new RangeError('index $_index out of range $maxIndex');
      
      final int column = _index % colsPerRow;
      final int row = _index ~/ colsPerRow;
      final int posX = (colsPerRow - column) * _columnSize;
      final int posY = row * _rowSize;

      _reflowManager.invalidateCSS(_control, 'background-position', '$posX$px $posY$px');
    }
  }
  
  void _propagateClick(MouseEvent event) {
    if (_allowClick) {
      _allowClick = false;
      
      notify(
          new FrameworkEvent<MouseEvent>(
              'buttonClick',
              relatedObject: event
          )
      );
      
      new Timer(
        const Duration(milliseconds: 50),
        () => _allowClick = true
      );
    }
  }
}