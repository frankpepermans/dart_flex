part of dart_flex;

abstract class IAccordionHeaderItemRenderer extends IItemRenderer {
  
}

class AccordionHeaderItemRenderer<D extends dynamic> extends LabelItemRenderer<D> implements IAccordionHeaderItemRenderer {
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  AccordionHeaderItemRenderer({String elementId: null}) : super(elementId: null) {
    className = 'AccordionHeaderItemRenderer';
  }

  static AccordionHeaderItemRenderer construct() => new AccordionHeaderItemRenderer();

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
}