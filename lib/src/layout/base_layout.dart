part of dart_flex;

abstract class ILayout {

  bool get useVirtualLayout;
  set useVirtualLayout(bool value);

  int get gap;
  set gap(int value);

  bool get constrainToBounds;
  set constrainToBounds(bool value);

  String get align;
  set align(String value);
  
  int get layoutWidth;
  int get layoutHeight;

  void doLayout(int width, int height, int pageItemSize, int pageOffset, int pageSize, List<IFlexLayout> elements);

}