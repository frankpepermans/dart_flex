part of dart_flex;

class FrameworkEvent<T> {

  //-----------------------------------
  //
  // Public properties
  //
  //-----------------------------------

  //-----------------------------------
  // ident
  //-----------------------------------

  String _ident;

  String get ident => _ident;

  //-----------------------------------
  // type
  //-----------------------------------

  String _type;

  String get type => _type;

  //-----------------------------------
  // relatedObject
  //-----------------------------------

  T _relatedObject;

  T get relatedObject => _relatedObject;

  //-----------------------------------
  // currentTarget
  //-----------------------------------

  IFrameworkEventDispatcher _currentTarget;

  IFrameworkEventDispatcher get currentTarget => _currentTarget;
  set currentTarget(IFrameworkEventDispatcher value) => _currentTarget = value;

  //-----------------------------------
  //
  // Factories
  //
  //-----------------------------------

  factory FrameworkEvent(String type, {T relatedObject: null}) => new FrameworkEvent.construct('FrameworkEvent', type, relatedObject: relatedObject);

  //-----------------------------------
  //
  // Constructor
  //
  //-----------------------------------

  FrameworkEvent.construct(String ident, String type, {T relatedObject: null}) {
    _ident = ident;
    _type = type;
    _relatedObject = relatedObject;
  }
}