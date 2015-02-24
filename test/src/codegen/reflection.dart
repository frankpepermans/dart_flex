part of codegen;

class Reflection {

  Map<Symbol, Map<String, List<_IInvokable>>> createGraph(String libraryUri) {
    final Map<Symbol, Map<String, List<_IInvokable>>> uiList = <Symbol, Map<String, List<_IInvokable>>>{};

    mirrors.currentMirrorSystem().libraries.forEach(
      (Uri uri, mirrors.LibraryMirror M) {
          if (uri.path == libraryUri) {
            M.declarations.forEach(
              (Symbol S, mirrors.DeclarationMirror D) {
                  if (D is mirrors.ClassMirror && extendsUIWrapper(D)) uiList[S] = createGraphForUIWrapper(D);
              }
            );
          }
       }
    );

    return uiList;
  }

  Map<String, List<_IInvokable>> createGraphForUIWrapper(mirrors.ClassMirror CM) {
    final Map<String, List<_IInvokable>> decl = <String, List<_IInvokable>>{};

    decl['methods'] = <_IInvokable>[];

    decl['getters'] = _fillGetters(CM);
    decl['setters'] = _fillSetters(CM, decl['getters']);

    return decl;
  }

  mirrors.InstanceMirror reflectInstance(dynamic instance) => mirrors.reflect(instance);

  bool extendsUIWrapper(mirrors.ClassMirror M) {
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

  bool extendsObservable(mirrors.ClassMirror M) {
    bool isObservableSubClass = false;
    mirrors.ClassMirror m = M;

    while (m.superclass != null) {
      if (m.superclass != null && m.superclass.simpleName.toString() == 'Symbol("Observable")') {
        isObservableSubClass = true;

        break;
      }

      m = m.superclass;
    }

    return isObservableSubClass;
  }

  bool extendsObservableList(mirrors.ClassMirror M) {
    bool isObservableSubClass = false;
    mirrors.ClassMirror m = M;

    while (m.superclass != null) {
      if (m.superclass != null && m.superclass.simpleName.toString() == 'Symbol("ObservableList")') {
        isObservableSubClass = true;

        break;
      }

      m = m.superclass;
    }

    return isObservableSubClass;
  }

  bool extendsObservableMap(mirrors.ClassMirror M) {
    bool isObservableSubClass = false;
    mirrors.ClassMirror m = M;

    while (m.superclass != null) {
      if (m.superclass != null && m.superclass.simpleName.toString() == 'Symbol("ObservableMap")') {
        isObservableSubClass = true;

        break;
      }

      m = m.superclass;
    }

    return isObservableSubClass;
  }

  // Private

  String _toQName(String symbolName) => symbolName.split('"')[1];

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