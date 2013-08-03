import 'dart:async';
import 'dart:html';
import 'package:observe/observe.dart';
import 'package:dart_flex/dart_flex.dart';

//-----------------------------------
//
// Public properties
//
//-----------------------------------

//-----------------------------------
// xTagRegistry
//-----------------------------------

XTagRegistry xTagRegistry = new XTagRegistry();

//-----------------------------------
// view elements
//-----------------------------------

IViewStackElement layoutView;

IViewStackElement dataGridView;

IViewStackElement layoutViewCode;

IViewStackElement dataGridViewCode;

ComboBox layoutSelector;

Group imageGroup;

DataGrid issuesGrid;

Slider gapSelector;

Group layoutViewCodeContainer;

Group dataGridViewCodeContainer;

//-----------------------------------
//
// main
//
//-----------------------------------

void main() {
  xTagRegistry.onPartAdded.listen(_xTagRegistry_partAddedHandler);
}

void test() {
  /*DivElement container = event.currentTarget as DivElement;
  
  Group group = container.xtag as Group;
  //container.on
  print(group.className);*/
}

//-----------------------------------
//
// Private methods
//
//-----------------------------------

void _xTagRegistry_partAddedHandler(FrameworkEvent event) {
  XTagMap xTagMap = event.relatedObject as XTagMap;
  
  switch (xTagMap.xtagId) {
    case 'layoutView' :
      layoutView = xTagMap.xtagElement as IViewStackElement;
      
      _layoutView_partAddedHandler(layoutView);
      
      break;
      
    case 'dataGridView' :
      dataGridView = xTagMap.xtagElement as IViewStackElement;
      
      _dataGridView_partAddedHandler(dataGridView);
      
      break;
      
    case 'layoutViewCode' :
      layoutViewCode = xTagMap.xtagElement as IViewStackElement;
      
      _layoutViewCode_partAddedHandler(layoutViewCode);
      
      break;
      
    case 'dataGridViewCode' :
      dataGridViewCode = xTagMap.xtagElement as IViewStackElement;
      
      _dataGridViewCode_partAddedHandler(dataGridViewCode);
      
      break;
      
    case 'layoutViewCodeContainer' :
      layoutViewCodeContainer = xTagMap.xtagElement as Group;
      
      break;
      
    case 'dataGridViewCodeContainer' :
      dataGridViewCodeContainer = xTagMap.xtagElement as Group;
      
      break;
      
    case 'dataGridView' :
      dataGridView = xTagMap.xtagElement as IViewStackElement;
      
      _dataGridView_partAddedHandler(dataGridView);
      
      break;
      
    case 'layoutSelector' :
      layoutSelector = xTagMap.xtagElement as ComboBox;
      
      _layoutSelector_partAddedHandler(layoutSelector);
      
      break;
      
    case 'gapSelector' :
      gapSelector = xTagMap.xtagElement as Slider;
      
      _gapSelector_partAddedHandler(gapSelector);
      
      break;
      
    case 'imageGroup' :
      imageGroup = xTagMap.xtagElement as Group;
      
      break;
      
    case 'issuesGrid' :
      issuesGrid = xTagMap.xtagElement as DataGrid;
      
      loadDartIssuesDataProvider();
      
      break;
  }
}

void loadDartIssuesDataProvider() {
  Future<String> csv = HttpRequest.getString('dartIssuesPipe.csv');

  csv.then(_dartIssuesDataProvider_resultHandler);
}

void loadLayoutViewCode() {
  Future<String> codePage = HttpRequest.getString('loadLayoutViewCode.html');

  codePage.then(
      (String result) => layoutViewCodeContainer.control.innerHtml = result
  );
}

void loadDataGridViewCode() {
  Future<String> codePage = HttpRequest.getString('loadDataGridViewCode.html');

  codePage.then(
      (String result) => dataGridViewCodeContainer.control.innerHtml = result
  );
}

//-----------------------------------
//
// Event handlers
//
//-----------------------------------

