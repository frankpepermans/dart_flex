part of dart_flex;

class skin {
  
  final String src;
    
  const skin(this.src);
}

abstract class Skin {
  
}

class ProgrammaticSkin<H extends BaseComponent> implements Skin {
  
  H host;
  
}

class SkinTest<H extends DataGrid> extends ProgrammaticSkin<DataGrid> {
  
  ProgrammaticSkin() {
    host;
  }
  
}