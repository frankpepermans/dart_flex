part of dart_flex;

class ClassFactory<T> {

  Function _constructorMethod;

  Function get constructorMethod => _constructorMethod;

  String _library;

  String get library => _library;

  String _className;

  String get className => _className;

  ClassFactory({String library: null, String className: null, Function constructorMethod: null}) {
    _library = library;
    _className = className;
    _constructorMethod = constructorMethod;

  }

  T immediateInstance() => _constructorMethod();

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

  Future<T> _createFutureInstance() {
    Completer<T> completer = new Completer<T>();

    completer.complete(_constructorMethod());

    return completer.future;
  }
}



