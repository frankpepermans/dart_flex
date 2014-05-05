library dart_flex.build.uiml_transformer;

import 'dart:async';
import 'dart:mirrors';

import 'package:barback/barback.dart';
import 'package:xml/xml.dart';

class UIMLTransformer extends Transformer {
  
  static const String SKIN_DECL = '#SKIN_DECL#';
  static const String SKIN_CREATE_BLOCK = '#SKIN_CREATE_BLOCK#';
  static const String SKIN_FNC = '#SKIN_FNC#';
  
  static const String TEMPLATE = '''#SKIN_DECL#
  
  @override
  void createChildren() {
    super.createChildren();
    
    #SKIN_CREATE_BLOCK#
  }
  
  #SKIN_FNC#
''';
    
  UIMLTransformer.asPlugin();
    
  String get allowedExtensions => ".dart";
  
  @override
  Future<dynamic> apply(Transform transform) {
    final Completer completer = new Completer();
    
    transform.primaryInput.readAsString().then(
      (String codeBody) {
        final RegExp exp = new RegExp(r"@Skin\('[^']+'\)");
        final Iterable<Match> matches = exp.allMatches(codeBody);
        
        if ((matches != null) && (matches.length > 0)) {
          final AssetId skinAssetId = new AssetId.parse(codeBody.substring(matches.first.start + 7, matches.first.end - 2));
          
          transform.readInputAsString(skinAssetId).then(
            (String content) {
              final XmlDocument incoming = parse(content);
              final UIMLSkin skin = new UIMLSkin(incoming.lastChild as XmlElement, transform.logger);
              
              String res = TEMPLATE;
              
              res = res.replaceAll(SKIN_DECL, skin.getLocalDeclarations());
              res = res.replaceAll(SKIN_FNC, skin.getBindingMethods());
              
              transform.addOutput(
                new Asset.fromString(
                    transform.primaryInput.id, 
                    codeBody.replaceAll(exp, res.replaceAll(SKIN_CREATE_BLOCK, skin.toString()))
                )
              );
              
              completer.complete(null);
            }
          );
        } else completer.complete(null);
      }
    );
    
    return completer.future;
  }
}

class UIMLElement {
  
  static int _locallyScopedCount = 0, _streamIndex = 0, _bindingIndex = 0;
  
  final UIMLSkin skin;
  final UIMLElement parent;
  final XmlElement element;
  
  String _ns, _className, _id, _properties;
  ClassMirror _classMirror;
  bool _isLocallyScoped;
  List<String> _declarations = <String>[];
  List<String> _methods = <String>[];
  
  String get ns => _ns;
  String get className => _className;
  String get id => _id;
  String get properties => _properties;
  
  UIMLElement(this.skin, this.parent, this.element) {
    final List<String> nsAndName = element.name.toString().split(':');
    
    _ns = nsAndName.first;
    _className = nsAndName.last;
    _id = _getId();
    _properties = _getProperties();
    _classMirror = skin.getLibraryItem(_ns).getClassMirror(_className);
  }
  
  String toString() {
    String ctr = '';
    
    if (_isLocallyScoped) ctr = 'final $_className';
    
    return '$ctr $_id = new ${_className}();${_properties}${_getInclusionStatement()}${_getCreationEvent()}';
  }
  
  String _getId() {
    final XmlAttribute idAttr = element.attributes.firstWhere(
      (XmlAttribute A) => (A.name.local == 'id'),
      orElse: () => null
    );
    
    _isLocallyScoped = (idAttr == null);
    
    if (_isLocallyScoped) return '__scope_fnc_local_${++_locallyScopedCount}';
    
    return idAttr.value;
  }
  
  String _getProperties() {
    final List<String> properties = <String>[];
    
    element.attributes.forEach(
      (XmlAttribute A) {
        final RegExp exp = new RegExp(r"{[^}]+}");
        
        String value = A.value;
        Map<String, String> bindingObj;
        
        if (exp.hasMatch(value)) {
          bindingObj = _getBindingStatement(value, A.name.local);
          
          _methods.add(bindingObj['declaration']);
          
          properties.add(bindingObj['invocation']);
        } else switch (A.name.local) {
          case 'id': break;
          case 'width':
            if (A.value.contains('%')) properties.add('${_id}.percentWidth=${A.value.substring(0, A.value.length - 1)}.0;');
            else properties.add('${_id}.width=${A.value};');
            
            break;
          case 'height':
            if (A.value.contains('%')) properties.add('${_id}.percentHeight=${A.value.substring(0, A.value.length - 1)}.0;');
            else properties.add('${_id}.height=${A.value};');
            
            break;
          default:
            properties.add('${_id}.${A.name.local}=${A.value};');
        }
      }
    );
    
    return properties.join('\r\r\t');
  }
  
