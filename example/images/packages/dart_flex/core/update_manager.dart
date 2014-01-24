part of dart_flex;

abstract class ICallLater {
  
  UpdateManager get later;
  
}

abstract class CallLaterMixin implements ICallLater {
  
  //---------------------------------
  // later
  //---------------------------------
  
  UpdateManager _later;

  void set updateManager(UpdateManager value) {
    if (value != _later) _later = value;
  }
  
  UpdateManager get later => _later;
  
}

class UpdateManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  final dynamic _owner;
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
