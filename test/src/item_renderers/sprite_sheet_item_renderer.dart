part of dart_flex_test;

class SpriteSheetItemRenderer extends ItemRenderer {
  
  static Random _RANDOM = new Random(1000);
  
  SpriteSheetItemRenderer({String elementId: null}) : super(elementId: null, autoDrawBackground: false) {
    className = '';
  }

  static SpriteSheetItemRenderer construct() => new SpriteSheetItemRenderer()..layout = new TileLayout()..gap = 0;
  
  @override
  void createChildren() {
    super.createChildren();
    
    final int len = _RANDOM.nextInt(9) + 1;
    
    for (int i=0; i<len; i++) addComponent(_createSpriteSheet());
  }
  
  SpriteSheet _createSpriteSheet() {
    final SpriteSheet sheet = new SpriteSheet()
      ..source = 'images/ss01.png'
      ..width = 80
      ..height = 55
      ..columnSize = 80
      ..rowSize = 55
      ..sheetWidth = 640
      ..sheetHeight = 55;
    
    int index = 0;
    
    new Timer.periodic(
        const Duration(milliseconds: 120),
        (_) => sheet.index = ++index % 8
    );
    
    return sheet;
  }
}