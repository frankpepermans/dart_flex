library dart_flex.codegen.event_transformer;

/*
 * 
  
  static const EventHook<FrameworkEvent> onButtonClickEvent = const EventHook<FrameworkEvent>('buttonClick');
  Stream<FrameworkEvent> get onButtonClick => HeaderItemRenderer.onButtonClickEvent.forTarget(this);
 */

import 'dart:async';

import 'package:barback/barback.dart';

class EventTransformer extends Transformer {
  
  EventTransformer.asPlugin();
    
  String get allowedExtensions => ".dart";
  
  @override
  Future<bool> apply(Transform transform) async {
    final RegExp exp = new RegExp(r"@event[^;]+;");
    String codeBody = await transform.primaryInput.readAsString();
    Match match = _matchNext(codeBody);
    
    while (match != null) {
      final String codeBodyMatch = codeBody.substring(match.start, match.end);
      final List<String> codeBodyMatchSplit = codeBodyMatch.split(' ');
      
      if (codeBodyMatchSplit.length == 3) {
        final String varName = codeBodyMatchSplit.last.substring(0, codeBodyMatchSplit.last.length - 1);
        String eventType = varName.substring(2);
        
        eventType = '${eventType[0].toLowerCase()}${eventType.substring(1)}';
        
        codeBody = codeBody.replaceFirst(exp, "static const EventHook<FrameworkEvent> _EVENT_${varName}Event = const EventHook<FrameworkEvent>('${eventType}'); Stream<FrameworkEvent> get $varName => _EVENT_${varName}Event.forTarget(this);");
      
        match = _matchNext(codeBody);
      } else break;
    }
    
    transform.addOutput(
      new Asset.fromString(
          transform.primaryInput.id, 
          codeBody
      )
    );
    
    return true;
  }
  
  Match _matchNext(String codeBody) => new RegExp(r"@event[^;]+;").firstMatch(codeBody);
  
}