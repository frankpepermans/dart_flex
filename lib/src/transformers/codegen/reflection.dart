part of dart_flex.codegen;

class Reflection {

  Map<Symbol, _LibraryPart> createGraph(String libraryUri) {
    final Map<Symbol, _LibraryPart> uiList = <Symbol, _LibraryPart>{};
    bool hasMatch = false;

    mirrors.currentMirrorSystem().libraries.forEach(
      (Uri uri, mirrors.LibraryMirror M) {
          if (uri.path == libraryUri) {
            hasMatch = true;
            
            M.declarations.forEach(
              (Symbol S, mirrors.DeclarationMirror D) {
                  if (D is mirrors.ClassMirror) uiList[S] = createGraphForUIWrapper(D);
              }
            );
          }
       }
    );
    
    if (!hasMatch) throw new ArgumentError('Library $libraryUri was not found');

    return uiList;
  }

  _LibraryPart createGraphForUIWrapper(mirrors.ClassMirror CM) {
    final List<_IInvokable> getters = _fillGetters(CM);

    return new _LibraryPart(CM, <_IInvokable>[], getters, _fillSetters(CM, getters));
  }

  mirrors.InstanceMirror reflectInstance(dynamic instance) => mirrors.reflect(instance);

  _Extends extendsWhat(mirrors.ClassMirror M) {
    const String uiWrapperSymbolName = 'Symbol("UIWrapper")';
    const String observableSymbolName = 'Symbol("Observable")';
    const String observableListSymbolName = 'Symbol("ObservableList")';
    const String observableMapSymbolName = 'Symbol("ObservableMap")';
    String simpleName;
    bool isUIWrapperSubClass = false;
    bool isObservableSubClass = false;
    bool isObservableListSubClass = false;
    bool isObservableMapSubClass = false;
    mirrors.ClassMirror m = M;

    while (m.superclass != null) {
      if (m.superclass != null) {
        simpleName = m.superclass.simpleName.toString();
        
        if (!isUIWrapperSubClass && simpleName == uiWrapperSymbolName) isUIWrapperSubClass = true;
        else if (!isObservableSubClass && simpleName == observableSymbolName) isObservableSubClass = true;
        else if (!isObservableListSubClass && simpleName == observableListSymbolName) isObservableListSubClass = true;
        else if (!isObservableMapSubClass && simpleName == observableMapSymbolName) isObservableMapSubClass = true;
      }

      m = m.superclass;
    }

    return new _Extends(isUIWrapperSubClass, isObservableSubClass, isObservableListSubClass, isObservableMapSubClass);
  }

  // Private

  String _toQName(String symbolName) => symbolName.split('"')[1];

  List<_IInvokable> _fillGetters(mirrors.ClassMirror M) {
    final List<_IInvokable> L = <_IInvokable>[];

    M.instanceMembers.forEach(
      (Symbol S, mirrors.MethodMirror V) {
        bool isReflectable = false;
        
        V.metadata.forEach(
          (mirrors.InstanceMirror IM) {
            if (IM.reflectee is ObservableProperty) isReflectable = true;
          }
        );
        
        if (!V.isPrivate)
          if (V.isGetter) {
            if (V.returnType.hasReflectedType) L.add(
                new _Getter(
                    _toQName(V.simpleName.toString()), V.returnType.reflectedType, _getListener(M, _toQName(V.simpleName.toString())), isReflectable
                )
            );
            else L.add(
                new _Getter(
                    _toQName(V.simpleName.toString()), dynamic, _getListener(M, _toQName(V.simpleName.toString())), isReflectable
                )
            );
        }
      }
    );

    return L;
  }

  List<_IInvokable> _fillSetters(mirrors.ClassMirror M, List<_IInvokable> getters) {
    final List<_IInvokable> L = <_IInvokable>[];

    M.instanceMembers.forEach(
      (Symbol S, mirrors.MethodMirror V) {
          if (!V.isPrivate)
            if (V.isSetter) {
              _IInvokable getter = getters.firstWhere(
                      (_IInvokable I) => ('${I.name}=' == _toQName(V.simpleName.toString())),
                  orElse: () => null
              );

              if (getter != null) L.add(new _Setter('${getter.name}=', getter.expectedType));
              else {
                if (V.parameters.first.type.hasReflectedType) L.add(new _Setter(_toQName(V.simpleName.toString()), V.parameters.first.type.reflectedType));
                else L.add(new _Setter(_toQName(V.simpleName.toString()), dynamic));
              }
          }
      }
    );

    return L;
  }

  _Getter _getListener(mirrors.ClassMirror M, String propertyName) {
    final String listenerName = 'on${propertyName[0].toUpperCase()}${propertyName.substring(1)}Changed';
    _Getter listener;

    M.instanceMembers.forEach(
      (Symbol S, mirrors.MethodMirror V) {
          if (!V.isPrivate)
            if (V.isGetter && _toQName(V.simpleName.toString()) == listenerName) {
              if (V.returnType.hasReflectedType) listener = new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, null, false);
              else listener = new _Getter(_toQName(V.simpleName.toString()), dynamic, null, false);
          }
      }
    );

    return listener;
  }

}