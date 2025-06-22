import 'dart:io';

class RouteGenerator {
  final String libRoot;
  RouteGenerator({this.libRoot = 'lib'});

  void generateRoutesFromSchema(Map<String, dynamic> schema) {
    print('Generando archivos de rutas...');
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    final usecaseTypes = types.where((t) =>
      t is Map &&
      t['description'] is String &&
      (t['description'] as String).contains('-usecase')
    );
    if (usecaseTypes.isEmpty) {
      print('No se encontraron types con "-usecase" en la descripción.');
      return;
    }
    final outDir = Directory('$libRoot/src/presentation/core/navigation/routes');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
      print('  + Carpeta creada: \\${outDir.path}');
    }
    for (final type in usecaseTypes) {
      final name = type['name'] as String;
      final capName = _capitalize(name);
      final file = File('${outDir.path}/${name.toLowerCase()}_routes.dart');
      if (!file.existsSync()) {
        file.writeAsStringSync('''import 'package:agile_front/agile_front.dart';
import 'package:go_router/go_router.dart';
import '/src/presentation/pages/$capName/read/main.dart';
import '/src/presentation/pages/$capName/create/main.dart';
import '/src/presentation/pages/$capName/delete/main.dart';
import '/src/presentation/pages/$capName/update/main.dart';

final List<GoRoute> ${name.toLowerCase()}Routes = [
  GoRoute(
    path: '/${name.toLowerCase()}',
    pageBuilder: (context, state) => CustomSlideTransition(
      context: context, 
      state: state, 
      child: const ${capName}Page()
    ),
    routes: [
      GoRoute(
        path: 'create',
        pageBuilder: (context, state) => CustomDialogPage(
          context: context, 
          state: state, 
          child: const ${capName}CreatePage()
        ),
      ),
      GoRoute(
        path: 'update/:id',
        pageBuilder: (context, state) => CustomDialogPage(
          context: context, 
          state: state, 
          child: ${capName}UpdatePage(
            id: state.pathParameters['id']!
          )
        )
      ),
      GoRoute(
        path: 'delete/:id',
        pageBuilder: (context, state) => CustomDialogPage(
          context: context, 
          state: state, 
          child: ${capName}DeletePage(
            id: state.pathParameters['id']!
          )
        )
      )
    ]
  )
];
''');
        print('    + Archivo generado: \\${file.path}');
      }
    }
  }
}
String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);