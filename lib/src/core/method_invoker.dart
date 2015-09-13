part of dart_flex;

class MethodInvoker {
  
  final ReflowManager reflowManager = new ReflowManager();
  final dynamic owner;
  final String id;
  final Function method;
  List arguments;
  
  MethodInvoker.delayedSingle(this.owner, this.id, this.method, this.arguments) {
    reflowManager.scheduleMethod(this, forceSingleExecution: true);
  }
  
  MethodInvoker.delayedNonSingle(this.owner, this.id, this.method, this.arguments) {
    reflowManager.scheduleMethod(this, forceSingleExecution: false);
  }
  
  dynamic invoke() {
    if (arguments.isNotEmpty) return Function.apply(method, arguments);
    
    return method();
  }
  
}