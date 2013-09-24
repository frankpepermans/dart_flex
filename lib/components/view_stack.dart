part of dart_flex;

abstract class IViewStackElement implements IUIWrapper {
  
  //---------------------------------
  //
  // Events
  //
  //---------------------------------
  
  Stream<FrameworkEvent> get onRequestViewChange;

}

class ViewStack extends UIWrapper {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  bool _isScrollPolicyInvalid = false;
  int _xOffset = 0;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // container
  //---------------------------------
  
  Group _container;
  
  Group get container => _container;
  
  //---------------------------------
  // registeredViews
  //---------------------------------
  
  List<ViewStackElementData> _registeredViews = new List<ViewStackElementData>();
  
  List<ViewStackElementData> get registeredViews => _registeredViews;
  
  //---------------------------------
  // activeView
  //---------------------------------
  
  String get activeView => (_activeViewStackElement != null) ? _activeViewStackElement.uniqueId : null;
  
  //---------------------------------
  // activeViewStackElement
  //---------------------------------
  
  ViewStackElementData _activeViewStackElement;
  ViewStackElementData _inactiveViewStackElement;
  
  ViewStackElementData get activeViewStackElement => _activeViewStackElement;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ViewStack({String elementId: null}) : super(elementId: elementId) {
  	_className = 'ViewStack';
  	
  	//_createChildren();
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  /*void scanForDOMChildren() {
    final int len = $dom_childNodes.length;
    Node child;
    bool hasEncounteredFirstElement = false;
    int i;
    
    for (i=0; i<len; i++) {
      child = $dom_childNodes[i];
      
      if (child is Element) {
        final Element childCast = child as Element;
        
        if (childCast.xtag is IViewStackElement) {
          final IViewStackElement childComponent = child.xtag as IViewStackElement;
          
          addView(childCast.id, childComponent);
          
          if (!hasEncounteredFirstElement) {
            hasEncounteredFirstElement = true;
            
            show(childCast.id);
          }
        }
      } 
    }
  }*/
  
  void addComponent(IUIWrapper element, {bool prepend: false}) {
    throw new ArgumentError('Please use addView() instead');
  }
  
  void addView(String uniqueId, IViewStackElement element) {
    ViewStackElementData viewStackElement;
    int i = _registeredViews.length;
    
    while (i > 0) {
      viewStackElement = _registeredViews[--i];
      
      if (viewStackElement.uniqueId == uniqueId) return;
    }
    
    viewStackElement = new ViewStackElementData()
    ..element = element
    ..uniqueId = uniqueId;
    
    element.onRequestViewChange.listen(_viewStackElement_requestViewChangeHandler);
    
    _registeredViews.add(viewStackElement);
  }
  
  bool show(String uniqueId) {
    if (_container == null) {
      onControlChanged.listen(
          (FrameworkEvent event) => show(uniqueId)
      );
    } else {
      ViewStackElementData viewStackElement;
      final int currentIndex = (_activeViewStackElement != null) ? _registeredViews.indexOf(_activeViewStackElement) : -1;
      int newIndex = -1;
      int i = _registeredViews.length;
      
      if (currentIndex == -1) _xOffset = 0;
      
      _reflowManager.invalidateCSS(_container._control, 'transition', 'left 0.5s ease-out');
      
      while (i > 0) {
        viewStackElement = _registeredViews[--i];
        
        if (viewStackElement.uniqueId == uniqueId) {
          newIndex = i;
          
          break;
        }
      }
      
      if (
          (currentIndex == newIndex) ||
          (newIndex == -1)
      ) {
        return false;
      }
      
      viewStackElement.element.visible = false;
      
      viewStackElement.element.preInitialize(this);
      
      if (currentIndex >= 0) {
        _inactiveViewStackElement = _activeViewStackElement;
        
        _inactiveViewStackElement.element.visible = false;
        
        if (newIndex > currentIndex) {
          --_xOffset;
        } else {
          ++_xOffset;
        }
      }
      
      _activeViewStackElement = viewStackElement;
      
      _container.addComponent(viewStackElement.element);
      
      _updateLayout();
      
      _activeViewStackElement.element.visible = true;
      
      return true;
    }
    
    return false;
  }
  
  bool removeView(String uniqueId) {
    ViewStackElementData viewStackElement;
    int i = _registeredViews.length;
    
    while (i > 0) {
      viewStackElement = _registeredViews[--i];
      
      if (viewStackElement.uniqueId == uniqueId) {
        _container.removeComponent(viewStackElement.element);
        
        return _registeredViews.remove(viewStackElement);
      }
    }
    
    return false;
  }
  
  void removeAllViews() {
    int i = _registeredViews.length;
    
    while (i > 0) removeView(_registeredViews[--i].uniqueId);
    
    _xOffset = 0;
    
    _updateLayout();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    if (_control == null) {
      _setControl(new DivElement());
    }
    
    _layout = new AbsoluteLayout();
    
    _container = new Group()
    ..inheritsDefaultCSS = false
    ..cssClasses = ['_ViewStackSlider']
    .._layout = new AbsoluteLayout();
    
    _reflowManager.invalidateCSS(
        _container._control,
        'position',
        'absolute'
    );
    
    super.addComponent(_container);
    
    super._createChildren();
    
    notify(
        new FrameworkEvent(
            'controlChanged',
            relatedObject: _control
        )
    );
  }
  
  void _updateLayout() {
    super._updateLayout();
    
    if (_container != null) {
      _container.x = _xOffset * _width;
      _container.width = _registeredViews.length * _width;
      _container.height = _height;
    }

    if (_activeViewStackElement != null) {
      _activeViewStackElement.element.x = _xOffset * -_width;
      _activeViewStackElement.element.width = _width;
      _activeViewStackElement.element.height = _height;
    }
  }
  
  void _viewStackElement_requestViewChangeHandler(ViewStackEvent event) {
    if (event.namedView != null) {
      show(event.namedView);
    } else if (event.sequentialView > 0) {
      final int len = _registeredViews.length;
      final int index = _registeredViews.indexOf(_activeViewStackElement);
      ViewStackElementData requestedElement;
      int requestedIndex;
      
      switch (event.sequentialView) {
        case ViewStackEvent.REQUEST_PREVIOUS_VIEW : requestedIndex = index - 1;   break;
        case ViewStackEvent.REQUEST_NEXT_VIEW :     requestedIndex = index + 1;   break;
        case ViewStackEvent.REQUEST_FIRST_VIEW :    requestedIndex = 0;           break;
        case ViewStackEvent.REQUEST_LAST_VIEW :     requestedIndex = len - 1;     break;
      }
      
      requestedIndex = (requestedIndex < 0) ? (len - 1) : (requestedIndex >= len) ? 0 : requestedIndex;
      
      requestedElement = _registeredViews[requestedIndex];
      
      show(requestedElement.uniqueId);
    }
  }
}

class ViewStackElementData {
  
  IUIWrapper element;
  String uniqueId;
  
}