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
      // CRUD: create, read, update, delete
      final crudParts = ['create', 'read', 'update', 'delete'];
      for (final crud in crudParts) {
        final fileName = '${crud}_${name.toLowerCase()}_usecase.dart';
        final className =
            '${_capitalize(crud)}${_capitalize(name)}Usecase';
        final file = File('${outDir.path}/$fileName');
        if (!file.existsSync()) {
          file.writeAsStringSync('''
import '/src/domain/operation/fields_builders/main.dart';
import '/src/domain/operation/main.dart';
import 'package:agile_front/infraestructure/usecase.dart';

class $className implements UseCase {
  $className();
  @override
  String build() {
    // TODO: Implementar lógica de $crud para $name
    return '';
  }
}
''');
          print('    + Archivo generado: \\${file.path}');
        }
      }
    }
  }

  // Puedes agregar métodos auxiliares para generar archivos, carpetas, etc.
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
