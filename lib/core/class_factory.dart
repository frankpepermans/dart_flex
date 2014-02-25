part of dart_flex;

class ClassFactory<T extends IUIWrapper> {
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  Function _constructorMethod;

  Function get constructorMethod => _constructorMethod;
  
  List<dynamic> _constructorArguments;

  List<dynamic> get constructorArguments => _constructorArguments;

  String _library;

  String get library => _library;

  String _className;

  String get className => _className;
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

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

  /*Future<T> _createFutureInstance() {
    Completer<T> completer = new Completer<T>();

    completer.complete(Function.apply(_constructorMethod, _constructorArguments));

    return completer.future;
  }*/
}

class ItemRendererFactory<T extends IItemRenderer> extends ClassFactory {
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  InvalidHandler _validationHandler;

  InvalidHandler get validationHandler => _validationHandler;
  
  InactiveHandler _inactiveHandler;

  InactiveHandler get inactiveHandler => _inactiveHandler;
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  @override
  T immediateInstance() {
    final T renderer = Function.apply(_constructorMethod, _constructorArguments);
    
    renderer.inactiveHandler = _inactiveHandler;
    renderer.validationHandler = _validationHandler;
    
    return renderer;
  }
  
  ItemRendererFactory({String library: null, String className: null, Function constructorMethod: null, List<dynamic> constructorArguments: const <dynamic>[], InvalidHandler validationHandler: null, InactiveHandler inactiveHandler: null}) : super(library: library, className: className, constructorMethod: constructorMethod, constructorArguments: constructorArguments) {
    _validationHandler = validationHandler;
    _inactiveHandler = inactiveHandler;
  }
  
}

