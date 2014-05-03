library dart_flex.build.xml_parser;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:xml/xml.dart';

class XmlParser extends Transformer {
  
  static String SKIN_CREATE_BLOCK = '#SKIN_CREATE_BLOCK#';
  
  static String TEMPLATE = '''@override
  void createChildren() {
    super.createChildren();
    
    #SKIN_CREATE_BLOCK#
  }
''';
  
  static int _index = 0;
    
  XmlParser.asPlugin();
    
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
          
          _processXmlAsset(transform, skinAssetId, TEMPLATE).then(
            (String skinPart) {
              transform.addOutput(
                new Asset.fromString(
                    transform.primaryInput.id, 
                    codeBody.replaceAll(exp, skinPart)
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
  
  Future<String> _processXmlAsset(Transform transform, AssetId skinAssetId, String templateBody) {
    final Completer<String> completer = new Completer<String>();
    
    transform.readInputAsString(skinAssetId).then(
      (String content) {
        final XmlDocument incoming = parse(content);
        final List<String> lines = <String>[], declarations = <String>[];
        final XmlElement skinElement = incoming.lastChild as XmlElement;
        final Map<String, String> rootMap = _processRootNode(skinElement);
        
        _processChildren(declarations, lines, skinElement);
  
        final String newContent = lines.join('\r\t\t');
        
        _index++;
        
        templateBody = templateBody.replaceAll(SKIN_CREATE_BLOCK, newContent);
        
        completer.complete(templateBody);
      }
    );
    
    return completer.future;
  }
  
  Map<String, String> _processRootNode(XmlElement root) {
    final Map<String, String> rootMap = <String, String>{};
    
    root.attributes.forEach(
      (XmlAttribute rootAttribute) => rootMap[rootAttribute.name.toString()] = rootAttribute.value
    );
    
    return rootMap;
  }
  
  void _processChildren(List<String> declarations, List<String> lines, XmlElement node, {String parentComponent}) {
    node.children.forEach(
      (XmlNode childNode) {
        if (childNode is XmlElement) {
          final XmlAttribute idAttribute = childNode.attributes.firstWhere(
            (XmlAttribute nodeAttribute) => (nodeAttribute.name.local == 'id'),
            orElse: () => null
          );
          final String idValue = (idAttribute == null) ? 'genCmpnt${++_index}' : idAttribute.value;
          
          declarations.add('${childNode.name.local} ${idValue};');
          
          lines.add(_nodeToComponent(childNode, idValue, parentComponent, (idAttribute == null)));
          
          _processChildren(declarations, lines, childNode, parentComponent: idValue);
        }
      }     
    );
  }
  
  String _nodeToComponent(XmlElement node, String idValue, String parentComponent, bool isLocalVar) {
    final String className = node.name.toString();
    final List<String> properties = <String>[];
    
    node.attributes.forEach(
      (XmlAttribute attribute) {
        if (attribute.name.local == 'id') {
          // Ignore
        }
        else if (attribute.name.local == 'width') {
          if (attribute.value.contains('%')) properties.add('..percentWidth=${attribute.value.substring(0, attribute.value.length - 1)}.0');
          else properties.add('..width=${attribute.value}');
        }
        else if (attribute.name.local == 'height') {
          if (attribute.value.contains('%')) properties.add('..percentHeight=${attribute.value.substring(0, attribute.value.length - 1)}.0');
          else properties.add('..height=${attribute.value}');
        }
        else properties.add('..${attribute.name.local}=${attribute.value}');
      }
    );
    
    String result = isLocalVar ? 'final $className $idValue = new ${className}()${properties.join('')};' : '$idValue = new ${className}()${properties.join('')};';
    
    if (parentComponent != null) result = '${result}\r\t\t${parentComponent}.addComponent(${idValue});';
    else result = '${result}\r\t\taddComponent(${idValue});';
    
    if (!isLocalVar) result = "${result}\r\t\tnotify(new FrameworkEvent('skinPartAdded', relatedObject: ${idValue}));";
    
    return result;
  }
}