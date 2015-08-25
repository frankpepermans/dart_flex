part of dart_flex;

typedef int SortHandler(dynamic a, dynamic b, DataGridColumn column, IHeaderData headerData);

abstract class IHeaderItemRenderer<D extends IHeaderData> extends IItemRenderer<IHeaderData> {
  
  Event lastClickEvent;
  
  Stream<FrameworkEvent> get onButtonClick;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  IHeaderData get headerData;
  
}

class HeaderItemRenderer<D extends IHeaderData> extends ItemRenderer<IHeaderData> implements IHeaderItemRenderer {
  
  @event Stream<FrameworkEvent> onButtonClick;

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  Button _button;
  
  Button get button => _button;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  Event lastClickEvent;
  
  SortHandler sortHandler;
  
  bool isSortedAsc = true;
  
  IHeaderData get headerData => _data as IHeaderData;
  
  @override
  void set data(D value) {
    streamSubscriptionManager.flushIdent('highlight-listener');
    
    super.data = value;
    
    if (value != null) streamSubscriptionManager.add('highlight-listener', value.onHighlightedChanged.listen((_) => invalidateData()));
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  HeaderItemRenderer({String elementId: null, SortHandler sortHandler}) : super(elementId: null, autoDrawBackground: false) {
    this.sortHandler = sortHandler;
  }

  static HeaderItemRenderer construct([SortHandler sortHandler= null]) => new HeaderItemRenderer(sortHandler: sortHandler);

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    _button = new Button()
    ..percentWidth = 100.0
    ..percentHeight = 100.0;
    
    _streamSubscriptionManager.add(
        'header_item_renderer_chainDataListChanges', 
        _button.onButtonClick.listen(_button_buttonClickHandler)
    );

    invalidateData();

    addComponent(_button);
  }
  
  @override
  void invalidateData() {
    super.invalidateData();
    
    if (
       (_button != null) &&
       (_data != null)
    ) _button.label = headerData.label;
    
    cssClasses = (headerData != null && headerData.highlighted) ? const <String>['header-highlighted'] : null;
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _button_buttonClickHandler(FrameworkEvent<dynamic> event) {
    lastClickEvent = _button.lastClickEvent;
    
    notify(
        new FrameworkEvent<IHeaderData>(
            'buttonClick',
            relatedObject: headerData
        )
    );
  }
}

abstract class IHeaderData extends EventDispatcher {
  
  Stream<FrameworkEvent> onHighlightedChanged;
  
  bool get highlighted;
  void set highlighted(bool value);
  
  final String label = '', labelLong = '', identifier = '';
  final Symbol field = null;
  final dynamic data = null;
  
}

class HeaderData extends EventDispatcherImpl implements IHeaderData {
  
  @event Stream<FrameworkEvent> onHighlightedChanged;
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data = null;
  
  //---------------------------------
  // highlighted
  //---------------------------------
  
  bool _highlighted = false;
  
  bool get highlighted => _highlighted;
  void set highlighted(bool value) {
    if (value != _highlighted) {
      _highlighted = value;
      
      notify(new FrameworkEvent<bool>('highlightedChanged', relatedObject: value));
    }
  }
  
  HeaderData(this.identifier, this.field, this.label, this.labelLong);
  
  static HeaderData createSimple(String simpleName) => new HeaderData(simpleName, new Symbol(simpleName), simpleName, simpleName);
  
  String toString() => '$label : $field';
}

class DynamicHeaderData extends EventDispatcherImpl implements IHeaderData {
  
  @event Stream<FrameworkEvent> onHighlightedChanged;
  
  final String label, labelLong, identifier;
  final Symbol field;
  final dynamic data;
  
  //---------------------------------
  // highlighted
  //---------------------------------
  
  bool _highlighted = false;
  
  bool get highlighted => _highlighted;
  void set highlighted(bool value) {
    if (value != _highlighted) {
      _highlighted = value;
      
      notify(new FrameworkEvent<bool>('highlightedChanged', relatedObject: value));
    }
  }
  
  DynamicHeaderData(this.identifier, this.field, this.label, this.labelLong, this.data);
  
  static DynamicHeaderData createSimple(String simpleName, dynamic simpleData) => new DynamicHeaderData(simpleName, new Symbol(simpleName), simpleName, simpleName, simpleData);
  
  String toString() => '$label : $field';
}