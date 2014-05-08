part of dart_flex.build.uiml_transformer;

class UIMLSkin {
  
  final XmlElement element;
  final TransformLogger logger;
  
  List<UIMLSkinLibraryItem> _libraryItems;
  List<UIMLElement> _elements;
  
  List<UIMLSkinLibraryItem> get libraryItems => _libraryItems;
  List<UIMLElement> get elements => _elements;
  
  UIMLSkin(this.element, this.logger) {
    _libraryItems = _getLibraryItems();
    _elements = _toElements(element);
  }
  
  String getLocalDeclarations() {
    List<String> declarations = <String>[];
    
    _elements.forEach(
      (UIMLElement element) {
        if (element._isLocallyScoped) declarations.add('${element.className} ${element._id};');
        
        declarations.add(element._declarations.join('\r\t'));
      }
    );
    
    return declarations.join('\r\t');
  }
  
  String getBindingMethods() {
    List<String> methods = <String>[];
    
    _elements.forEach(
      (UIMLElement element) => methods.add(element._methods.join('\r\t'))
    );
    
    return methods.join('\r\t');
  }
  
  String toString() => _elements.join('\r\t\t');
  
  UIMLSkinLibraryItem getLibraryItem(String ns) => _libraryItems.firstWhere(
    (UIMLSkinLibraryItem I) => (I.ns == ns)
  );
  
  List<UIMLSkinLibraryItem> _getLibraryItems() {
    final List<UIMLSkinLibraryItem> items = <UIMLSkinLibraryItem>[];
    
    element.attributes.forEach(
      (XmlAttribute A) {
        final List<String> nsDecl = A.name.toString().split(':');
        
        if (nsDecl.length == 2 && nsDecl.first == 'xmlns') items.add(new UIMLSkinLibraryItem.fromUri(logger, nsDecl.last, A.value));
      }
    );
    
    return items;
  }
  
  List<UIMLElement> _toElements(XmlElement target, {UIMLElement parent}) {
    final List<UIMLElement> elements = <UIMLElement>[];
    
    target.children.forEach(
      (XmlNode N) {
        if (N is XmlElement) {
          final UIMLElement uimlElm = new UIMLElement(this, parent, N);
          
          elements.add(uimlElm);
          
          elements.addAll(_toElements(N, parent: uimlElm));
        }
      }     
    );
    
    return elements;
  }
}