  Map<String, String> _getBindingStatement(String expr, String property) {
    final String bindName = '__bind_${++_bindingIndex}';
    final String trimExpr = expr.substring(1, expr.length - 1);
    final List<String> chain = trimExpr.split('.');
    final List<String> existsStatement = <String>[], existsStatement2 = <String>[], currentPath = <String>[], currentPath2 = <String>[], streams = <String>[], streamMethods = <String>[];
    
    chain.forEach(
      (String node) {
        final String streamName = '__stream_${++_streamIndex}';
        final String exists = _getExistsStatement(existsStatement);
        final String listener = 'on${node[0].toUpperCase()}${node.substring(1, node.length)}Changed';
        final String listenerTarget = '${currentPath.join('.')}${(currentPath.length > 0) ? '.' : ''}$listener';
        
        final String stream = '$streamName = $listenerTarget';
        
        if (currentPath.length > 0) existsStatement.add('(${currentPath.join('.')}.$node != null)');
        else existsStatement.add('($node != null)');
        
        currentPath.add(node);
        
        streams.add(streamName);
        
        streamMethods.add(
          'if ($streamName != null) { ${streamName}.cancel(); } ${_getExistsStatement(existsStatement2)} if ($listenerTarget != null) ${stream}.listen(${bindName});'    
        );
        
        if (currentPath2.length > 0) existsStatement2.add('(${currentPath2.join('.')}.$node != null)');
        else existsStatement2.add('($node != null)');
        
        currentPath2.add(node);
      }
    );
    
    _declarations.add('StreamSubscription ${streams.join(', ')};');
    
    return <String, String>{
      'declaration': 'void ${bindName}(_) { ${_getExistsStatement(existsStatement)} ${_id}.${property} = ${trimExpr}; \r\t${streamMethods.join('\r\t')} }',
      'invocation': '${bindName}(null);'
    };
  }
  
  String _getExistsStatement(List<String> existsStatement) {
    if (existsStatement.length > 0) return 'if (${existsStatement.join(' && ')})';
    
    return '';
  }
  
  String _getInclusionStatement() {
    if (parent != null) return '\r\t\t${parent.id}.addComponent(${_id});';
    
    return '\r\t\taddComponent(${_id});';
  }
  
  String _getCreationEvent() {
    if (!_isLocallyScoped) return "\r\t\tnotify(new FrameworkEvent<IUIWrapper>('skinPartAdded', relatedObject: ${_id}));";
    
    return '';
  }
}

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

class UIMLSkinLibraryItem {
  
  final String ns, lib;
  final TransformLogger logger;
  
  UIMLSkinLibraryItem(this.logger, this.ns, this.lib);
  
  factory UIMLSkinLibraryItem.fromUri(TransformLogger logger, String ns, String uri) {
    final List<String> parts = uri.split('://');
    
    return new UIMLSkinLibraryItem(logger, ns, parts.last);
  }
  
  ClassMirror getClassMirror(String className) {
    final MirrorSystem mirrorSystem = currentMirrorSystem();
    
    mirrorSystem.libraries.values.forEach(
      (LibraryMirror M) {
        if (M.simpleName.toString().contains('dart_flex')) logger.info(M.simpleName.toString());
      }
    );return null;
    
    final LibraryMirror libraryMirror = mirrorSystem.libraries.values.firstWhere(
      (LibraryMirror M) => (M.simpleName.toString() == 'Symbol("${lib}")'),
      orElse: () => null
    );
    
    if (libraryMirror == null) logger.error('Could not locate library $lib');
    
    libraryMirror.declarations.values.forEach(
      (DeclarationMirror M) => logger.info(M.simpleName.toString())
    );return null;
    
    final ClassMirror classMirror = libraryMirror.declarations.values.firstWhere(
      (DeclarationMirror M) => (M.simpleName == className),
      orElse: () => null
    ) as ClassMirror;
    
    if (classMirror == null) logger.error('Could not locate class $className in library $lib');
    
    return classMirror;
  }
}