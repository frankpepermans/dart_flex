import 'package:dart_flex/dart_flex.dart' as flex;

import 'dart:async';
import 'dart:html';
import 'dart:mirrors' as mirrors;
import 'package:xml/xml.dart' as xml;

int _localScopeCount = 0;

void main() {
  _loadXml('src/views/example_view.xml').then(
      (xml.XmlDocument xml) {
        final xml.XmlNode xmlBody = xml.lastChild;
        final List<_Library> libraries = _fetchXmlLibraries(xmlBody);

        _scanRecursively(xmlBody, libraries);
      }
  );


}

void _scanRecursively(xml.XmlNode xmlNode, List<_Library> libraries) {
  xmlNode.children.forEach(
    (xml.XmlNode node) {
      //node.nodeType.ELEMENT;
      if (node is xml.XmlElement) {
        xml.XmlElement E = node;

        _Declaration D = _convertXmlElementToScript(E, libraries);

        print(D);
      }
    }
  );
}

_Declaration _convertXmlElementToScript(xml.XmlElement E, Map<String, List<_Library>> libraries) {
  _Library lib = libraries.firstWhere(
    (_Library L) => L.prefix == E.name.prefix,
    orElse: () => null
  );

  if (lib == null) throw new ArgumentError('Prefix ${E.name.prefix} is not declared in the XML header');

  final Symbol S = new Symbol(E.name.local);

  if (!lib.listing.containsKey(S)) throw new ArgumentError('Element ${E.name.local} is not found in library ${lib.uri}}');

  final List<_IInvokable> setters = lib.listing[S]['setters'];
  final Map<String, _PendingAttribute> M = <String, _PendingAttribute>{};
  String id;

  E.attributes.forEach(
      (xml.XmlAttribute A) {
        if (A.name.local == 'id') id = A.value;
        else {
          final _Setter setter = setters.firstWhere(
              (_Setter S) => S.name == '${A.name.local}=',
              orElse: () => null
          );

          if (setter == null) throw new ArgumentError('Property ${A.name.local} is not found in ${E.name.local}');
          else M[A.name.local] = new _PendingAttribute(A.value, setter);
        }
      }
  );

  final StringBuffer SB = new StringBuffer();

  if (id == null) id = '__scope_fnc_local_${++_localScopeCount}';

  SB.write('$id = new ${E.name.local}()');

  M.forEach(
      (String K, _PendingAttribute V) {
        _SourceResult SR = _xmlValueToSourceValue(V.value, V.setter.expectedType);

        SB.write('..${K}=${SR.sourceValue}');
      }
  );

  SB.write(';');

  final _Declaration D = new _Declaration(id, SB.toString());

  E.children.forEach(
      (xml.XmlNode C) {
        if (C is xml.XmlElement) D.declarations.add(_convertXmlElementToScript(C, libraries));
      }
  );

  return D;
}

_Library _getElementLibrary(xml.XmlName name, List<_Library> libraries) {
  final _Library library = libraries.firstWhere(
      (_Library L) => L.prefix == name.prefix,
      orElse: () => null
  );

  return true;
}

List<_Library> _fetchXmlLibraries(xml.XmlNode xmlBody) {
  final List<_Library> libraries = <_Library>[];

  xmlBody.attributes.forEach(
      (xml.XmlAttribute A) {
        final String prefix = A.name.local;
        final String libraryUri = A.value.split('library://').last;

        libraries.add(
            new _Library(prefix, libraryUri, _createGraph(libraryUri))
        );
      }
  );

  return libraries;
}

Map<Symbol, Map<String, List<_IInvokable>>> _createGraph(String libraryUri) {
  final Map<Symbol, Map<String, List<_IInvokable>>> uiList = <Symbol, Map<String, List<_IInvokable>>>{};

  mirrors.currentMirrorSystem().libraries.forEach(
    (Uri uri, mirrors.LibraryMirror M) {
      if (uri.path == libraryUri) {
        M.declarations.forEach(
          (Symbol S, mirrors.DeclarationMirror D) {
            if (D is mirrors.ClassMirror && _extendsUIWrapper(D)) {
              Map<String, List<_IInvokable>> decl = <String, List<_IInvokable>>{};

              decl['methods'] = <_IInvokable>[];

              decl['getters'] = _fillGetters(D);
              decl['setters'] = _fillSetters(D, decl['getters']);

              uiList[S] = decl;
            }
          }
        );
      }
    }
  );

  return uiList;
}

