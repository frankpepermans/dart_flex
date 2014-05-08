part of dart_flex.build.uiml_transformer;

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
  
  String _trimQuotes(String value) {
    final RegExp exp = new RegExp(r"'[^']+'");
    Match match = exp.firstMatch(value);
    
    while (match != null) {
      value = value.substring(0, match.start) + value.substring(match.end);
      
      match = exp.firstMatch(value);
    }
    
    return value;
  }
  
  List<String> _allMatches(String value) {
    final List<String> result = <String>[];
    final RegExp exp = new RegExp(r"[^\(\) \+\-\/\*\&\|]+");
    
    exp.allMatches(value).forEach(
      (Match M) => result.add(value.substring(M.start, M.end))    
    );
    
    return result;
  }
  
  Map<String, String> _getBindingStatement(String expr, String property) {
    final String fullExpr = expr.substring(1, expr.length - 1);
    final List<String> matches = _allMatches(_trimQuotes(fullExpr));
    
    String decl = '', invoc = '';
    
    matches.forEach(
      (String trimExpr) {
        final String bindName = '__bind_${++_bindingIndex}';
        final List<String> chain = trimExpr.split('.');
        final List<String> existsStatement = <String>[], existsStatement2 = <String>[], currentPath = <String>[], currentPath2 = <String>[], streams = <String>[], streamMethods = <String>[];
        
        chain.forEach(
          (String node) {
            final String streamName = '__stream_${++_streamIndex}';
            final String exists = _getExistsStatement(existsStatement);
            final String listener = 'on${node[0].toUpperCase()}${node.substring(1, node.length)}Changed';
            final String singular = currentPath.join('.');
            final String target = '${singular}${(currentPath.length > 0) ? '.' : ''}';
            final String listenerTarget = '${target}$listener';
            final String srcTarget = (singular.length > 0) ? singular : 'this';
            
            final String stream = '$streamName = (($srcTarget is ObservableList) ? ${target}listChanges.listen(${bindName}) : ($srcTarget is Observable) ? ${target}changes.listen(${bindName}) : $listenerTarget.listen(${bindName}));';
            
            if (currentPath.length > 0) existsStatement.add('(${currentPath.join('.')}.$node != null)');
            else existsStatement.add('($node != null)');
            
            currentPath.add(node);
            
            streams.add(streamName);
            
            streamMethods.add(
              'if ($streamName != null) { ${streamName}.cancel(); } ${_getExistsStatement(existsStatement2)} if ($listenerTarget != null) ${stream}'    
            );
            
            if (currentPath2.length > 0) existsStatement2.add('(${currentPath2.join('.')}.$node != null)');
            else existsStatement2.add('($node != null)');
            
            currentPath2.add(node);
          }
        );
        
        _declarations.add('StreamSubscription ${streams.join(', ')};');
        
        decl += 'void ${bindName}(_) { ${_getExistsStatement(existsStatement)} ${_id}.${property} = ${fullExpr}; else ${_id}.${property} = null; \r\t${streamMethods.join('\r\t')} }\r\r\t';
        invoc += 'later > () => ${bindName}(null);';
      }
    );
    
    return <String, String>{
      'declaration': decl,
      'invocation': invoc
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