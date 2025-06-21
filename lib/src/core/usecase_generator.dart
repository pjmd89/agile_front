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
import 'package:agile_front/agile_front.dart' as af;
import 'package:gps_agile_front/src/domain/entities/main.dart';


class $className implements af.UseCase {
  final af.Operation _operation;
  final af.Service _conn;
  $className({
    required af.Operation operation,
    required af.Service conn,
  }) : _operation = operation,
      _conn = conn;

  @override
  build() {
    _conn.operation(operation: _operation, callback: callback);
  }
  callback(Object ob) {
    //final thisObject = ob as {YourEntityType};
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

class PageGenerator {
  final String libRoot;
  PageGenerator({this.libRoot = 'lib'});

  void generatePagesFromSchema(Map<String, dynamic> schema) {
    print('Generando páginas de presentación...');
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
      final outDir = Directory('$libRoot/src/presentation/pages/$name');
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
        print('  + Carpeta creada: \\${outDir.path}');
      }
      // CRUD: create, read, update, delete
      final crudParts = ['create', 'read', 'update', 'delete'];
      for (final crud in crudParts) {
        String classCrud = crud == 'read' ? '' : _capitalize(crud);
        String className = '${_capitalize(name)}${classCrud}Page';
        String fileName = crud == 'read'
            ? 'main.dart'
            : '${crud}_${name.toLowerCase()}_page.dart';
        final file = File('${outDir.path}/$fileName');
        if (!file.existsSync()) {
          file.writeAsStringSync('''import 'package:flutter/material.dart';

class $className extends StatefulWidget {
  const $className({super.key});

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
''');
          print('    + Archivo generado: \\${file.path}');
        }
      }
    }
  }
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
