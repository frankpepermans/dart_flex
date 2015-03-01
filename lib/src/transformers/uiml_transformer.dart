library dart_flex.codegen;

import 'dart:async';
import 'dart:mirrors' as mirrors;

//import 'package:dart_flex/dart_flex.dart' as flex;
import 'package:barback/barback.dart';
import 'package:xml/xml.dart' as xml;
import 'package:observe/observe.dart';

part "codegen/containers.dart";
part "codegen/reflection.dart";
part "codegen/scanner.dart";

class UIMLTransformer extends Transformer {
  
  static const String SKIN_PARTS = '#SKIN_PARTS#';
  static const String SKIN_DECL = '#SKIN_DECL#';
  static const String SKIN_CREATE_BLOCK = '#SKIN_CREATE_BLOCK#';
  static const String SKIN_FNC = '#SKIN_FNC#';
  
  static const String TEMPLATE = '''@override
  void createChildren() {
    super.createChildren();
    #SKIN_CREATE_BLOCK#
  }
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
        
        if ((matches != null) && matches.isNotEmpty) {
          final AssetId skinAssetId = new AssetId.parse(codeBody.substring(matches.first.start + 7, matches.first.end - 2));
          
          transform.readInputAsString(skinAssetId).then(
            (String content) {
              final Scanner S = new Scanner('Controller', content);
              
              String res = TEMPLATE;
              
              transform.addOutput(
                new Asset.fromString(
                    transform.primaryInput.id, 
                    codeBody.replaceAll(exp, res.replaceAll(SKIN_CREATE_BLOCK, S.createChildrenBody))
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