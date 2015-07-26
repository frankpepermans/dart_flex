part of dart_flex;

class BoundsContainer extends VGroup {

  VGroup _actualContainer;
  Spacer _top, _bottom, _left, _right;
  
  //---------------------------------
  // body
  //---------------------------------
  
  VGroup get body => _actualContainer;
  
  //---------------------------------
  // left
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onLeftChangedEvent = const EventHook<FrameworkEvent>('leftChanged');
  Stream<FrameworkEvent> get onLeftChanged => BoundsContainer.onLeftChangedEvent.forTarget(this);
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
  
  static const EventHook<FrameworkEvent> onRightChangedEvent = const EventHook<FrameworkEvent>('rightChanged');
  Stream<FrameworkEvent> get onRightChanged => BoundsContainer.onRightChangedEvent.forTarget(this);
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
  
  static const EventHook<FrameworkEvent> onTopChangedEvent = const EventHook<FrameworkEvent>('topChanged');
  Stream<FrameworkEvent> get onTopChanged => BoundsContainer.onTopChangedEvent.forTarget(this);
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
  
  static const EventHook<FrameworkEvent> onBottomChangedEvent = const EventHook<FrameworkEvent>('bottomChanged');
  Stream<FrameworkEvent> get onBottomChanged => BoundsContainer.onBottomChangedEvent.forTarget(this);
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

  BoundsContainer({String elementId: null}) : super(elementId: elementId, gap: 0) {
    _className = 'BoundsContainer';
    
    _actualContainer = new VGroup()
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