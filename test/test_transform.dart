import 'package:dart_flex/dart_flex.dart' as flex;

import 'dart:mirrors' as mirrors;

const Symbol UI_WRAPPER_SYMBOL = const Symbol("UIWrapper");

void main() {
  final Map<Symbol, Map<String, List<_IInvokable>>> uiList = <Symbol, Map<String, List<_IInvokable>>>{};
  
  mirrors.currentMirrorSystem().libraries.forEach(
    (Uri uri, mirrors.LibraryMirror M) {
      if (uri.path == 'dart_flex/dart_flex.dart') {
        M.declarations.forEach(
          (Symbol S, mirrors.DeclarationMirror D) {
            if (D is mirrors.ClassMirror && _extendsUIWrapper(D)) {
              Map<String, List<_IInvokable>> decl = uiList[S] = <String, List<_IInvokable>>{};
              
              decl['getters'] = <_IInvokable>[];
              decl['setters'] = <_IInvokable>[];
              decl['methods'] = <_IInvokable>[];
              
              _fillGetters(D, decl['getters']);
              _fillSetters(D, decl['setters'], decl['getters']);
            }
          }    
        );
      }
    }
  );
}

String _toQName(String symbolName) => symbolName.split('"')[1];

bool _extendsUIWrapper(mirrors.ClassMirror M) {
  bool isUIWrapperSubClass = false;
  mirrors.ClassMirror m = M;
  
  while (m.superclass != null) {
    m = m.superclass;
    
    if (m.superclass != null && m.superclass.simpleName == UI_WRAPPER_SYMBOL) {
      isUIWrapperSubClass = true;
      
      break;
    }
  }
  
  return isUIWrapperSubClass;
}

void _fillGetters(mirrors.ClassMirror M, List<_IInvokable> list) {
  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isGetter) {
          if (V.returnType.hasReflectedType) list.add(new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, _getListener(M, _toQName(V.simpleName.toString()))));
          else list.add(new _Getter(_toQName(V.simpleName.toString()), dynamic, _getListener(M, _toQName(V.simpleName.toString()))));
        }
    }
  );
}

_Getter _getListener(mirrors.ClassMirror M, String propertyName) {
  final String listenerName = 'on${propertyName[0].toUpperCase()}${propertyName.substring(1)}Changed';
  _Getter listener;
  
  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isGetter && _toQName(V.simpleName.toString()) == listenerName) {
          if (V.returnType.hasReflectedType) listener = new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, null);
          else listener = new _Getter(_toQName(V.simpleName.toString()), dynamic, null);
        }
    }
  );
  
  return listener;
}

void _fillSetters(mirrors.ClassMirror M, List<_IInvokable> list, List<_IInvokable> lookup) {
  M.instanceMembers.forEach(
    (Symbol S, mirrors.MethodMirror V) {
      if (!V.isPrivate)
        if (V.isSetter) {
          _IInvokable getter = lookup.firstWhere(
            (_IInvokable I) => (I.name == _toQName(V.simpleName.toString())),
            orElse: () => null
          );
          if (getter != null) list.add(new _Setter(getter.name, getter.expectedType));
          else {
            if (V.parameters.first.type.hasReflectedType) list.add(new _Setter(_toQName(V.simpleName.toString()), V.parameters.first.type.reflectedType));
            else list.add(new _Setter(_toQName(V.simpleName.toString()), dynamic));
          }
        }
    }
  );
}

abstract class _IInvokable {
  
  String name;
  Type expectedType;
  
}

class _Getter implements _IInvokable {
  
  String name;
  Type expectedType;
  _Getter listener;
  
  _Getter(this.name, this.expectedType, this.listener) {
    if (listener != null) print(listener.name);
  }
  
}

class _Setter implements _IInvokable {
  
  String name;
  Type expectedType;
  
  _Setter(this.name, this.expectedType) {
    //print('$name $expectedType');
  }
  
}

class _Method implements _IInvokable {
  
  String name;
  Type expectedType;
  
  _Method(this.name, this.expectedType);
  
}