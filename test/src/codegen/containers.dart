part of codegen;

class _Extends {
  
  final bool extendsUIWrapper, extendsObsevable, extendsObsevableList, extendsObsevableMap;
  
  _Extends(this.extendsUIWrapper, this.extendsObsevable, this.extendsObsevableList, this.extendsObsevableMap);
  
}

class _Library {

  final String prefix, uri;
  final Map<Symbol, Map<String, List<_IInvokable>>> listing;

  _Library(this.prefix, this.uri, this.listing);

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

  final String id, body;
  final List<_Declaration> declarations = <_Declaration>[];

  _Declaration(this.id, this.body);

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
          SB.write('${new String.fromCharCode(10)}${id}.addComponent(${D.id}});');
        }
    );

    return SB.toString();
  }
}

class _PendingAttribute {

  final String value;
  final _Setter setter;

  _PendingAttribute(this.value, this.setter);

}

class _SourceResult {

  final String sourceValue, sourceMethod, sourceMethodName;

  _SourceResult(this.sourceValue, this.sourceMethod, this.sourceMethodName);

}