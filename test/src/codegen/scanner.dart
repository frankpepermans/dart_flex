part of codegen;

class Scanner {

  final dynamic instance;
  final String forXml;
  final Reflection R = new Reflection();
  final List<String> _initLines = <String>[], _methodLines = <String>[], _declarations = <String>[];
  int _localScopeCount = 0;

  Scanner(this.instance, this.forXml) {
    _loadXml('src/views/example_view.xml').then(
      (xml.XmlDocument xml) {
        final List<_Library> libraries = _fetchXmlLibraries(xml.lastChild);

        _scanRecursively(xml.lastChild, libraries);
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
            
            _initLines.add(D.toString());

            print(D);
          }
        }
    );
  }

  List<_Library> _fetchXmlLibraries(xml.XmlElement xmlBody) {
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
      mirrors.ClassMirror CM = mirrors.reflectClass(expectedType);
      bool isClassFactory = false;

      while (CM != null) {
        CM.metadata.forEach(
          (mirrors.InstanceMirror IM) {
            if (IM.reflectee is flex.classFactory) isClassFactory = true;
          }
        );
        
        if (isClassFactory) break;
        
        CM = CM.superclass;
      }

      return new _SourceResult('${genericMethodName}()', _buildSourceMethod(dotPath, genericMethodName, expectedType, isClassFactory), genericMethodName);
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
    final _Library lib = libraries.firstWhere(
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

    if (id == null) {
      id = '__scope_ins_local_${++_localScopeCount}';
      
      _declarations.add('${E.name.local} ${id};');
    }

    SB.write('$id = new ${E.name.local}();');
    
    final _Declaration D = new _Declaration(id);

    E.children.forEach(
      (xml.XmlNode C) {
        if (C is xml.XmlElement) {
          final _Setter setter = setters.firstWhere(
            (_Setter S) => S.name == '${C.name.local}=',
            orElse: () => null
          );
          
          if (setter == null) D.declarations.add(_convertXmlElementToScript(C, libraries));
          else {
            final xml.XmlElement content = C.children.firstWhere(
              (xml.XmlNode N) => N is xml.XmlElement,
              orElse: () => null
            );
            
            M[C.name.local] = new _PendingAttribute('{${content.name.local}}', setter);
          }
        }
      }
    );
    
    M.forEach(
      (String K, _PendingAttribute V) {
        _SourceResult SR = _xmlValueToSourceValue(V.value, V.setter.expectedType);
        
        SB.write('${id}.${K}=${SR.sourceValue};');
      }
    );
    
    D.body = SB.toString();

    return D;
  }

  String _buildSourceMethod(List<String> dotPath, String genericMethodName, Type expectedType, bool isClassFactory) {
    final mirrors.InstanceMirror IM = R.reflectInstance(instance);
    mirrors.ClassMirror CM = IM.type;
    List<String> targets = <String>['this'], nullChecks = <String>[], fncBodyList = <String>[];

    dotPath.forEach(
      (String segment) {
        if (CM != null) {
          final Map<String, List<_IInvokable>> decl = R.createGraphForUIWrapper(CM);

          decl['getters'].forEach(
              (_Getter G) {
                if (G.name == segment) {
                  if (G.isReflectable) {
                    _declarations.add('StreamSubscription __scope_var_local_${++_localScopeCount};');
                    
                    fncBodyList.add('if (__scope_var_local_${_localScopeCount} != null) __scope_var_local_${_localScopeCount}.cancel();');
                    
                    if (nullChecks.isNotEmpty) fncBodyList.add('if (${nullChecks.join(' && ')}) __scope_var_local_${_localScopeCount} = ${targets.join('.')}.changes.listen(${genericMethodName});');
                    else fncBodyList.add('__scope_var_local_${_localScopeCount} = ${targets.join('.')}.changes.listen(${genericMethodName});');
                  }
                  
                  if (G.listener != null) {
                    _declarations.add('StreamSubscription __scope_var_local_${++_localScopeCount};');
                    
                    fncBodyList.add('if (__scope_var_local_${_localScopeCount} != null) __scope_var_local_${_localScopeCount}.cancel();');
                    
                    if (nullChecks.isNotEmpty) fncBodyList.add('if (${nullChecks.join(' && ')}) __scope_var_local_${_localScopeCount} = ${targets.join('.')}.${G.listener.name}.listen(${genericMethodName});');
                    else fncBodyList.add('__scope_var_local_${_localScopeCount} = ${targets.join('.')}.${G.listener.name}.listen(${genericMethodName});');
                  }

                  CM = mirrors.reflectType(G.expectedType) as mirrors.ClassMirror;
                }
              }
          );
          
          targets.add(segment);
          
          nullChecks.add('(${targets.join('.')} != null)');
        }
      }
    );
    
    nullChecks.removeLast();
    
    String theReturn, theMethod;
    
    if (isClassFactory) theReturn = 'new ItemRendererFactory(constructorMethod: ${dotPath.join('.')}.construct)';
    else theReturn = dotPath.join('.');
    
    if (nullChecks.isEmpty) theMethod = '$expectedType ${genericMethodName}(_) { ${fncBodyList.join('')} return ${theReturn}; }';
    else theMethod = '$expectedType ${genericMethodName}(_) { ${fncBodyList.join('')} return (${nullChecks.join(' && ')}) ? ${theReturn} : null; }';
    
    _methodLines.add(theMethod);
    
    print(theMethod);
    
    return '${genericMethodName}(null)';
  }

}