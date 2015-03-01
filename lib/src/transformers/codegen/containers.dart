part of dart_flex.codegen;

class _Extends {
  
  final bool extendsUIWrapper, extendsObsevable, extendsObsevableList, extendsObsevableMap;
  
  _Extends(this.extendsUIWrapper, this.extendsObsevable, this.extendsObsevableList, this.extendsObsevableMap);
  
}

class _Library {

  final String prefix, uri;
  final Map<Symbol, _LibraryPart> listing;

  _Library(this.prefix, this.uri, this.listing);

}

class _LibraryPart {
  
  final mirrors.ClassMirror CM;
  final List<_IInvokable> methods, getters, setters;
  
  _LibraryPart(this.CM, this.methods, this.getters, this.setters);
  
}

abstract class _IInvokable {

  String name;
  Type expectedType;

}

class _Getter implements _IInvokable {

  String name;
  Type expectedType;
  final _Getter listener;
  final bool isReflectable;

  _Getter(this.name, this.expectedType, this.listener, this.isReflectable) {
    //if (listener != null) print(listener.name);
  }

}

class _Setter implements _IInvokable {

  String name;
  Type expectedType;

  _Setter(this.name, this.expectedType) {
    //print('$name $expectedType');
  }

  String toString() => '$expectedType $name';
}

class _Method implements _IInvokable {

  String name;
  Type expectedType;

  _Method(this.name, this.expectedType);

}

class _Declaration {

  final String id;
  final List<_Declaration> declarations = <_Declaration>[];
  bool isRoot = false;
  String body;

  _Declaration(this.id);

  String toString() {
    final StringBuffer SB = new StringBuffer();

    SB.write(body);

    declarations.forEach(
      (_Declaration D) {
        SB.write('${new String.fromCharCode(10)}$D');
      }
    );

    declarations.forEach(
      (_Declaration D) {
        SB.write('${new String.fromCharCode(10)}${id}.addComponent(${D.id});');
      }
    );
    
    if (isRoot) SB.write('${new String.fromCharCode(10)}addComponent(${id});');

    return SB.toString();
  }
}

class _PendingAttribute {

  final String value;
  final _Setter setter;
  final bool isList;
  final xml.XmlElement listElement;

  _PendingAttribute(this.value, this.setter, this.isList, this.listElement);

}

class _SourceResult {

  final String sourceValue, sourceMethod;
  String sourceMethodName;

  _SourceResult(this.sourceValue, this.sourceMethod, this.sourceMethodName);

}