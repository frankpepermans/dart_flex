part of dart_flex.codegen;

class Scanner {

  final String instanceName;
  final String xmlFile;
  final Reflection R = new Reflection();
  final List<String> _initLines = <String>[], _methodLines = <String>[], _declarations = <String>[], _listVars = <String>[];
  mirrors.ClassMirror instanceCM;
  int _localScopeCount = 0;
  String createChildrenBody;

  Scanner(this.instanceName, this.xmlFile) {
    xml.XmlDocument xmlDoc = xml.parse(xmlFile);
    final List<_Library> libraries = _fetchXmlLibraries(xmlDoc.lastChild);
    
    libraries.forEach(
      (_Library L) {
        L.listing.forEach(
          (_, _LibraryPart LP) {
            if (LP.CM.hasReflectedType && LP.CM.reflectedType.toString() == instanceName) instanceCM = LP.CM;
          }
        );
      }
    );

    _scanRecursively(xmlDoc.lastChild, libraries);
    
    final StringBuffer SB = new StringBuffer();
    
    SB.write(_declarations.join(new String.fromCharCode(10)));
    SB.write(_methodLines.join(new String.fromCharCode(10)));
    SB.write(_listVars.join(new String.fromCharCode(10)));
    SB.write(_initLines.join(new String.fromCharCode(10)));
    
    createChildrenBody = SB.toString();
  }

  // Private

