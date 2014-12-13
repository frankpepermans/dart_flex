part of dart_flex.build.uiml_transformer;

class UIMLElement extends UIMLPart {
  
  static int _locallyScopedCount = 0, _streamIndex = 0, _bindingIndex = 0;
  
  String _id, _properties;
  ClassMirror _classMirror;
  bool _isLocallyScoped;
  List<String> _declarations = <String>[];
  List<String> _methods = <String>[];
  
  String get id => _id;
  String get properties => _properties;
  
  UIMLElement(UIMLSkin skin, UIMLPart parent, XmlElement element) : super(skin, parent, element) {
    _id = _getId();
    _properties = _getProperties();
    //_classMirror = skin.getLibraryItem(_ns).getClassMirror(_className);
  }
  
  String toString() {
    if (parent != null && parent.isRepeater) return '${(parent as UIMLElement).id}.creationHandler = () { final $_className $_id = new ${_className}();${_properties} return $_id; };';
    
    return '$_id = new ${_className}();${_properties}${_getInclusionStatement()}${_getCreationEvent()}';
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
        
        bool isEvent = false;
        String value = A.value, property = A.name.local;
        Map<String, String> bindingObj;
        
        if (property.contains('-')) {
          final List<String> eventParts = property.split('-');
          String eventName = '';
          
          isEvent = true;
          
          eventParts.forEach(
            (String part) {
              if (eventName == '') eventName = part;
              else eventName += part[0].toUpperCase() + part.substring(1);
            }
          );
          
          property = eventName;
        }
        
        final bool parentIsRepeater = (parent != null && parent.isRepeater);
        
        if (!parentIsRepeater && exp.hasMatch(value)) {
          bindingObj = _getBindingStatement(value, property);
          
          _methods.add(bindingObj['declaration']);
              
          properties.add(bindingObj['invocation']);
        } else {
          String aval = A.value;
          
          if (parent != null) aval = aval.replaceAll('repeater.currentValue', '${(parent as UIMLElement).id}.getCurrentValueFor(${_id})');
          
          if (exp.hasMatch(aval)) aval = aval.substring(1, aval.length - 1);
          
          switch (property) {
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
              if (isEvent) properties.add('${_id}.${property}.listen(${A.value});');
              else properties.add('${_id}.${property}=${aval};');
          }
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
    String fullExpr = expr.substring(1, expr.length - 1);
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
            
            final String stream = '$streamName = (($srcTarget is ObservableList) ? ${target}listChanges.listen(${bindName}) : ($srcTarget is Observable) ? ${target}changes.listen(${bindName}) : ($srcTarget is IUIWrapper) ? $listenerTarget.listen(${bindName}) : null);';
            
            if (currentPath.isNotEmpty) existsStatement.add('(${currentPath.join('.')}.$node != null)');
            else existsStatement.add('($node != null)');
            
            currentPath.add(node);
            
            streams.add(streamName);
            
            streamMethods.add(
              'try { if ($streamName != null) { ${streamName}.cancel(); } ${_getExistsStatement(existsStatement2)} ${stream} } catch(error) {}'    
            );
            
            if (currentPath2.length > 0) existsStatement2.add('(${currentPath2.join('.')}.$node != null)');
            else existsStatement2.add('($node != null)');
            
            currentPath2.add(node);
          }
        );
        
        _declarations.add('StreamSubscription ${streams.join(', ')};');
        
        if (fullExpr.contains('repeater.currentValue')) fullExpr = fullExpr.replaceAll('repeater.currentValue', '${(parent as UIMLElement).id}.getCurrentValueFor(${_id})');
        
        decl += 'void ${bindName}(_) { ${_getExistsStatement(existsStatement)} ${_id}.${property} = ${fullExpr}; else ${_id}.${property} = null; \r\t${streamMethods.join('\r\t')} }\r\r\t';
        invoc += 'reflowManager.scheduleMethod(this, ${bindName}, [null], forceSingleExecution: true);';
      }
    );
    
    return <String, String>{
      'declaration': decl,
      'invocation': invoc
    };
  }
  
  String _getExistsStatement(List<String> existsStatement) {
    const List<String> excludes = const <String>['(new != null)', '(const != null)', '(final != null)', '( != null)'];
    
    existsStatement.removeWhere(
      (String E) => excludes.contains(E)  
    );
    
    if (existsStatement.isNotEmpty) return 'if (${existsStatement.join(' && ')})';
    
    return 'if (true)';
  }
  
  String _getInclusionStatement() {
    final String stateUpdateCurrent = '\r\t\rupdateAfterSkinStateChanged(${_id});\r\t\tonCurrentSkinStatesChanged.listen((FrameworkEvent<List<SkinState>> event) => updateAfterSkinStateChanged(${_id}));';
    
    if (parent is UIMLElement) {
      final String stateUpdateInclude = '\r\t\t${_id}.onIncludeInChanged.listen((FrameworkEvent<List<SkinState>> event) => updateAfterSkinStateChanged(${_id}));';
      final String stateUpdateExclude = '\r\t\t${_id}.onExcludeFromChanged.listen((FrameworkEvent<List<SkinState>> event) => updateAfterSkinStateChanged(${_id}));';
      
      return '\r\t\t${(parent as UIMLElement).id}.addComponent(${_id});${stateUpdateCurrent}${stateUpdateInclude}${stateUpdateExclude}';
    }
    else if (parent is UIMLProperty) return '\r\t\t${(parent.parent as UIMLElement).id}.${parent.className} = ${_id};';
    
    return '\r\t\taddComponent(${_id});${stateUpdateCurrent}';
  }
  
  String _getCreationEvent() {
    if (!_isLocallyScoped) return "\r\t\tnotify(new FrameworkEvent<IUIWrapper>('skinPartAdded', relatedObject: ${_id}));";
    
    return '';
  }
}