part of dart_flex;

abstract class ComponentLayout {
  
  Stream<FrameworkEvent> get onXChanged;
  Stream<FrameworkEvent> get onYChanged;
  Stream<FrameworkEvent> get onWidthChanged;
  Stream<FrameworkEvent> get onPercentWidthChanged;
  Stream<FrameworkEvent> get onLayoutWidthChanged;
  Stream<FrameworkEvent> get onHeightChanged;
  Stream<FrameworkEvent> get onPercentHeightChanged;
  Stream<FrameworkEvent> get onLayoutHeightChanged;
  Stream<FrameworkEvent> get onPaddingLeftChanged;
  Stream<FrameworkEvent> get onPaddingRightChanged;
  Stream<FrameworkEvent> get onPaddingTopChanged;
  Stream<FrameworkEvent> get onPaddingBottomChanged;
  Stream<FrameworkEvent> get onLayoutChanged;
  
  bool get includeInLayout;
  set includeInLayout(bool value);
  
  bool get allowLayoutUpdate;
  set allowLayoutUpdate(bool value);

  bool get autoSize;
  set autoSize(bool value);
  
  int get x;
  set x(int value);

  int get y;
  set y(int value);

  int get width;
  int get layoutWidth;
  set width(int value);

  double get percentWidth;
  set percentWidth(double value);

  int get height;
  int get layoutHeight;
  set height(int value);

  double get percentHeight;
  set percentHeight(double value);

  int get paddingLeft;
  set paddingLeft(int value);

  int get paddingRight;
  set paddingRight(int value);

  int get paddingTop;
  set paddingTop(int value);

  int get paddingBottom;
  set paddingBottom(int value);
  
  ILayout get layout;
  set layout(ILayout value);
  
}

abstract class BaseComponentMixin implements ComponentLayout, ComponentLifeCycle, EventDispatcher {
  
  @event Stream<FrameworkEvent> onIncludeInLayoutChanged;
  @event Stream<FrameworkEvent> onAllowLayoutUpdateChanged;
  @event Stream<FrameworkEvent> onAutoSizeChanged;
  @event Stream<FrameworkEvent> onXChanged;
  @event Stream<FrameworkEvent> onYChanged;
  @event Stream<FrameworkEvent> onLayoutWidthChanged;
  @event Stream<FrameworkEvent> onWidthChanged;
  @event Stream<FrameworkEvent> onPercentWidthChanged;
  @event Stream<FrameworkEvent> onLayoutHeightChanged;
  @event Stream<FrameworkEvent> onHeightChanged;
  @event Stream<FrameworkEvent> onPercentHeightChanged;
  @event Stream<FrameworkEvent> onPaddingLeftChanged;
  @event Stream<FrameworkEvent> onPaddingRightChanged;
  @event Stream<FrameworkEvent> onPaddingTopChanged;
  @event Stream<FrameworkEvent> onPaddingBottomChanged;
  @event Stream<FrameworkEvent> onLayoutChanged;
  
  //---------------------------------
  // includeInLayout
  //---------------------------------

  bool _includeInLayout = true;

  bool get includeInLayout => _includeInLayout;

  set includeInLayout(bool value) {
    if (value != _includeInLayout) {
      _includeInLayout = value;

      notify(
        new FrameworkEvent('includeInLayoutChanged')
      );

      invalidateOwnerProperties();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // allowLayoutUpdate
  //---------------------------------

  bool _allowLayoutUpdate = true;

  bool get allowLayoutUpdate => _allowLayoutUpdate;

  set allowLayoutUpdate(bool value) {
    if (value != _allowLayoutUpdate) {
      _allowLayoutUpdate = value;

      notify(
        new FrameworkEvent('allowLayoutUpdateChanged')
      );

      invalidateOwnerProperties();

      invalidateProperties();
    }
  }

  //---------------------------------
  // autoSize
  //---------------------------------

  bool _autoSize = true;

  bool get autoSize => _autoSize;

  set autoSize(bool value) {
    if (value != _autoSize) {
      _autoSize = value;

      notify(
        new FrameworkEvent('autoSizeChanged')
      );

      invalidateOwnerProperties();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // x
  //---------------------------------
  
  int _x = 0;

  int get x => _x;

  set x(int value) {
    if (value != _x) {
      _x = value;

      notify(
        new FrameworkEvent('xChanged')
      );

      _updateControl(1);
    }
  }

  //---------------------------------
  // y
  //---------------------------------
  
  int _y = 0;

  int get y => _y;

  set y(int value) {
    if (value != _y) {
      _y = value;

      notify(
        new FrameworkEvent('yChanged')
      );

      _updateControl(2);
    }
  }

  //---------------------------------
  // width
  //---------------------------------
  
  int _width = 0;

  int get width => _width;
  int get layoutWidth => (_layout != null) ? _layout.layoutWidth : 0;

  set width(int value) {
    if (value != _width) {
      _width = value;

      notify(
        new FrameworkEvent('widthChanged')
      );

      _updateControl(3);

      invalidateProperties();
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

      notify(
        new FrameworkEvent('percentWidthChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // height
  //---------------------------------
  
  int _height = 0;

  int get height => _height;
  int get layoutHeight => (_layout != null) ? _layout.layoutHeight : 0;

  set height(int value) {
    if (value != _height) {
      _height = value;

      notify(
        new FrameworkEvent('heightChanged')
      );

      _updateControl(4);

      invalidateProperties();
    }
  }

  //---------------------------------
  // percentHeight
  //---------------------------------

  double _percentHeight = 0.0;

  double get percentHeight => _percentHeight;

  set percentHeight(double value) {
    if (value != _percentHeight) {
      _percentHeight = value;

      notify(
        new FrameworkEvent('percentHeightChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingLeft
  //---------------------------------

  int _paddingLeft = 0;

  int get paddingLeft => _paddingLeft;

  set paddingLeft(int value) {
    if (value != _paddingLeft) {
      _paddingLeft = value;

      notify(
        new FrameworkEvent('paddingLeftChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingRight
  //---------------------------------

  int _paddingRight = 0;

  int get paddingRight => _paddingRight;

  set paddingRight(int value) {
    if (value != _paddingRight) {
      _paddingRight = value;

      notify(
        new FrameworkEvent('paddingRightChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingTop
  //---------------------------------

  int _paddingTop = 0;

  int get paddingTop => _paddingTop;

  set paddingTop(int value) {
    if (value != _paddingTop) {
      _paddingTop = value;

      notify(
        new FrameworkEvent('paddingTopChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // paddingBottom
  //---------------------------------

  int _paddingBottom = 0;

  int get paddingBottom => _paddingBottom;

  set paddingBottom(int value) {
    if (value != _paddingBottom) {
      _paddingBottom = value;

      notify(
        new FrameworkEvent('paddingBottomChanged')
      );

      invalidateProperties();
    }
  }

  //---------------------------------
  // layout
  //---------------------------------
  
  ILayout _layout;

  ILayout get layout => _layout;
  set layout(ILayout value) {
    if (value != _layout) {
      _layout = value;

      notify(
        new FrameworkEvent('layoutChanged')
      );

      invalidateProperties();
    }
  }
  
  void _updateControl(int type);
}