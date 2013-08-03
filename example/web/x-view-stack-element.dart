import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:dart_flex/dart_flex.dart';

class ViewStackElementComponent extends VGroup implements IViewStackElement {
  
  static const EventHook<ViewStackEvent> onRequestViewChangeEvent = const EventHook<ViewStackEvent>(ViewStackEvent.REQUEST_VIEW_CHANGE);
  Stream<ViewStackEvent> get onRequestViewChange => ViewStackElementComponent.onRequestViewChangeEvent.forTarget(this);
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // listName
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onListNameChangedEvent = const EventHook<FrameworkEvent>('listNameChanged');
  Stream<FrameworkEvent> get onListNameChanged => ViewStackElementComponent.onListNameChangedEvent.forTarget(this);
  
  String _listName;
  bool _isListNameInvalid = false;
  
  String get listName => _listName;
  set listName(String value) {
    if (_listName != value) {
      _listName = value;
      _isListNameInvalid = true;
      
      notify(
          new FrameworkEvent(
            'listNameChanged'    
          )
      );
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // header
  //---------------------------------
  
  Header _header;
  
  Header get header => _header;
  
  //---------------------------------
  // homeButton
  //---------------------------------
  
  Button _homeButton;
  
  Button get homeButton => _homeButton;
  
  //---------------------------------
  // settingsButton
  //---------------------------------
  
  Button _settingsButton;
  
  Button get settingsButton => _settingsButton;
  
  //---------------------------------
  // grid
  //---------------------------------
  
  DataGrid _grid;
  
  DataGrid get grid => _grid;
  
  //---------------------------------
  // footer
  //---------------------------------
  
  Footer _footer;
  
  Footer get footer => _footer;
  
  //---------------------------------
  // toggleRowSizeButton
  //---------------------------------
  
  Button _toggleRowSizeButton;
  
  Button get toggleRowSizeButton => _toggleRowSizeButton;
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ViewStackElementComponent() : super(elementId: null, gap: 0) {
    onInitializationComplete.listen(_initializationCompleteHandler);
    
    _initHeader();
  }
  
  void _init() {
    _initFooter();
  }
  
  void _initHeader() {
    _header = new Header()
    ..percentWidth = 100.0
    ..height = 40
    ..label = _listName;
    
    _homeButton = new Button()
    ..inheritsDefaultCSS = false
    ..width = 32
    ..height = 32
    ..cssClasses = ['backButton'];
    
    _settingsButton = new Button()
    ..inheritsDefaultCSS = false
    ..width = 32
    ..height = 32
    ..cssClasses = ['options'];
    
    _header.leftSideItems.add(_homeButton);
    _header.rightSideItems.add(_settingsButton);
    
    addComponent(_header, prepend: true);
  }
  
  void _initFooter() {
    _footer = new Footer()
    ..percentWidth = 100.0
    ..height = 40;
    
    addComponent(_footer);
  }
  
  void invalidateProperties() {
    super.invalidateProperties();
    
    later > _commitProperties;
  }
  
  void _commitProperties() {
    if (_isListNameInvalid) {
      _isListNameInvalid = false;
      
      if (_header != null) {
        _header.label = _listName;
      }
    }
  }
  
  void _requestView({String namedView: null, int sequentialView: -1}) {
    notify(
        new ViewStackEvent(
            ViewStackEvent.REQUEST_VIEW_CHANGE,
            relatedObject: this,
            namedView: namedView,
            sequentialView: sequentialView
        )
    );
  }
  
  void _initializationCompleteHandler(FrameworkEvent event) {
    _init();
  }
}