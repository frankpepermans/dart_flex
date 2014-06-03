part of dart_flex;

abstract class IViewStackElement implements IUIWrapper {
  
  //---------------------------------
  //
  // Events
  //
  //---------------------------------
  
  Stream<FrameworkEvent> get onRequestViewChange;

}

class ViewStack extends Group {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  bool _isScrollPolicyInvalid = false;
  int _previousIndex = -1, _currentIndex = -1;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent<ViewStackElementData>> onViewChangedEvent = const EventHook<FrameworkEvent<ViewStackElementData>>('viewChanged');
  Stream<FrameworkEvent<ViewStackElementData>> get onViewChanged => ViewStack.onViewChangedEvent.forTarget(this);
  
  //---------------------------------
  // registeredViews
  //---------------------------------
  
  List<ViewStackElementData> _registeredViews = new List<ViewStackElementData>();
  
  List<ViewStackElementData> get registeredViews => _registeredViews;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ViewStack({String elementId: null}) : super(elementId: elementId) {
  	_className = 'ViewStack';
  	
  	layout = new AbsoluteLayout();
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void updateLayout() {
    super.updateLayout();
    
    if (_currentIndex >= 0) {
      final ViewStackElementData currentData = _registeredViews[_currentIndex];
      
      currentData.element.width = width;
      currentData.element.height = height;
    }
    
    if (_previousIndex >= 0) {
      final ViewStackElementData previousData = _registeredViews[_previousIndex];
      
      previousData.element.width = width;
      previousData.element.height = height;
    }
  }
  
  void addView(String uniqueId, IViewStackElement element) {
    ViewStackElementData viewStackElement = _registeredViews.firstWhere(
      (ViewStackElementData data) => (data.uniqueId == uniqueId),
      orElse: () => null
    );
    
    if (viewStackElement == null && element != null) {
      viewStackElement = new ViewStackElementData(element, uniqueId);
      
      element.streamSubscriptionManager.add(
          'view_stack_elementRequestViewChange', 
          element.onRequestViewChange.listen(_viewStackElement_requestViewChangeHandler)
      );
      
      _registeredViews.add(viewStackElement);
    }
  }
  
  bool show(String uniqueId) {
    final ViewStackElementData currentData = _registeredViews.firstWhere(
      (ViewStackElementData D) => (D.uniqueId == uniqueId),
      orElse: () => null
    );
    
    _previousIndex = _currentIndex;
    _currentIndex = _registeredViews.indexOf(currentData);
    
    if (_currentIndex == _previousIndex) return false;
    
    final ViewStackElementData previousData = (_previousIndex >= 0) ? _registeredViews[_previousIndex] : null;
    final int animationDirection = _getAnimationDirection();
    
    if (animationDirection == 0) return false;
    
    if (currentData.element.x == 0) currentData.element.x = -width * animationDirection;
    currentData.element.y = 0;
    
    new Timer(const Duration(milliseconds: 100), () => currentData.element.x = 0);
    
    addComponent(currentData.element);
    
    if (previousData != null) {
      previousData.element.y = 0;
      
      addComponent(previousData.element);
      
      new Timer(const Duration(milliseconds: 100), () => previousData.element.x = width * animationDirection);
    }
    
    int i = 0;
    
    _registeredViews.forEach(
      (ViewStackElementData D) {
        D.element.visible = (i == _previousIndex || i == _currentIndex);
        
        i++;
      }
    );
    
    invalidateLayout();
    
    notify(
      new FrameworkEvent<ViewStackElementData>('viewChanged', relatedObject: currentData)    
    );
    
    return true;
  }
  
  bool removeView(String uniqueId) {
    ViewStackElementData viewStackElementData = _registeredViews.firstWhere(
      (ViewStackElementData data) => (data.uniqueId == uniqueId),
      orElse: () => null
    );
    
    if (viewStackElementData != null) {
      removeComponent(viewStackElementData.element, flush: false);
      
      _currentIndex = -1;
      
      return _registeredViews.remove(viewStackElementData);
    }
    
    return false;
  }
  
  void removeAllViews() {
    int i = _registeredViews.length;
    
    while (i > 0) removeView(_registeredViews[--i].uniqueId);
    
    _currentIndex = _previousIndex = -1;
    
    updateLayout();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  int _getAnimationDirection() {
    if ((_currentIndex == -1) || (_currentIndex == _previousIndex)) return 0;
    
    return (_currentIndex < _previousIndex) ? 1 : -1;
  }
  
  void _viewStackElement_requestViewChangeHandler(ViewStackEvent event) {
    if (event.namedView != null) {
      show(event.namedView);
    } else if (event.sequentialView > 0) {
      final int len = _registeredViews.length;
      ViewStackElementData requestedElement;
      int requestedIndex;
      
      switch (event.sequentialView) {
        case ViewStackEvent.REQUEST_PREVIOUS_VIEW : requestedIndex = _currentIndex - 1;   break;
        case ViewStackEvent.REQUEST_NEXT_VIEW :     requestedIndex = _currentIndex + 1;   break;
        case ViewStackEvent.REQUEST_FIRST_VIEW :    requestedIndex = 0;                   break;
        case ViewStackEvent.REQUEST_LAST_VIEW :     requestedIndex = len - 1;             break;
      }
      
      requestedIndex = (requestedIndex < 0) ? (len - 1) : (requestedIndex >= len) ? 0 : requestedIndex;
      
      requestedElement = _registeredViews[requestedIndex];
      
      show(requestedElement.uniqueId);
    }
  }
}

class ViewStackElementData {
  
  final IUIWrapper element;
  final String uniqueId;
  
  ViewStackElementData(this.element, this.uniqueId);
  
}