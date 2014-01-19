part of dart_flex;

abstract class ICallLater {
  
  UpdateManager get later;
  
}

abstract class CallLaterMixin implements ICallLater {
  
  //---------------------------------
  // later
  //---------------------------------

  UpdateManager _later;

  UpdateManager get later => _later;
  
}

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
