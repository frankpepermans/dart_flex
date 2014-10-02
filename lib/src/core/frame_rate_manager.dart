part of dart_flex;

class FrameManager {
  
  StreamController C;
  Stream S;
  int fps = 30;
  int tick = 0;
  
  int _lastFrame = 0;
  
  //---------------------------------
  //
  // Singleton Constructor
  //
  //---------------------------------
  
  FrameManager._internal() {
    C = new StreamController();
    
    final StreamTransformer transformer = new StreamTransformer.fromHandlers(handleData: (int C, EventSink sink) {
      final Frame enterFrame = new EnterFrame(C);
      final Frame exitFrame = new ExitFrame(C);
      
      sink.add(enterFrame);
      sink.add(exitFrame);
    });
    
    S = C.stream.transform(transformer).asBroadcastStream();
    
    nextFrame();
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  static FrameManager _instance;

  factory FrameManager() {
    if (_instance != null) return _instance;
    
    _instance = new FrameManager._internal();
    
    return _instance;
  }
  
  void nextFrame() {
    window.animationFrame.then(
      (double T) {
        final double interval = 1000 / fps;
        final int currentFrame = T ~/ interval;
        
        if (currentFrame > _lastFrame) {
          _lastFrame = tick;
          
          C.add(++tick);
        }
        
        nextFrame();
      }
    );
  }
  
}

abstract class Frame {
  
  final int count;
  
  Frame(this.count);
  
}

class EnterFrame extends Frame {
  
  EnterFrame(int count) : super(count);
  
  String toString() => 'enterFrame: $count';
}

class ExitFrame extends Frame {
  
  ExitFrame(int count) : super(count);
  
  String toString() => 'exitFrame: $count';
  
}