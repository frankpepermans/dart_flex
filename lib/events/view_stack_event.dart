part of dartflex;

class ViewStackEvent extends FrameworkEvent {
  
  //-----------------------------------
  //
  // Public properties
  //
  //-----------------------------------

  //-----------------------------------
  // namedView
  //-----------------------------------

  String _namedView;

  String get namedView => _namedView;

  //-----------------------------------
  // sequentialView
  //-----------------------------------

  int _sequentialView;

  int get sequentialView => _sequentialView;

  //-----------------------------------
  //
  // Factories
  //
  //-----------------------------------
  
  ViewStackEvent.construct(String ident, String type, {Object relatedObject: null, String namedView: null, int sequentialView: -1}) : 
  super.construct('ViewStackEvent', type, relatedObject: relatedObject) {
    _namedView = namedView;
    _sequentialView = sequentialView;
  }

  factory ViewStackEvent(String type, {Object relatedObject: null, String namedView: null, int sequentialView: -1}) {
    return new ViewStackEvent.construct('ViewStackEvent', type, relatedObject: relatedObject, namedView: namedView, sequentialView: sequentialView);
  }

  static const String REQUEST_VIEW_CHANGE = 'requestViewChange';
  
  static const int REQUEST_PREVIOUS_VIEW = 1;
  static const int REQUEST_NEXT_VIEW = 2;
  static const int REQUEST_FIRST_VIEW = 3;
  static const int REQUEST_LAST_VIEW = 4;
}
