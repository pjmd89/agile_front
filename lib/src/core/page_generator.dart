import 'dart:io';

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
        final viewModelImport = "import './view_model.dart';";
        //final viewModelImport = "import '/src/presentation/pages/$name/$crud/view_model.dart';";
        final file = File('${crudDir.path}/main.dart');
        // Parámetros para update y delete
        String constructorParams = (crud == 'update' || crud == 'delete') ? '{super.key, required this.id}' : '{super.key}';
        String fieldId = (crud == 'update' || crud == 'delete') ? '  final String id;\n' : '';
        if (!file.existsSync()) {
          file.writeAsStringSync('''import 'package:flutter/material.dart';
$viewModelImport

class $className extends StatefulWidget {
  const $className($constructorParams);
$fieldId
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
String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);