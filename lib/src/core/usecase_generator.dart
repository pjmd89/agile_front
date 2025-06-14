import 'dart:io';

class UseCaseGenerator {
  final String libRoot;
  UseCaseGenerator({this.libRoot = 'lib'});

  void generateUseCasesFromSchema(Map<String, dynamic> schema) {
    print('Generando use cases...');
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    // Filtrar types que tengan en la descripción la cadena '-usecase'
    final usecaseTypes = types.where((t) =>
      t is Map &&
      t['description'] is String &&
      (t['description'] as String).contains('-usecase')
    );
    if (usecaseTypes.isEmpty) {
      print('No se encontraron types con "-usecase" en la descripción.');
      return;
    }
    for (final type in usecaseTypes) {
      final name = type['name'] as String;
      final outDir = Directory('$libRoot/src/domain/usecases/$name');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
        print('  + Carpeta creada: \\${outDir.path}');
      }
      // Aquí puedes agregar la lógica para generar los archivos del usecase
      // Por ejemplo, un archivo base:
      final file = File('${outDir.path}/${name.toLowerCase()}_usecase.dart');
      if (!file.existsSync()) {
        file.writeAsStringSync('// UseCase generado para $name\n');
        print('    + Archivo generado: \\${file.path}');
      }
    }
  }

  // Puedes agregar métodos auxiliares para generar archivos, carpetas, etc.
}
