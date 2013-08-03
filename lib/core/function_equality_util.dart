part of dartflex;

class FunctionEqualityUtil {
  
  static bool _isDart = !identical(1, 1.0);

  static bool equals(Function functionA, Function functionB) {
    if (_isDart) {
      // dart VM does not currently support function equality checks
      return (functionA.toString() == functionB.toString());
    } else {
      // JS obviously does
      return (functionA == functionB);
    }
  }

}

