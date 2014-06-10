part of dart_flex;

class ScrollBinder {
  
  void bind(ListBase scrollViewA, ListBase scrollViewB, String scrollPolicy) {
    Future.wait([_getScrollTarget(scrollViewA), _getScrollTarget(scrollViewB)]).then(
      (List<ListRenderer> scrollTargets) {
        final ListRenderer scrollTargetA = scrollTargets.first;
        final ListRenderer scrollTargetB = scrollTargets.last;
        
        scrollTargetA.onListScrollPositionChanged.listen(
          (_) => scrollTargetB.scrollPosition = scrollTargetA.scrollPosition
        );
        
        scrollTargetA.onHeaderScrollPositionChanged.listen(
          (_) => scrollTargetB.headerScrollPosition = scrollTargetA.headerScrollPosition
        );
        
        scrollTargetB.onListScrollPositionChanged.listen(
          (_) => scrollTargetA.scrollPosition = scrollTargetB.scrollPosition
        );
        
        scrollTargetB.onHeaderScrollPositionChanged.listen(
          (_) => scrollTargetA.headerScrollPosition = scrollTargetB.headerScrollPosition
        );
      }
    );
  }
  
  Future<ListRenderer> _getScrollTarget(ListBase view) {
    if (view is DataGrid) {
      if (view.list == null) {
        final Completer<ListRenderer> completer = new Completer<ListRenderer>();
        
        view.onControlChanged.listen(
          (_) => completer.complete(view.list)
        );
      } else return new Future<ListRenderer>.value(view.list);
    }
    
    return new Future<ListRenderer>.value(view);
  }
  
}