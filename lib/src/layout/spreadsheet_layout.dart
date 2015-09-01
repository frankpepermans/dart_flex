part of dart_flex;

class SpreadsheetLayout extends HorizontalLayout implements ILayout {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // lockIndex
  //---------------------------------
  
  int _lockIndex = -1;
  
  int get lockIndex => _lockIndex;
  set lockIndex(int value) {
    if (value != _lockIndex) {
      _lockIndex = value;
    }
  }
  
  //---------------------------------
  // lockIndexPosition
  //---------------------------------
  
  int _lockIndexPosition = 0;
  
  int get lockIndexPosition => _lockIndexPosition;
  set lockIndexPosition(int value) {
    if (value != _lockIndexPosition) {
      _lockIndexPosition = value;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  SpreadsheetLayout({bool constrainToBounds: true}) : super(constrainToBounds: constrainToBounds);

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void doLayout(int width, int height, int pageItemSize, int pageOffset, int pageSize, List<ComponentLayout> elements) {
    Component element;
    int percWidth = width;
    final int percWidthFloored = (pageItemSize == 0) ? 0 : (pageOffset ~/ pageItemSize * pageItemSize);
    int offset = _useVirtualLayout ? percWidthFloored : 0;
    int w, h, sx, i;
    int staticElmLen = 0;
    int lockIndexOffset = _lockIndexPosition;
    final int len = elements.length;
    
    for (i=0; i<len; i++) {
      element = elements[i] as Component;
      
      element.reflowManager.invalidateCSS(element.control, 'position', 'absolute');

      if (!element.includeInLayout) {
        staticElmLen++;
      } else if (
          (element.percentWidth == 0.0) &&
          (element.width > 0)
      ) {
        percWidth -= element.width;

        staticElmLen++;
      }
    }

    sx = elements.length - staticElmLen;

    percWidth -= staticElmLen * _gap;
    
    for (i=0; i<len; i++) {
      element = elements[i];
      
      w = h = 0;
      
      if (element.includeInLayout) {
        if (element.percentWidth > 0.0) w = (element.percentWidth * .01 * (percWidth - _gap * (sx - 1)) ~/ sx) - element.paddingLeft - element.paddingRight;
        else if (element.width > 0) w = element.width - element.paddingLeft - element.paddingRight;

        if (element.percentHeight > 0) h = (height * element.percentHeight) ~/ 100 - element.paddingTop - element.paddingBottom;
        else if (element.height > 0) h = element.height - element.paddingTop - element.paddingBottom;

        if (w == null) w = 0;
        if (h == null) h = 0;
        
        if (i < _lockIndex) {
          element.x = lockIndexOffset;
          
          lockIndexOffset += element._width;
          
          element.reflowManager.invalidateCSS(element._control, 'z-index', '${100 + _lockIndex}');
        } else {
          if (
              (pageSize == 0) ||
              ((offset + w) <= pageSize)
          ) {
            if (_align == 'left') element.x = offset + element.paddingLeft;
            else if (_align == 'right') element.x = width - offset - element.paddingLeft - element.paddingRight - element.width;
          } else element.x = element.paddingLeft;
          
          element.reflowManager.invalidateCSS(element._control, 'z-index', '0');
        }

        if (_constrainToBounds && (h > 0)) element.y = ((height * .5) - (h * .5) + element.paddingTop).toInt();

        if (element.autoSize) element.width = w;

        if (_constrainToBounds && element.autoSize) element.height = h;
        
        _layoutWidth = element.x + element.width;
        _layoutHeight = element.y + element.height;

        offset += w + _gap + element.paddingLeft + element.paddingRight;
      } else if (element.visible) {
        element.x = element.paddingLeft;
        element.y = element.paddingTop;
      } else {
        element.x = offset + element.paddingLeft;
        element.y = element.paddingTop;
      }
    }
  }

}



