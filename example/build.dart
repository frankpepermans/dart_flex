import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

main() {
  /*Directory dir = new Directory('packages/dart_flex/components');
  
  Future<List<FileSystemEntity>> listing = dirContents(dir);
  
  listing.then(_directoryListingCompleteHandler);*/
  
  build(new Options().arguments, ['web/data_grid_web_component.html']);
}

void _directoryListingCompleteHandler(List<FileSystemEntity> result) {
  final Pattern regExpA = new RegExp('packages/dart_flex/components');
  final Pattern regExpC = new RegExp('_');
  String fileName;
  
  result.forEach(
    (File file) {
      fileName = file.path.split(
          regExpA
      ).last.replaceAll(regExpC, '-');
      
      if (fileName.length > 0) {
        _createXTag(fileName.substring(1)); 
      }
    }
  );
}

void _createXTag(String componentName) {
  final String xtagName = 'x-' + componentName;
  
  print(xtagName);
}

Future<List<FileSystemEntity>> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = new Completer();
  var lister = dir.list(recursive: false);
  lister.listen ( 
      (file) => files.add(file),
      // should also register onError
      onDone:   () => completer.complete(files)
      );
  return completer.future;
}
