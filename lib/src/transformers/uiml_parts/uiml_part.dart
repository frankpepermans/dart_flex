part of dart_flex.build.uiml_transformer;

abstract class UIMLPart {
  
  final UIMLSkin skin;
  final UIMLPart parent;
  final XmlElement element;
  
  String _ns, _className;
  
  String get ns => _ns;
  String get className => _className;
  
  UIMLPart(this.skin, this.parent, this.element) {
    final List<String> nsAndName = element.name.toString().split(':');
        
    _ns = nsAndName.first;
    _className = nsAndName.last;
  }
  
}