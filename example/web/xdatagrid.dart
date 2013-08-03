import 'dart:math';
import 'package:dart_flex/dart_flex.dart';
import 'package:observe/observe.dart';

class DataGridComponent extends DataGrid {
  
  DataGridComponent() : super() {
    
    /* builds a random data provider */
    /* you can alter the data provider collection directly, and it will update in the grid */
    dataProvider = createDataProvider(dpLen: 1000); 
    
    /* defines the grid cols */
    /* 
     * columns will stretch to the full width, this setup takes 3 columns 
     * col 2 and col 3 are fixed to 120 pixels width each
     * col 1 then is set at 100%, which means it will use up the remaining space,
     * DIV width - 120 - 120
     */
    columns = new ObservableList.from(
        [
         new DataGridColumn()
        ..minWidth = 120                                                 // min width in pixels
        ..percentWidth = 100.0                                           // scales the column to whatever available size left
        ..headerData = { 'label' : 'product', 'property' : 'product' }   // label is the header label text, property is the property in the data provider individual items
        ..field = 'product'                                              // property in the data provider individual items
            ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
        // Defines which header item renderer to use
        ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),
        // Defines which column item renderer to use

        new DataGridColumn()
        ..width = 120            // exact column width
        ..headerData = { 'label' : 'tags', 'property' : 'tag' }
        ..field = 'tag'
            ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct),

        new DataGridColumn()
        ..width = 120
        ..headerData = { 'label' : 'have it', 'property' : 'toggled' }
        ..field = 'toggled'
            ..headerItemRendererFactory = new ClassFactory(constructorMethod: HeaderItemRenderer.construct)
        ..columnItemRendererFactory = new ClassFactory(constructorMethod: LabelItemRenderer.construct)
        ]
    );
  }
  
  //*************************                   *************************//
  //                                                                     //
  //              Random data provider generation methods                //
  //                                                                     //
  //*************************                   *************************//
  
  String getRandomProduct() {
    Random rnd = new Random();

    List<String> products = [
                             'lettuce', 'tomatoes', 'whole grain bread', 'grapes', 'paprika', 'pineapple', 'corned beef', 'coca cola', 'fanta', 'sprite', 'ice tea',
                             'eggs', 'rice', 'hamburgers', 'french fries', 'cookies (any)', 'chocolate', 'butter', 'cheese', 'salmon', 'chicken wings', 'water',
                             'toilet paper', 'shampoo', 'mineral water', 'soda', 'baking powder', 'diapers', 'cucumber', 'apples', 'union', 'sausage'
                             ];

    return products[rnd.nextInt(products.length)];
  }

  String getRandomTag() {
    Random rnd = new Random();

    List<String> tags = [
                         'dairy', 'sweets', 'fruits & veggies', 'bread', 'poultry', 'meat', 'fish', 'beverages', 'household', 'multimedia', 'press shop', 'liquors', 'cleaning'
                         ];

    return tags[rnd.nextInt(tags.length)];
  }

  String getRandomPhone() {
    Random rnd = new Random();

    int a = rnd.nextInt(9);
    int b = rnd.nextInt(9);
    int c = rnd.nextInt(9);
    int d = rnd.nextInt(9);
    int e = rnd.nextInt(9);
    int f = rnd.nextInt(9);
    int g = rnd.nextInt(9);
    int h = rnd.nextInt(9);
    int i = rnd.nextInt(9);

    return '5$b$c - $d$e$f$g$h$i';
  }
  
  Map createListItem(int index) {
    Map item = new Map();
    Random rnd = new Random();

    item['id'] = index;
    item['imageNumber'] = rnd.nextInt(229);
    item['rating'] = rnd.nextInt(5) + 1;
    item['product'] = getRandomProduct();
    item['tag'] = getRandomTag();
    item['phone'] = getRandomPhone();
    item['toggled'] = false;

    return item;
  }
  
  ObservableList createDataProvider({int dpLen: 10, String labelMain: 'Option:'}) {
    ObservableList dataProvider = new ObservableList();
    int i;

    for (i=0; i<dpLen; i++) {
      dataProvider.add(createListItem(i));
    }

    return dataProvider;
  }
}