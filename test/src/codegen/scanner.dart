part of codegen;

class Scanner {

  int _localScopeCount = 0;

  Scanner(String forXml) {
    _loadXml('src/views/example_view.xml').then(
            (xml.XmlDocument xml) {
          final xml.XmlNode xmlBody = xml.lastChild;
          final List<_Library> libraries = _fetchXmlLibraries(xmlBody);

          _scanRecursively(xmlBody, libraries);
        }
    );
  }

  // Private

  Future<xml.XmlDocument> _loadXml(String uri) {
    final Completer<xml.XmlDocument> C = new Completer<xml.XmlDocument>();

    HttpRequest.getString(uri).then(
            (String content) => C.complete(xml.parse(content))
    );

    return C.future;
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

  List<_Library> _fetchXmlLibraries(xml.XmlNode xmlBody) {
    final Reflection R = new Reflection();
    final List<_Library> libraries = <_Library>[];

    xmlBody.attributes.forEach(
      (xml.XmlAttribute A) {
          final String prefix = A.name.local;
          final String libraryUri = A.value.split('library://').last;

          libraries.add(
              new _Library(prefix, libraryUri, R.createGraph(libraryUri))
          );
      }
    );

    return libraries;
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

  _Declaration _convertXmlElementToScript(xml.XmlElement E, List<_Library> libraries) {
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

  String _buildSourceMethod(List<String> dotPath, String genericMethodName, Type expectedType) {
    return '$expectedType ${genericMethodName}() => null;';
  }

}