Future<xml.XmlDocument> _loadXml(String uri) {
  final Completer<xml.XmlDocument> C = new Completer<xml.XmlDocument>();

  HttpRequest.getString(uri).then(
      (String content) => C.complete(xml.parse(content))
  );

  return C.future;
}

String _toQName(String symbolName) => symbolName.split('"')[1];

bool _extendsUIWrapper(mirrors.ClassMirror M) {
  bool isUIWrapperSubClass = false;
  mirrors.ClassMirror m = M;
  
  while (m.superclass != null) {
    if (m.superclass != null && m.superclass.simpleName.toString() == 'Symbol("UIWrapper")') {
      isUIWrapperSubClass = true;

      break;
    }

    m = m.superclass;
  }
  
  return isUIWrapperSubClass;
}

List<_IInvokable> _fillGetters(mirrors.ClassMirror M) {
  final List<_IInvokable> L = <_IInvokable>[];

  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isGetter) {
          if (V.returnType.hasReflectedType) L.add(new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, _getListener(M, _toQName(V.simpleName.toString()))));
          else L.add(new _Getter(_toQName(V.simpleName.toString()), dynamic, _getListener(M, _toQName(V.simpleName.toString()))));
        }
    }
  );

  return L;
}

_Getter _getListener(mirrors.ClassMirror M, String propertyName) {
  final String listenerName = 'on${propertyName[0].toUpperCase()}${propertyName.substring(1)}Changed';
  _Getter listener;
  
  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isGetter && _toQName(V.simpleName.toString()) == listenerName) {
          if (V.returnType.hasReflectedType) listener = new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, null);
          else listener = new _Getter(_toQName(V.simpleName.toString()), dynamic, null);
        }
    }
  );
  
  return listener;
}

List<_IInvokable> _fillSetters(mirrors.ClassMirror M, List<_IInvokable> getters) {
  final List<_IInvokable> L = <_IInvokable>[];

  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isSetter) {
          _IInvokable getter = getters.firstWhere(
            (_IInvokable I) => ('${I.name}=' == _toQName(V.simpleName.toString())),
            orElse: () => null
          );

          if (getter != null) L.add(new _Setter('${getter.name}=', getter.expectedType));
          else {
            if (V.parameters.first.type.hasReflectedType) L.add(new _Setter(_toQName(V.simpleName.toString()), V.parameters.first.type.reflectedType));
            else L.add(new _Setter(_toQName(V.simpleName.toString()), dynamic));
          }
        }
    }
  );

  return L;
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
  _Getter listener;
  
  _Getter(this.name, this.expectedType, this.listener) {
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

class _PendingAttribute {

  final String value;
  final _Setter setter;

  _PendingAttribute(this.value, this.setter);

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

_SourceResult _xmlValueToSourceValue(String xmlValue, Type expectedType) {
  if (xmlValue.codeUnitAt(0) == '{'.codeUnitAt(0) && xmlValue.codeUnitAt(xmlValue.length - 1) == '}'.codeUnitAt(0)) {
    final String xmlSource = xmlValue.substring(1, xmlValue.length - 1);
    final List<String> dotPath = xmlSource.split('.');
    final String genericMethodName = '__scope_fnc_local_${++_localScopeCount}';
    //todo: make generic method

    return new _SourceResult('${genericMethodName}()', _buildSourceMethod(dotPath, genericMethodName, expectedType), genericMethodName);
  }

  switch (expectedType) {
    case String: return new _SourceResult("'${xmlValue}'", null, null);
    case int: return new _SourceResult(int.parse(xmlValue).toString(), null, null);
    case double:
      if (xmlValue.contains('.')) return new _SourceResult(double.parse(xmlValue).toString(), null, null);
      else return new _SourceResult(double.parse('${xmlValue}.0').toString(), null, null);
  }

  return new _SourceResult(xmlValue, null, null);
}

String _buildSourceMethod(List<String> dotPath, String genericMethodName, Type expectedType) {
  return '$expectedType ${genericMethodName}() => null;';
}

class _SourceResult {

  final String sourceValue, sourceMethod, sourceMethodName;

  _SourceResult(this.sourceValue, this.sourceMethod, this.sourceMethodName);

}