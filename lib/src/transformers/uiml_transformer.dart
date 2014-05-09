library dart_flex.build.uiml_transformer;

import 'dart:async';
import 'dart:mirrors';

import 'package:barback/barback.dart';
import 'package:xml/xml.dart';

part "uiml_parts/uiml_part.dart";
part "uiml_parts/uiml_property.dart";
part "uiml_parts/uiml_element.dart";
part "uiml_parts/uiml_skin.dart";
part "uiml_parts/uiml_skin_library_item.dart";

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