part of dart_flex;

class BoundsContainer extends VGroup {

  Group _actualContainer;
  Spacer _top, _bottom, _left, _right;
  String _orientation;
  
  @event Stream<FrameworkEvent> onLeftChanged;
  @event Stream<FrameworkEvent> onRightChanged;
  @event Stream<FrameworkEvent> onTopChanged;
  @event Stream<FrameworkEvent> onBottomChanged;
  
  //---------------------------------
  // body
  //---------------------------------
  
  Group get body => _actualContainer;
  
  //---------------------------------
  // left
  //---------------------------------
  
  int _leftBounds = 0;
  
  int get left => _leftBounds;
  set left(int value) {
    if (value != _leftBounds) {
      _leftBounds = value;
      
      invalidateProperties();
  
      notify(
        new FrameworkEvent(
          'leftChanged'
        )
      );
    }
  }
  
  //---------------------------------
  // right
  //---------------------------------
  
  int _rightBounds = 0;
  
  int get right => _rightBounds;
  set right(int value) {
    if (value != _rightBounds) {
      _rightBounds = value;
      
      invalidateProperties();
  
      notify(
        new FrameworkEvent(
          'rightChanged'
        )
      );
    }
  }
  
  //---------------------------------
  // top
  //---------------------------------
  
  int _topBounds = 0;
  
  int get top => _topBounds;
  set top(int value) {
    if (value != _topBounds) {
      _topBounds = value;
      
      invalidateProperties();
  
      notify(
        new FrameworkEvent(
          'topChanged'
        )
      );
    }
  }
  
  //---------------------------------
  // bottom
  //---------------------------------
  
  int _bottomBounds = 0;
  
  int get bottom => _bottomBounds;
  set bottom(int value) {
    if (value != _bottomBounds) {
      _bottomBounds = value;
      
      invalidateProperties();
  
      notify(
        new FrameworkEvent(
          'bottomChanged'
        )
      );
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  BoundsContainer({String elementId: null, String orientation: 'vertical'}) : super(elementId: elementId, gap: 0) {
    _className = 'BoundsContainer';
    _orientation = orientation;
    
    if (_orientation == 'vertical') _actualContainer = new VGroup()
      ..cssClasses = const <String>['bounds-container-body']
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    else _actualContainer = new HGroup()
    ..cssClasses = const <String>['bounds-container-body']
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

  @override
  void createChildren() {
    super.createChildren();
    
    _top = new Spacer()
      ..percentWidth = 100.0;

    _bottom = new Spacer()
      ..percentWidth = 100.0;

    _left = new Spacer()
      ..percentHeight = 100.0;

    _right = new Spacer()
      ..percentHeight = 100.0;

    final HGroup hgroup = new HGroup()
      ..gap = 0
      ..percentWidth = 100.0
      ..percentHeight = 100.0;

    hgroup.addComponent(_left);
    hgroup.addComponent(_actualContainer);
    hgroup.addComponent(_right);

    addComponent(_top);
    addComponent(hgroup);
    addComponent(_bottom);
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    if (_left != null) {
      _left.width = _leftBounds;
      _left.visible = _left.includeInLayout = (_leftBounds > 0);
    }
    
    if (_right != null) {
      _right.width = _rightBounds;
      _right.visible = _right.includeInLayout = (_rightBounds > 0);
    }
    
    if (_top != null) {
      _top.height = _topBounds;
      _top.visible = _top.includeInLayout = (_topBounds > 0);
    }
    
    if (_bottom != null) {
      _bottom.height = _bottomBounds;
      _bottom.visible = _bottom.includeInLayout = (_bottomBounds > 0);
    }
  }

}