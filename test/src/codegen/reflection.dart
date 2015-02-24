part of codegen;

class Reflection {

  Map<Symbol, Map<String, List<_IInvokable>>> createGraph(String libraryUri) {
    final Map<Symbol, Map<String, List<_IInvokable>>> uiList = <Symbol, Map<String, List<_IInvokable>>>{};

    mirrors.currentMirrorSystem().libraries.forEach(
      (Uri uri, mirrors.LibraryMirror M) {
          if (uri.path == libraryUri) {
            M.declarations.forEach(
              (Symbol S, mirrors.DeclarationMirror D) {
                  if (D is mirrors.ClassMirror && _extendsUIWrapper(D)) {
                    Map<String, List<_IInvokable>> decl = <String, List<_IInvokable>>{};

                    decl['methods'] = <_IInvokable>[];

                    decl['getters'] = _fillGetters(D);
                    decl['setters'] = _fillSetters(D, decl['getters']);

                    uiList[S] = decl;
                  }
              }
            );
          }
       }
    );

    return uiList;
  }

  // Private

  String _toQName(String symbolName) => symbolName.split('"')[1];

  bool _extendsUIWrapper(mirrors.ClassMirror M) {
    bool isUIWrapperSubClass = false;
    mirrors.ClassMirror m = M;

    while (m.superclass != null) {
      if (m.superclass != null && m.superclass.simpleName.toString() == 'Symbol("UIWrapper")') {
        isUIWrapperSubClass = true;

        break;
      }

      m = m.superclass;
    }

    return isUIWrapperSubClass;
  }

  List<_IInvokable> _fillGetters(mirrors.ClassMirror M) {
    final List<_IInvokable> L = <_IInvokable>[];

    M.instanceMembers.forEach(
      (Symbol S, mirrors.MethodMirror V) {
          if (!V.isPrivate)
            if (V.isGetter) {
              if (V.returnType.hasReflectedType) L.add(new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, _getListener(M, _toQName(V.simpleName.toString()))));
              else L.add(new _Getter(_toQName(V.simpleName.toString()), dynamic, _getListener(M, _toQName(V.simpleName.toString()))));
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
              if (V.returnType.hasReflectedType) listener = new _Getter(_toQName(V.simpleName.toString()), V.returnType.reflectedType, null);
              else listener = new _Getter(_toQName(V.simpleName.toString()), dynamic, null);
          }
      }
    );

    return listener;
  }

}