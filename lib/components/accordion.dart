part of dart_flex;

typedef ItemRendererFactory<IItemRenderer> ItemRendererFactoryHandler(dynamic data);

class Accordion extends Group {
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  List<_AccordionPanelElement> _panels;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  static const EventHook<FrameworkEvent<IItemRenderer>> onRendererAddedEvent = const EventHook<FrameworkEvent<IItemRenderer>>('rendererAdded');
  Stream<FrameworkEvent<IItemRenderer>> get onRendererAdded => Accordion.onRendererAddedEvent.forTarget(this);
  
  static const EventHook<FrameworkEvent<IItemRenderer>> onRendererRemovedEvent = const EventHook<FrameworkEvent<IItemRenderer>>('rendererRemoved');
  Stream<FrameworkEvent<IItemRenderer>> get onRendererRemoved => Accordion.onRendererRemovedEvent.forTarget(this);
  
  //---------------------------------
  // orientation
  //---------------------------------
  
  static const EventHook<FrameworkEvent> onOrientationChangedEvent = const EventHook<FrameworkEvent>('orientationChanged');
  Stream<FrameworkEvent> get onOrientationChanged => Accordion.onOrientationChangedEvent.forTarget(this);

  String _orientation = 'vertical';
  bool _isOrientationChanged = true;

