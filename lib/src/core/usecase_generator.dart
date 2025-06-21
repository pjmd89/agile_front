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
      final typeDir = Directory('$libRoot/src/presentation/pages/$name');
      if (!typeDir.existsSync()) {
        typeDir.createSync(recursive: true);
        print('  + Carpeta creada: \\${typeDir.path}');
      }
      // CRUD: create, read, update, delete
      final crudParts = ['create', 'read', 'update', 'delete'];
      for (final crud in crudParts) {
        final crudDir = Directory('${typeDir.path}/$crud');
        if (!crudDir.existsSync()) {
          crudDir.createSync(recursive: true);
          print('    + Carpeta creada: \\${crudDir.path}');
        }
        final classCrud = crud == 'read' ? '' : _capitalize(crud);
        final className = '${_capitalize(name)}${classCrud}Page';
        final viewModelImport = "import '/src/presentation/pages/$name/$crud/view_model.dart';";
        final file = File('${crudDir.path}/main.dart');
        if (!file.existsSync()) {
          file.writeAsStringSync('''import 'package:flutter/material.dart';
$viewModelImport

class $className extends StatefulWidget {
  const $className({super.key});

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
  late ViewModel viewModel;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = ViewModel(context: context);
  }
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: viewModel, builder:  (context, child) {
      return Placeholder();
    });
  }
}
''');
          print('      + Archivo generado: \\${file.path}');
        }
        // Crear view_model.dart
        final viewModelFile = File('${crudDir.path}/view_model.dart');
        if (!viewModelFile.existsSync()) {
          viewModelFile.writeAsStringSync('''import 'package:agile_front/agile_front.dart';
import 'package:flutter/material.dart';
import '/src/presentation/providers/gql_notifier.dart';

class ViewModel extends ChangeNotifier {
  bool _loading = true;
  bool _error = false;
  final GqlConn _gqlConn;
  final BuildContext _context;
  bool get loading => _loading;
  bool get error => _error;

  set loading(bool newLoading) {
    _loading = newLoading;
    notifyListeners();
  }
  set error(bool value) {
    _error = value;
    notifyListeners();
  }
  ViewModel(
    {required BuildContext context}
  ) : _context = context,
      _gqlConn = context.read<GQLNotifier>().gqlConn;

  
}
''');
          print('      + Archivo generado: \\${viewModelFile.path}');
        }
      }
    }
  }
}

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
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/src/presentation/pages/$name/read/main.dart';
import '/src/presentation/pages/$name/create/main.dart';
import '/src/presentation/pages/$name/delete/main.dart';
import '/src/presentation/pages/$name/update/main.dart';
import '/src/presentation/core/templates/basic/main.dart';
import '/src/presentation/providers/locale_notifier.dart';

ShellRoute ${name.toLowerCase()}ShellRoute = ShellRoute(
  builder: (context, state, child){
    String locale = context.watch<AppLocaleNotifier>().locale;
    return Localizations.override(
      context: context,
      locale: Locale(locale),
      child: BasicTemplate(
        child: child
      )
    );
  },
  routes: [
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
          pageBuilder: (context, state) => CustomSlideTransition(
            context: context, 
            state: state, 
            child: const ${capName}CreatePage()
          )
        ),
        GoRoute(
          path: 'update/:id',
          pageBuilder: (context, state) => CustomSlideTransition(
            context: context, 
            state: state, 
            child: ${capName}UpdatePage(
              id: state.pathParameters['id']!
            )
          )
        ),
        GoRoute(
          path: 'delete/:id',
          pageBuilder: (context, state) => CustomSlideTransition(
            context: context, 
            state: state, 
            child: ${capName}DeletePage(
              id: state.pathParameters['id']!
            )
          )
        )
      ]
    )
  ]
);
''');
        print('    + Archivo generado: \\${file.path}');
      }
    }
  }
}

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
    final mainFile = File('${outDir.path}/main.dart');
    final buffer = StringBuffer();
    buffer.writeln("import 'package:go_router/go_router.dart';");
    // Imports de cada archivo de rutas
    for (final type in usecaseTypes) {
      final name = type['name'] as String;
      buffer.writeln("import '${name.toLowerCase()}_routes.dart';");
    }
    buffer.writeln();
    // Lista de shellRoutes
    final shellRoutes = usecaseTypes.map((type) => '${(type['name'] as String).toLowerCase()}ShellRoute').join(',\n    ');
    buffer.writeln('GoRouter templateRouter = GoRouter(');
    buffer.writeln('  initialLocation: "/",');
    buffer.writeln('  routes: [$shellRoutes],');
    buffer.writeln(');');
    if(!mainFile.existsSync()){
      mainFile.writeAsStringSync(buffer.toString());
      print('  + Archivo generado: ${mainFile.path}');
    }
  }
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
