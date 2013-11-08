part of dart_flex;

class ClassFactory<T extends UIWrapper> {

  Function _constructorMethod;

  Function get constructorMethod => _constructorMethod;
  
  List<dynamic> _constructorArguments;

  List<dynamic> get constructorArguments => _constructorArguments;

  String _library;

  String get library => _library;

  String _className;

  String get className => _className;

  ClassFactory({String library: null, String className: null, Function constructorMethod: null, List<dynamic> constructorArguments: const <dynamic>[]}) {
    _library = library;
    _className = className;
    _constructorMethod = constructorMethod;
    _constructorArguments = constructorArguments;
  }

  T immediateInstance() => Function.apply(_constructorMethod, _constructorArguments);

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

    completer.complete(Function.apply(_constructorMethod, _constructorArguments));

    return completer.future;
  }
}



