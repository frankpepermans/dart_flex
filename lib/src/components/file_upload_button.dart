part of dart_flex;

class FileUploadButton extends Button {
  
  @event Stream<FrameworkEvent> onContentChanged;
  
  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------
  
  FileUploadInputElement _fileUploadInput;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // fileName
  //---------------------------------

  String _fileName;

  String get fileName => _fileName;
  
  //---------------------------------
  // content
  //---------------------------------

  String _content;

  String get content => _content;
  
  //---------------------------------
  // raw
  //---------------------------------

  Blob _raw;

  Blob get raw => _raw;
  
  //---------------------------------
  // accept
  //---------------------------------

  String _accept;

  String get accept => _accept;
  set accept(String value) {
    if (value != _accept) {
      _accept = value;

      if (_fileUploadInput != null) _fileUploadInput.accept = value;
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  FileUploadButton({String elementId: null}) : super(elementId: elementId) {
    _className = 'FileUploadButton';
  }

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    _fileUploadInput = new FileUploadInputElement()
    ..style.opacity = '0.0'
    ..multiple = false
    ..accept = _accept
    ..onChange.listen(_fileUpload_selectHandler);
    
    onButtonClick.listen(
        (_) => _fileUploadInput.click()
    );
    
    _autoSize = true;
    
    super.createChildren();
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _fileUpload_selectHandler(Event event) {
    FileReader fileReader = new FileReader();
    
    fileReader.onLoadEnd.listen(
      (ProgressEvent event) {
        _content = fileReader.result as String;
        
        notify('contentChanged');
      }
    );
    
    _raw = _fileUploadInput.files.first;
    _fileName = _fileUploadInput.files.first.name;
    
    fileReader.readAsText(_fileUploadInput.files.first);
  }
}