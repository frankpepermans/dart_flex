part of dartflex;

class ClassFactory {

  Function _constructorMethod;

  Function get constructorMethod => _constructorMethod;

  Object _library;

  Object get library => _library;

  Object _className;

  Object get className => _className;

  ClassFactory({String library: null, String className: null, Function constructorMethod: null}) {
    _library = library;
    _className = className;
    _constructorMethod = constructorMethod;

  }

  Object immediateInstance() {
    return _constructorMethod();
  }

  /*Future futureInstance() {
    if (_constructorMethod != null) {
      return _createFutureInstance();
    } else {
      MirrorSystem mirrorSystem = currentMirrorSystem();
      LibraryMirror libraryMirror = mirrorSystem.libraries[_library];
      ClassMirror classMirror = libraryMirror.classes[_className];

      return classMirror.newInstanceAsync('', []);
    }
  }*/

  Future _createFutureInstance() {
    Completer completer = new Completer();

    completer.complete(_constructorMethod());

    return completer.future;
  }
}



