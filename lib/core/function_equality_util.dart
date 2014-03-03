part of dart_flex;

class FunctionEqualityUtil {
  
  static const bool _IS_DART = !identical(1, 1.0);

  static bool equals(Function functionA, Function functionB) {
    if (_IS_DART) {
      // dart VM does not currently support function equality checks
      return (functionA.toString().compareTo(functionB.toString()) == 0);
    } else {
      // JS obviously does
      return (functionA == functionB);
    }
  }

}

