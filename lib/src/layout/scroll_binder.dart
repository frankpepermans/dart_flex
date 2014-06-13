part of dart_flex;

class ScrollBinder {
  
  final Map<ListBase, Completer<ListRenderer>> _completers = <ListBase, Completer<ListRenderer>>{};
  
  void bind(List<ListBase> scrollViews, {bool bindHorizontally: false, bool bindVertically: false}) {
    final List<Future<ListRenderer>> waits = <Future<ListRenderer>>[];
    
    scrollViews.forEach(
      (ListBase L) => waits.add(_getScrollTarget(L))
    );
    
    Future.wait(waits).then(
      (List<ListRenderer> scrollTargets) {print('GO');
        if (bindHorizontally) {
          scrollTargets.forEach(
            (ListRenderer R) {
              R.onHeaderScrollPositionChanged.listen(
                (_) => scrollTargets.forEach(
                  (ListRenderer S) {
                    if (S != R) S.setScrollPosition(horizontalScrollValue: R.headerScrollPosition);
                  }
                )
              );
            }
          );
        }
        
        if (bindVertically) {
          scrollTargets.forEach(
            (ListRenderer R) {
              R.onListScrollPositionChanged.listen(
                (_) => scrollTargets.forEach(
                  (ListRenderer S) {
                    if (S != R) S.setScrollPosition(verticalScrollValue: R.scrollPosition);
                  }
                )
              );
            }
          );
        }
      }
    );
  }
  
  Future<ListRenderer> _getScrollTarget(ListBase view) {
    if (view is DataGrid) {
      if (view.list == null) {
        if (_completers.containsKey(view)) return _completers[view].future;
        
        _completers[view] = new Completer<ListRenderer>();
        
        view.onInitializationComplete.listen(
          (_) => _completers[view].complete(view.list)
        );
        
        return _completers[view].future;
      }
      
      return new Future<ListRenderer>.value(view.list);
    }
    
    return new Future<ListRenderer>.value(view);
  }
  
}