  void _scanRecursively(xml.XmlNode xmlNode, List<_Library> libraries) {
    xmlNode.children.forEach(
      (xml.XmlNode node) {
        //node.nodeType.ELEMENT;
        if (node is xml.XmlElement) {
          xml.XmlElement E = node;

          _Declaration D = _convertXmlElementToScript(E, libraries, null)..isRoot = true;
          
          _initLines.add(D.toString());
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

  _SourceResult _xmlValueToSourceValue(String xmlValue, Type expectedType, String dotSetter) {
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
      
      if (expectedType == Function) return new _SourceResult(genericMethodName, _buildSourceMethod(dotPath, genericMethodName, expectedType, isClassFactory, dotSetter), genericMethodName);
      else return new _SourceResult('${genericMethodName}(null)', _buildSourceMethod(dotPath, genericMethodName, expectedType, isClassFactory, dotSetter), genericMethodName);
    }

    switch (expectedType) {
      case Symbol: return new _SourceResult("const Symbol('${xmlValue}')", null, null);
      case String: return new _SourceResult("'${xmlValue}'", null, null);
      case int: return new _SourceResult(int.parse(xmlValue).toString(), null, null);
      case double:
        if (xmlValue.contains('.')) return new _SourceResult(double.parse(xmlValue).toString(), null, null);
        else return new _SourceResult(double.parse('${xmlValue}.0').toString(), null, null);
    }

    return new _SourceResult(xmlValue, null, null);
  }

  _Declaration _convertXmlElementToScript(xml.XmlElement E, List<_Library> libraries, String contructorMethod) {
    final _Library lib = libraries.firstWhere(
      (_Library L) => L.prefix == E.name.prefix,
      orElse: () => null
    );

    if (lib == null) throw new ArgumentError('Prefix ${E.name.prefix} is not declared in the XML header');

    final Symbol S = new Symbol(E.name.local);

    if (!lib.listing.containsKey(S)) throw new ArgumentError('Element ${E.name.local} is not found in library ${lib.uri}}');

    final List<_IInvokable> setters = lib.listing[S].setters;
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
          else M[A.name.local] = new _PendingAttribute(A.value, setter, false, null);
        }
      }
    );

    final StringBuffer SB = new StringBuffer();

    if (id == null) {
      id = '__scope_ins_local_${++_localScopeCount}';
      
      _declarations.add('${E.name.local} ${id};');
    }

    if (contructorMethod == null) SB.write('$id = new ${E.name.local}();');
    else {
      SB.write('$id = new ${E.name.local}.${contructorMethod}();');
    }
    
    final _Declaration D = new _Declaration(id);

    E.children.forEach(
      (xml.XmlNode C) {
        if (C is xml.XmlElement) {
          final xml.XmlAttribute F = C.attributes.firstWhere(
            (xml.XmlAttribute A) => A.name.local == 'factory',
            orElse: () => null
          );
          final _Setter setter = setters.firstWhere(
            (_Setter S) => S.name == '${C.name.local}=',
            orElse: () => null
          );
          
          if (F != null) {
            print(F);
          }
          
          if (setter == null) D.declarations.add(_convertXmlElementToScript(C, libraries, (F != null) ? F.value : null));
          else {
            xml.XmlElement content = C.children.firstWhere(
              (xml.XmlNode N) => N is xml.XmlElement,
              orElse: () => null
            );
            xml.XmlElement factoryArgs;
            
            if (F != null) {
              factoryArgs = content;
              content = null;
            }
            
            if (content != null) M[C.name.local] = new _PendingAttribute('{${content.name.local}}', setter, (content.name.prefix == 'core' && content.name.local == 'List'), content);
            else {
              if (factoryArgs != null) {
                final List<xml.XmlElement> args = factoryArgs.children.where(
                  (xml.XmlNode N) => N is xml.XmlElement    
                ).toList();
                final List<String> argsList = <String>[];
                
                args.forEach(
                  (xml.XmlElement E) {
                    final _Library lib = libraries.firstWhere(
                      (_Library L) => L.prefix == E.name.prefix,
                      orElse: () => null
                    );

                    if (lib == null) throw new ArgumentError('Prefix ${E.name.prefix} is not declared in the XML header');

                    final Symbol S = new Symbol(E.name.local);

                    if (!lib.listing.containsKey(S)) throw new ArgumentError('Element ${E.name.local} is not found in library ${lib.uri}}');
                    
                    _SourceResult SR = _xmlValueToSourceValue(E.children.first.text, lib.listing[S].CM.reflectedType, '');
                    
                    argsList.add(SR.sourceValue);
                  }
                );
                
                M[C.name.local] = new _PendingAttribute('${F.value}(${argsList.join(',')})', setter, false, null);
              }
              else M[C.name.local] = new _PendingAttribute('${C.children.first.text}', setter, false, null);
            }
          }
        }
      }
    );
    
    M.forEach(
      (String K, _PendingAttribute V) {
        _SourceResult SR = V.isList ? _parseListDeclaration(V.listElement, libraries, V.setter.expectedType) : _xmlValueToSourceValue(V.value, V.setter.expectedType, '${id}.${K}');
        
        SB.write('${id}.${K}=${SR.sourceValue};');
      }
    );
    
    D.body = SB.toString();

    return D;
  }
  
  _SourceResult _parseListDeclaration(xml.XmlElement listElement, List<_Library> libraries, Type expectedType) {
    final List<String> L = <String>[];
    final String theVar = '__scope_var_local_${++_localScopeCount}';
    int index = 0;
    
    listElement.children.forEach(
      (xml.XmlNode N) {
        if (N is xml.XmlElement) {
          _Library lib = libraries.firstWhere(
            (_Library L) => L.prefix == N.name.prefix,
            orElse: () => null
          );
          Symbol S = new Symbol(N.name.local);
          
          _LibraryPart R = lib.listing[S];
          _SourceResult SR = _buildDeclaration(N, libraries);
          
          SR.sourceMethodName = '${theVar}[${index++}]';
          
          L.add(SR.sourceValue);
        }
      }
    );
    
    _declarations.add('Function $theVar;');
    _listVars.add('${theVar} = () => new ObservableList.from([${L.join(',')}]);');
    
    return new _SourceResult('${theVar}()', null, null);
  }
  
