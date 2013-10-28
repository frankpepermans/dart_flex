part of dart_flex;

class UpdateManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  final UIWrapper _owner;
  final ReflowManager _reflowManager = new ReflowManager();

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  UpdateManager(this._owner);

  //-----------------------------------
  //
  // Operator overloads
  //
  //-----------------------------------

  void operator >(Function handler) => _reflowManager.scheduleMethod(_owner, handler, [], forceSingleExecution: true);
}
