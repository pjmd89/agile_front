import 'dart:io';

class MainRoutesGenerator {
  final String libRoot;
  MainRoutesGenerator({this.libRoot = 'lib'});

  void generateMainRoutesFromSchema(Map<String, dynamic> schema) {
    print('Generando archivo main.dart de rutas...');
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    final usecaseTypes = types.where((t) =>
      t is Map &&
      t['description'] is String &&
      (t['description'] as String).contains('-usecase')
    ).toList();
    if (usecaseTypes.isEmpty) {
      print('No se encontraron types con "-usecase" en la descripción.');
      return;
    }
    final outDir = Directory('$libRoot/src/presentation/core/navigation/routes');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
      print('  + Carpeta creada: \\${outDir.path}');
    }
    // --- Generar main.dart con el patrón solicitado ---
    final mainFile = File('${outDir.path}/main.dart');
    final buffer = StringBuffer();
    buffer.writeln("import 'package:go_router/go_router.dart';");
    buffer.writeln("import '/src/presentation/core/templates/basic/main.dart';");
    // Imports de cada archivo de rutas
    for (final type in usecaseTypes) {
      final name = type['name'] as String;
      buffer.writeln("import '${name.toLowerCase()}_routes.dart';");
    }
    buffer.writeln();
    // ShellRoute principal
    final shellRouteName = 'userShellRoute';
    buffer.writeln('ShellRoute $shellRouteName = ShellRoute(');
    buffer.writeln('  builder: (context, state, child) {');
    buffer.writeln('    return BasicTemplate(child: child);');
    buffer.writeln('  },');
    buffer.writeln('  routes: [');
    for (final type in usecaseTypes) {
      final typeLower = (type['name'] as String).toLowerCase();
      buffer.writeln('    ...${typeLower}Routes,');
    }
    buffer.writeln('  ],');
    buffer.writeln(');\n');
    // GoRouter
    buffer.writeln('GoRouter templateRouter = GoRouter(');
    buffer.writeln('  initialLocation: "/",');
    buffer.writeln('  routes: [');
    buffer.writeln('    $shellRouteName');
    buffer.writeln('  ],');
    buffer.writeln(');');
    if (!mainFile.existsSync()) {
      mainFile.writeAsStringSync(buffer.toString());
      print('  + Archivo generado: ${mainFile.path}');
    }
  }
}