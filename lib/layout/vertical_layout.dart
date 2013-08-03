part of dartflex;

class VerticalLayout implements ILayout {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // useVirtualLayout
  //---------------------------------

  bool _useVirtualLayout = false;

  bool get useVirtualLayout => _useVirtualLayout;
  set useVirtualLayout(bool value) {
    if (value != _useVirtualLayout) {
      _useVirtualLayout = value;
    }
  }

  //---------------------------------
  // gap
  //---------------------------------

  int _gap = 10;

  int get gap => _gap;
  set gap(int value) => _gap = value;

  //---------------------------------
  // constrainToBounds
  //---------------------------------

  bool _constrainToBounds = true;

  bool get constrainToBounds => _constrainToBounds;
  set constrainToBounds(bool value) => _constrainToBounds = value;
  
  //---------------------------------
  // align
  //---------------------------------

  String _align = 'top';

  String get align => _align;
  set align(String value) => _align = value;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  VerticalLayout({bool constrainToBounds: true}) {
    _constrainToBounds = constrainToBounds;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

  void doLayout(int width, int height, int pageItemSize, int pageOffset, int pageSize, List<IUIWrapper> elements) {
    UIWrapper element;
    int percHeight = height;
    final int pageHeightFloored = (pageItemSize == 0) ? 0 : pageOffset ~/ pageItemSize * pageItemSize;
    int offset = _useVirtualLayout ? pageHeightFloored : 0;
    int w, h, sx, i;
    int staticElmLen = 0;
    final int len = elements.length;
    
    for (i=0; i<len; i++) {
      element = elements[i];
      
      element.reflowManager.invalidateCSS(element.control, 'position', 'absolute');

      if (!element.includeInLayout) {
        staticElmLen++;
      } else if (
          (element.percentHeight == 0.0) &&
          (element.height > 0)
      ) {
        percHeight -= element.height;

        staticElmLen++;
      }
    }

    sx = elements.length - staticElmLen;

    percHeight -= staticElmLen * _gap;
    
    i = elements.length;
    
    for (i=0; i<len; i++) {
      element = elements[i];
      
      if (element.includeInLayout) {
        if (element.percentWidth > 0.0) {
          w = (width * element.percentWidth * .01).toInt() - element.paddingLeft - element.paddingRight;
        } else if (element.width > 0) {
          w = element.width - element.paddingLeft - element.paddingRight;
        }

        if (element.percentHeight > 0.0) {
          h = (element.percentHeight * .01 * (percHeight - _gap * (sx - 1)) / sx).toInt() - element.paddingTop - element.paddingBottom;
        } else if (element.height > 0) {
          h = element.height - element.paddingTop - element.paddingBottom;
        }

        w = (w == null) ? 0 : w;
        h = (h == null) ? 0 : h;

        if (_constrainToBounds) {
          element.x = (width * .5 - w * .5).toInt() + element.paddingLeft;
        }

        if (
            (pageSize == 0) ||
            ((offset + h) <= pageSize)
        ) {
          if (_align == 'top') {
            element.y = offset + element.paddingTop;
          } else if (_align == 'bottom') {
            element.y = height - offset - element.paddingTop - element.paddingBottom - element.height;
          }
        } else {
          element.y = element.paddingTop;
        }

        if (_constrainToBounds && element.autoSize) {
          element.width = w;
        }

        if (element.autoSize) {
          element.height = h;
        }

        offset += h + _gap + element.paddingTop + element.paddingBottom;
      } else {
        element.x = element.paddingLeft;
        element.y = element.paddingTop;
      }
    }
  }

}