  _SourceResult _buildDeclaration(xml.XmlElement E, List<_Library> libraries) {
    final _Library lib = libraries.firstWhere(
      (_Library L) => L.prefix == E.name.prefix,
      orElse: () => null
    );
    final Symbol S = new Symbol(E.name.local);
    final _LibraryPart R = lib.listing[S];
    _SourceResult SR;
    
    if (lib.prefix == 'core') SR = _xmlValueToSourceValue(E.children.first.text, R.CM.reflectedType, null);
    else {
      final String constr = 'new ${E.name.local}()';
      final _Declaration D = _convertXmlElementToScript(E, libraries, null);
      
      SR = new _SourceResult(D.id, D.body, null);
      
      _initLines.add(D.toString());
    }
    
    return SR;
  }

  String _buildSourceMethod(List<String> dotPath, String genericMethodName, Type expectedType, bool isClassFactory, String dotSetter) {
    String theReturn, theMethod;
    
    if (expectedType == Function) {
      String methodBody = dotPath.join('.').trim();
      
      if (methodBody[0] == '{') methodBody = methodBody.substring(1, methodBody.length - 1).trim();
      
      theMethod = 'dynamic ${genericMethodName}${methodBody}';
          
      _methodLines.add(theMethod);
      
      return '${genericMethodName}';
    }
    
    mirrors.ClassMirror CM = instanceCM;
    List<String> targets = <String>['this'], nullChecks = <String>[], preNullChecks = <String>[], fncBodyList = <String>[];
    
    dotPath.forEach(
      (String segment) {
        if (CM != null) {
          targets.add(segment);
          
          preNullChecks.add('(${targets.join('.')} != null)');
        }
      }
    );
    
    targets = <String>['this'];
    
    final String nullCondition = preNullChecks.isEmpty ? '' : 'if (${preNullChecks.join(' && ')}) ';

    dotPath.forEach(
      (String segment) {
        if (CM != null) {
          final _LibraryPart decl = R.createGraphForUIWrapper(CM);
          
          segment = segment.trim();

          decl.getters.forEach(
              (_Getter G) {
                if (G.name == segment) {
                  if (G.isReflectable) {
                    _declarations.add('StreamSubscription __scope_var_local_${++_localScopeCount};');
                    
                    fncBodyList.add('if (__scope_var_local_${_localScopeCount} != null) __scope_var_local_${_localScopeCount}.cancel();');
                    
                    if (nullChecks.isNotEmpty) fncBodyList.add('if (${nullChecks.join(' && ')}) __scope_var_local_${_localScopeCount} = ${targets.join('.')}.changes.listen((_) { $nullCondition $dotSetter = ${genericMethodName}(null); });');
                    else fncBodyList.add('__scope_var_local_${_localScopeCount} = ${targets.join('.')}.changes.listen((_) { $nullCondition $dotSetter = ${genericMethodName}(null); });');
                  }
                  
                  if (G.listener != null) {
                    _declarations.add('StreamSubscription __scope_var_local_${++_localScopeCount};');
                    
                    fncBodyList.add('if (__scope_var_local_${_localScopeCount} != null) __scope_var_local_${_localScopeCount}.cancel();');
                    
                    if (nullChecks.isNotEmpty) fncBodyList.add('if (${nullChecks.join(' && ')}) __scope_var_local_${_localScopeCount} = ${targets.join('.')}.${G.listener.name}.listen((_) { $nullCondition $dotSetter = ${genericMethodName}(null); });');
                    else fncBodyList.add('__scope_var_local_${_localScopeCount} = ${targets.join('.')}.${G.listener.name}.listen((_) { $nullCondition $dotSetter = ${genericMethodName}(null); });');
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
    
    if (nullChecks.isNotEmpty) nullChecks.removeLast();
    
    if (isClassFactory) theReturn = 'new ItemRendererFactory(constructorMethod: ${dotPath.join('.')}.construct)';
    else theReturn = dotPath.join('.');
    
    if (nullChecks.isEmpty) theMethod = '$expectedType ${genericMethodName}(_) { ${fncBodyList.join('')} return ${theReturn}; }';
    else theMethod = '$expectedType ${genericMethodName}(_) { ${fncBodyList.join('')} return (${nullChecks.join(' && ')}) ? ${theReturn} : null; }';
    
    _methodLines.add(theMethod);
    
    return '${genericMethodName}(null)';
  }

}