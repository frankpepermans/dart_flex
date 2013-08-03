part of dartflex;

class UpdateManager {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  UIWrapper _owner;
  ReflowManager _reflowManager = new ReflowManager();

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  UpdateManager(UIWrapper owner) {
    _owner = owner;
  }

  //-----------------------------------
  //
  // Operator overloads
  //
  //-----------------------------------

  void operator >(Function handler) {
    _reflowManager.scheduleMethod(_owner, handler, [], forceSingleExecution: true);
  }
}
