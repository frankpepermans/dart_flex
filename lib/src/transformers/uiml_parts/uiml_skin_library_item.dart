part of dart_flex.build.uiml_transformer;

class UIMLSkinLibraryItem {
  
  final String ns, lib;
  final TransformLogger logger;
  
  UIMLSkinLibraryItem(this.logger, this.ns, this.lib);
  
  factory UIMLSkinLibraryItem.fromUri(TransformLogger logger, String ns, String uri) {
    final List<String> parts = uri.split('://');
    
    return new UIMLSkinLibraryItem(logger, ns, parts.last);
  }
  
  ClassMirror getClassMirror(String className) {
    final MirrorSystem mirrorSystem = currentMirrorSystem();
    
    mirrorSystem.libraries.values.forEach(
      (LibraryMirror M) {
        if (M.simpleName.toString().contains('dart_flex')) logger.info(M.simpleName.toString());
      }
    );return null;
    
    final LibraryMirror libraryMirror = mirrorSystem.libraries.values.firstWhere(
      (LibraryMirror M) => (M.simpleName.toString() == 'Symbol("${lib}")'),
      orElse: () => null
    );
    
    if (libraryMirror == null) logger.error('Could not locate library $lib');
    
    libraryMirror.declarations.values.forEach(
      (DeclarationMirror M) => logger.info(M.simpleName.toString())
    );return null;
    
    final ClassMirror classMirror = libraryMirror.declarations.values.firstWhere(
      (DeclarationMirror M) => (M.simpleName == className),
      orElse: () => null
    ) as ClassMirror;
    
    if (classMirror == null) logger.error('Could not locate class $className in library $lib');
    
    return classMirror;
  }
}