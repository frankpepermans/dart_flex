part of dart_flex.build.uiml_transformer;

class UIMLSkin {
  
  final XmlElement element;
  final TransformLogger logger;
  
  List<UIMLSkinLibraryItem> _libraryItems;
  List<UIMLPart> _elements;
  List<String> _declarations = <String>[];
  
  List<UIMLSkinLibraryItem> get libraryItems => _libraryItems;
  List<UIMLPart> get elements => _elements;
  
  UIMLSkin(this.element, this.logger) {
    _libraryItems = _getLibraryItems();
    _elements = _toElements(element);
  }
  
  String getLocalDeclarations() {
    List<String> declarations = <String>[];
    
    _elements.forEach(
      (UIMLPart part) {
        if (part is UIMLElement) {
          if (part._isLocallyScoped) declarations.add('${part.className} ${part._id};');
          
          declarations.add(part._declarations.join('\r\t'));
        }
      }
    );
    
    return _declarations.join('\r\t') + '\r\t' + declarations.join('\r\t');
  }
  
  String getBindingMethods() {
    List<String> methods = <String>[];
    
    _elements.forEach(
      (UIMLPart part) {
        if (part is UIMLElement) methods.add(part._methods.join('\r\t'));
      }
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
  
  List<UIMLPart> _toElements(XmlElement target, {UIMLPart parent}) {
    final List<UIMLPart> elements = <UIMLPart>[];
    
    target.children.forEach(
      (XmlNode N) {
        if (N is XmlElement) {
          final List<String> nsAndName = N.name.toString().split(':');
          
          if (nsAndName.last == 'declarations') {
            N.children.forEach(
              (XmlNode O) => _declarations.add(_toObservable(O))
            );
          } else {
            final String casing = nsAndName.last[0];
            final UIMLPart uimlElm = (casing == casing.toLowerCase()) ? new UIMLProperty(this, parent, N) : new UIMLElement(this, parent, N);
            
            elements.add(uimlElm);
            
            elements.addAll(_toElements(N, parent: uimlElm));
          }
        }
      }     
    );
    
    return elements;
  }
  
  String _toObservable(XmlNode node) {
    if (node is XmlElement) {
      final List<String> nsAndName = node.name.toString().split(':');
      final String declName = nsAndName.last;
      final XmlAttribute idAttr = node.attributes.firstWhere(
        (XmlAttribute A) => (A.name.local == 'id'),
        orElse: () => null
      );
      
      if (idAttr == null) return '';
      
      if (const <String>['num', 'int', 'double', 'bool', 'String'].contains(declName)) {
        if (declName == 'String') return '@observable ${declName} ${idAttr.value} = \'${node.text}\';';
        
        return '@observable ${declName} ${idAttr.value} = ${node.text};';
      }
      else return '@observable ${declName} ${idAttr.value} = new ${declName}(${node.text});';
    }
    
    return '';
  }
}