  String get orientation => _orientation;
  set orientation(String value) {
    if (value != _orientation) {
      _orientation = value;
      _isOrientationChanged = true;

      notify(
        new FrameworkEvent(
          'orientationChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // dataProvider
  //---------------------------------

  static const EventHook<FrameworkEvent> onDataProviderChangedEvent = const EventHook<FrameworkEvent>('dataProviderChanged');
  Stream<FrameworkEvent> get onDataProviderChanged => Accordion.onDataProviderChangedEvent.forTarget(this);
  
  ObservableList<dynamic> _dataProvider;
  
  bool _isPanelsUpdateRequired = false;

  ObservableList<dynamic> get dataProvider => _dataProvider;
  set dataProvider(ObservableList<dynamic> value) {
    if (value != _dataProvider) {
      _dataProvider = value;
      _isPanelsUpdateRequired = true;
      
      selectedIndex = 0;
      
      if (value != null) _streamSubscriptionManager.add(
          'accordion_dataProviderChange', 
          value.listChanges.listen(_dataProvider_collectionChangedHandler),
          flushExisting: true
      );
      else _streamSubscriptionManager.flushIdent('accordion_dataProviderChange');
      
      notify(
          new FrameworkEvent(
            'dataProviderChanged',
            relatedObject: value
          )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // selectedIndex
  //---------------------------------

  static const EventHook<FrameworkEvent> onSelectedIndexChangedEvent = const EventHook<FrameworkEvent>('selectedIndexChanged');
  Stream<FrameworkEvent> get onSelectedIndexChanged => Accordion.onSelectedIndexChangedEvent.forTarget(this);
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;
  set selectedIndex(int value) {
    if (value != _selectedIndex) {
      _selectedIndex = value;
      _isPanelsUpdateRequired = true;

      notify(
        new FrameworkEvent(
          'selectedIndexChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // headerHeight
  //---------------------------------

  static const EventHook<FrameworkEvent> onHeaderHeightChangedEvent = const EventHook<FrameworkEvent>('headerHeightChanged');
  Stream<FrameworkEvent> get onHeaderHeightChanged => Accordion.onHeaderHeightChangedEvent.forTarget(this);
  int _headerHeight = 24;

  int get headerHeight => _headerHeight;
  set headerHeight(int value) {
    if (value != _headerHeight) {
      _headerHeight = value;
      _isPanelsUpdateRequired = true;

      notify(
        new FrameworkEvent(
          'headerHeightChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // headerItemRendererFactory
  //---------------------------------

  static const EventHook<FrameworkEvent> onHeaderItemRendererFactoryChangedEvent = const EventHook<FrameworkEvent>('headerItemRendererFactoryChanged');
  Stream<FrameworkEvent> get onHeaderItemRendererFactoryChanged => Accordion.onHeaderItemRendererFactoryChangedEvent.forTarget(this);
  ItemRendererFactory<IAccordionHeaderItemRenderer> _headerItemRendererFactory;

  ItemRendererFactory<IAccordionHeaderItemRenderer> get headerItemRendererFactory => _headerItemRendererFactory;
  set headerItemRendererFactory(ItemRendererFactory<IAccordionHeaderItemRenderer> value) {
    if (value != _headerItemRendererFactory) {
      _headerItemRendererFactory = value;

      notify(
        new FrameworkEvent(
          'headerItemRendererFactoryChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // headerField
  //---------------------------------

  Symbol _headerField;

  Symbol get headerField => _headerField;
  set headerField(Symbol value) {
    if (value != _headerField) {
      _headerField = value;
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // headerFields
  //---------------------------------

  List<Symbol> _headerFields;

  List<Symbol> get headerFields => _headerFields;
  set headerFields(List<Symbol> value) {
    if (value != _headerFields) {
      _headerFields = value;
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // contentItemRendererFactory
  //---------------------------------

  static const EventHook<FrameworkEvent> onContentItemRendererFactoryChangedEvent = const EventHook<FrameworkEvent>('contentItemRendererFactoryChanged');
  Stream<FrameworkEvent> get onContentItemRendererFactoryChanged => Accordion.onContentItemRendererFactoryChangedEvent.forTarget(this);
  ClassFactory<IItemRenderer> _contentItemRendererFactory;

  ClassFactory<IItemRenderer> get contentItemRendererFactory => _contentItemRendererFactory;
  set contentItemRendererFactory(ClassFactory<IItemRenderer> value) {
    if (value != _contentItemRendererFactory) {
      _contentItemRendererFactory = value;

      notify(
        new FrameworkEvent(
          'contentItemRendererFactoryChanged'
        )
      );
      
      _removeAllPanels();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // contentItemRendererFactoryHandler
  //---------------------------------

  static const EventHook<FrameworkEvent> onContentItemRendererFactoryHandlerChangedEvent = const EventHook<FrameworkEvent>('contentItemRendererFactoryHandlerChanged');
  Stream<FrameworkEvent> get onContentItemRendererFactoryHandlerChanged => Accordion.onContentItemRendererFactoryHandlerChangedEvent.forTarget(this);
  ItemRendererFactoryHandler _contentItemRendererFactoryHandler;

  ItemRendererFactoryHandler get contentItemRendererFactoryHandler => _contentItemRendererFactoryHandler;
  set contentItemRendererFactoryHandler(ItemRendererFactoryHandler value) {
    if (value != _contentItemRendererFactoryHandler) {
      _contentItemRendererFactoryHandler = value;

      notify(
        new FrameworkEvent(
          'contentItemRendererFactoryHandlerChanged'
        )
      );
      
      _removeAllPanels();

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // contentField
  //---------------------------------

  Symbol _contentField;

  Symbol get contentField => _contentField;
  set contentField(Symbol value) {
    if (value != _contentField) {
      _contentField = value;
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  // contentFields
  //---------------------------------

  List<Symbol> _contentFields;

  List<Symbol> get contentFields => _contentFields;
  set contentFields(List<Symbol> value) {
    if (value != _contentFields) {
      _contentFields = value;
      
      invalidateProperties();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  Accordion({String elementId: null}) : super(elementId: elementId) {
    _className = 'Accordion';
    
    horizontalScrollPolicy = verticalScrollPolicy = ScrollPolicy.NONE;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    ILayout defaultLayout;

    if (_isOrientationChanged) {
      _isOrientationChanged = false;
      
      if (orientation == 'horizontal') defaultLayout = new HorizontalLayout();
      else if (orientation == 'vertical') defaultLayout = new VerticalLayout();

      defaultLayout.useVirtualLayout = true;
      defaultLayout.gap = 0;

      layout = defaultLayout;
    }
    
    if (_control != null) {
      if (_isPanelsUpdateRequired) {
        _isPanelsUpdateRequired = false;
        
        _updatePanels();
      }
    }
  }
  
  @override
  void updateLayout() {
    if (_panels != null) {
      bool isVerticalLayout = (_orientation == 'vertical');
      
      _panels.forEach(
        (_AccordionPanelElement panel) {
          if (isVerticalLayout) {
            panel._headerItemRenderer.percentWidth = 100.0;
            panel._headerItemRenderer.height = _headerHeight;
            
            panel._contentItemRenderer.percentWidth = 100.0;
            panel._contentItemRenderer.percentHeight = 100.0;
          } else {
            panel._headerItemRenderer.width = _headerHeight;
            panel._headerItemRenderer.percentHeight = 100.0;
            
            panel._contentItemRenderer.percentWidth = 100.0;
            panel._contentItemRenderer.percentHeight = 100.0;
          }
        }
      );
    }
    
    super.updateLayout();
  }
  
  @override
  void flushHandler() {
    super.flushHandler();
    
    _removeAllPanels();
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _removeAllPanels() {
    if (_panels != null) _panels.forEach(
      (_AccordionPanelElement panel) {
        panel._headerSelectionListener.cancel();
        
        removeComponent(panel._contentItemRenderer, flush: true);
        removeComponent(panel._headerItemRenderer, flush: true);
      }
    );
    
    _panels = null;
  }
  
  void _updatePanels() {
    if (_panels == null) _panels = <_AccordionPanelElement>[];
    
    _AccordionPanelElement panel;
    IAccordionHeaderItemRenderer headerItemRenderer;
    IItemRenderer contentItemRenderer;
    int i = (_dataProvider != null) ? _dataProvider.length : 0;
    int j = _panels.length;
    int k;
    
    while (j > i) {
      panel = _panels[--j];
      
      panel._headerSelectionListener.cancel();
      
      removeComponent(panel._contentItemRenderer, flush: true);
      removeComponent(panel._headerItemRenderer, flush: true);
      
      _panels.remove(panel);
      
      notify(
          new FrameworkEvent<IItemRenderer>(
              'rendererRemoved',
              relatedObject: panel._contentItemRenderer
          )
      );
    }
    
    j = _panels.length;
    
    for (k=j; k<i; k++) {
      headerItemRenderer = _headerItemRendererFactory.immediateInstance()
        ..height = _headerHeight
        ..fields = _headerFields
        ..field = _headerField;
      
      contentItemRenderer = (_contentItemRendererFactoryHandler != null) ? _contentItemRendererFactoryHandler(_dataProvider[k]).immediateInstance() : _contentItemRendererFactory.immediateInstance();
      
      contentItemRenderer.fields = _contentFields;
      contentItemRenderer.field = _contentField;
      
      panel = new _AccordionPanelElement(
        _dataProvider[k],
        headerItemRenderer,
        contentItemRenderer,
        headerItemRenderer.onClick.listen(_panel_clickHandler)
      );
      
      _panels.add(panel);
      
      addComponent(panel._headerItemRenderer);
      addComponent(panel._contentItemRenderer);
      
      notify(
          new FrameworkEvent<IItemRenderer>(
              'rendererAdded',
              relatedObject: contentItemRenderer
          )
      );
    }
    
    j = _panels.length;
    
    for (i=0; i<j; i++) {
      panel = _panels[i];
      
      panel._headerItemRenderer.data = panel._contentItemRenderer.data = _dataProvider[i];
      
      panel._contentItemRenderer.visible = panel._contentItemRenderer.includeInLayout = (_selectedIndex == i);
    }
  }
  
  void _panel_clickHandler(FrameworkEvent event) {
    final IItemRenderer headerItemRenderer = event.currentTarget as IItemRenderer;
    
    int i = _panels.length;
    
    while (i > 0) if (_panels[--i]._headerItemRenderer == headerItemRenderer) {
      selectedIndex = i;
      
      break;
    }
  }
  
  void _dataProvider_collectionChangedHandler(List<ListChangeRecord> changes) {
    _isPanelsUpdateRequired = true;
    
    if (_selectedIndex >= _dataProvider.length) selectedIndex = (_dataProvider.length == 0) ? 0 : _dataProvider.length - 1;

    invalidateProperties();
  }
}

class _AccordionPanelElement {
  
  final IItemRenderer _headerItemRenderer, _contentItemRenderer;
  final dynamic _data;
  final StreamSubscription _headerSelectionListener;
  
  _AccordionPanelElement(this._data, this._headerItemRenderer, this._contentItemRenderer, this._headerSelectionListener) {
    _headerItemRenderer.data = _contentItemRenderer.data = _data;
  }
  
}