void _dartIssuesDataProvider_resultHandler(String result) {
  ObservableList dataProvider = new ObservableList();
  Map item;
  List<String> columns = result.split('|');
  final int len = columns.length;
  int i = 0;
  
  while (i < len) {
    item = new Map();
    
    item['id'] = int.parse(columns[i++]);
    item['type'] = columns[i++];
    item['status'] = columns[i++];
    item['priority'] = columns[i++];
    item['area'] = columns[i++];
    item['version'] = columns[i++];
    item['user'] = columns[i++];
    item['title'] = columns[i++];
    item['tags'] = columns[i++];
    
    i++;
    
    dataProvider.add(item);
  }
  
  issuesGrid.columns = new ObservableList.from(
      [
               new DataGridColumn()
               ..width = 60
               ..headerData = { 'label' : 'id', 'property' : 'id' }
               ..field = 'id'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),

               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'type', 'property' : 'type' }
               ..field = 'type'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),

               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'status', 'property' : 'status' }
               ..field = 'status'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'priority', 'property' : 'priority' }
               ..field = 'priority'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'area', 'property' : 'area' }
               ..field = 'area'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..width = 60
               ..headerData = { 'label' : 'when?', 'property' : 'version' }
               ..field = 'version'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'user', 'property' : 'user' }
               ..field = 'user'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..minWidth = 120
               ..percentWidth = 100.0
               ..headerData = { 'label' : 'title', 'property' : 'title' }
               ..field = 'title'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
               
               new DataGridColumn()
               ..width = 120
               ..headerData = { 'label' : 'tags', 'property' : 'tags' }
               ..field = 'tags'
               ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
               ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct)
      ]
  );
  
  issuesGrid.dataProvider = dataProvider;
}

void _layoutView_partAddedHandler(IViewStackElement layoutView) {
  dynamic runtimeType = layoutView as dynamic;
  
  runtimeType.homeButton.onButtonClick.listen(
      (FrameworkEvent event) => layoutView.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: layoutView,
              namedView: 'view-2',
              sequentialView: 0
          )
      )
  );
  
  runtimeType.settingsButton.onButtonClick.listen(
      (FrameworkEvent event) => dataGridView.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: layoutView,
              namedView: 'view-1-code',
              sequentialView: 0
          )
      )
  );
  
  loadLayoutViewCode();
}

void _dataGridView_partAddedHandler(IViewStackElement dataGridView) {
dynamic runtimeType = dataGridView as dynamic;
  
  runtimeType.homeButton.onButtonClick.listen(
      (FrameworkEvent event) => dataGridView.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: dataGridView,
              namedView: 'view-1',
              sequentialView: 0
          )
      )
  );
  
  runtimeType.settingsButton.onButtonClick.listen(
      (FrameworkEvent event) => dataGridView.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: dataGridView,
              namedView: 'view-2-code',
              sequentialView: 0
          )
      )
  );
  
  loadDataGridViewCode();
}

void _layoutViewCode_partAddedHandler(IViewStackElement layoutViewCode) {
  dynamic runtimeType = layoutViewCode as dynamic;
  
  runtimeType.homeButton.onButtonClick.listen(
      (FrameworkEvent event) => layoutViewCode.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: layoutViewCode,
              namedView: 'view-1',
              sequentialView: 0
          )
      )
  );
}

void _dataGridViewCode_partAddedHandler(IViewStackElement dataGridViewCode) {
dynamic runtimeType = dataGridViewCode as dynamic;
  
  runtimeType.homeButton.onButtonClick.listen(
      (FrameworkEvent event) => dataGridViewCode.notify(
          new ViewStackEvent(
              ViewStackEvent.REQUEST_VIEW_CHANGE,
              relatedObject: dataGridViewCode,
              namedView: 'view-2',
              sequentialView: 0
          )
      )
  );
}

void _layoutSelector_partAddedHandler(ComboBox layoutSelector) {
  layoutSelector.onSelectedItemChanged.listen(_layoutSelector_onSelectedItemChangedHandler);
}

void _gapSelector_partAddedHandler(Slider gapSelector) {
  gapSelector.onValueChanged.listen(_gapSelector_onValueChangedHandler);
}

void _layoutSelector_onSelectedItemChangedHandler(FrameworkEvent event) {
  Map selectedItem = layoutSelector.selectedItem as Map;
  ILayout newLayout = selectedItem['value'] as ILayout;
  
  imageGroup.layout = newLayout;
  
  gapSelector.value = newLayout.gap;
}

void _gapSelector_onValueChangedHandler(FrameworkEvent event) {
  imageGroup.layout.gap = gapSelector.value.toInt();
  
  imageGroup.invalidateProperties();
}