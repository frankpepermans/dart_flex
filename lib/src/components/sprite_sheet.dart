part of dart_flex;

class SpriteSheet extends Group {
  
  @event Stream<FrameworkEvent> onButtonClick;
  @event Stream<FrameworkEvent> onSourceChanged;
  @event Stream<FrameworkEvent> onIndexChanged;
  @event Stream<FrameworkEvent> onColumnSizeChanged;
  @event Stream<FrameworkEvent> onRowSizeChanged;
  @event Stream<FrameworkEvent> onSheetWidthChanged;
  @event Stream<FrameworkEvent> onSheetHeightChanged;

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

  //---------------------------------
  // source
  //---------------------------------
  
  String _source;

  String get source => _source;
  set source(String value) {
    if (value != _source) {
      _source = value;

      notify('sourceChanged');
      
      _updateIndex();
    }
  }

  //---------------------------------
  // index
  //---------------------------------

  int _index = 0;

  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notify('indexChanged');

      _updateIndex();
    }
  }

  //---------------------------------
  // columnSize
  //---------------------------------

  int _columnSize = 0;

  int get columnSize => _columnSize;
  set columnSize(int value) {
    if (value != _columnSize) {
      _columnSize = value;
      width = value;

      notify('columnSizeChanged');

      _updateIndex();
    }
  }

  //---------------------------------
  // rowSize
  //---------------------------------

  int _rowSize = 0;

  int get rowSize => _rowSize;
  set rowSize(int value) {
    if (value != _rowSize) {
      _rowSize = value;
      height = value;

      notify('rowSizeChanged');

      _updateIndex();
    }
  }

  //---------------------------------
  // sheetWidth
  //---------------------------------

  int _sheetWidth = 0;

  int get sheetWidth => _sheetWidth;
  set sheetWidth(int value) {
    if (value != _sheetWidth) {
      _sheetWidth = value;

      notify('sheetWidthChanged');

      _updateIndex();
    }
  }

  //---------------------------------
  // sheetHeight
  //---------------------------------

  int _sheetHeight = 0;

  int get sheetHeight => _sheetHeight;
  set sheetHeight(int value) {
    if (value != _sheetHeight) {
      _sheetHeight = value;

      notify('sheetHeightChanged');

      _updateIndex();
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SpriteSheet() : super() {
  	_className = 'sprite-sheet';
  	
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
      
      notify('buttonClick', event);
      
      new Timer(
        const Duration(milliseconds: 50),
        () => _allowClick = true
      );
    }
  }
}