// CLI principal para el generador de proyectos GraphQL
// Aquí se implementarán los comandos para generar la estructura, modelos, routers, etc.

import 'package:args/args.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../lib/src/core/graphql_introspection_service.dart';
import '../lib/src/core/model_generator.dart';
import '../lib/src/core/operation_generator.dart';
import '../lib/src/core/builder_generator.dart';

void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addOption(
          'lib-root',
          abbr: 'l',
          help: 'Carpeta raíz de lib para la estructura generada',
        )
        ..addCommand('init')
        ..addCommand('generate');

  final argResults = parser.parse(arguments);
  final libRoot = argResults['lib-root'] ?? 'lib';

  if (argResults.command == null) {
    print('Bienvenido al generador de proyectos GraphQL!');
    print('Comandos disponibles:');
    print('  init      Inicializa la estructura base de un nuevo proyecto');
    print(
      '  generate  Genera modelos, routers y carpetas a partir de un esquema GraphQL',
    );
    return;
  }

  switch (argResults.command!.name) {
    case 'init':
      print('Inicializando estructura base del proyecto...');
      _createBaseStructure(libRoot);
      //_copyBaseTemplates(libRoot);
      break;
    case 'generate':
      print(
        'Generando modelos, routers y carpetas a partir del esquema GraphQL...',
      );
      if (argResults.command!.arguments.isEmpty) {
        print('Por favor, proporciona la URL del endpoint GraphQL. Ejemplo:');
        print('  dart run bin/core_graphql_cli.dart generate <url>');
        return;
      }
      final endpointUrl = argResults.command!.arguments.first;
      await _generateFromGraphQL(endpointUrl, libRoot);
      break;
    default:
      print(
        'Comando no reconocido. Usa --help para ver los comandos disponibles.',
      );
  }
}

void _createBaseStructure(String libRoot) {
  final directories = [
    '$libRoot/src/domain/entities',
    '$libRoot/src/domain/usecases',
    '$libRoot/src/infraestructure/services',
    '$libRoot/src/infraestructure/persistence',
    '$libRoot/src/infraestructure/utils',
    '$libRoot/src/presentation/core/themes',
    '$libRoot/src/presentation/core/templates',
    '$libRoot/src/presentation/core/navigation',
    '$libRoot/src/presentation/pages',
    '$libRoot/src/presentation/widgets',
    '$libRoot/src/presentation/providers',
    '$libRoot/src/i18n',
    'test',
  ];

  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('  + Carpeta creada: $dir');
    }
  }

  final files = {
    '$libRoot/core_graphql.dart':
        """// Archivo principal de exportación del core\nlibrary core_graphql;\n""",
    '$libRoot/src/core/app_router.dart':
        '// TODO: Implementar app_router.dart\n',
    '$libRoot/src/core/datasource_base.dart':
        '// TODO: Implementar datasource_base.dart\n',
    '$libRoot/src/core/repository_base.dart':
        '// TODO: Implementar repository_base.dart\n',
    '$libRoot/src/core/theme_manager.dart':
        '// TODO: Implementar theme_manager.dart\n',
    '$libRoot/src/core/template_manager.dart':
        '// TODO: Implementar template_manager.dart\n',
    '$libRoot/src/core/error_manager.dart':
        '// TODO: Implementar error_manager.dart\n',
    '$libRoot/src/core/logger.dart': '// TODO: Implementar logger.dart\n',
    '$libRoot/src/core/config.dart': '// TODO: Implementar config.dart\n',
    '$libRoot/src/core/providers/auth_provider.dart':
        '// TODO: Implementar auth_provider.dart\n',
  };
/*
  files.forEach((path, content) {
    final file = File(path);
    // Asegura que el directorio padre exista antes de crear el archivo
    Directory(file.parent.path).createSync(recursive: true);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      print('  + Archivo creado: $path');
    }
  });
  */

  print('Estructura base creada correctamente.');
}

void _copyBaseTemplates(String libRoot) {
  final templateDir = Directory('templates/base');
  final destDir = Directory('$libRoot/src/core');

  if (!templateDir.existsSync()) {
    print('No se encontró la carpeta de templates/base.');
    return;
  }

  for (final file in templateDir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      final fileName = p.basename(file.path);
      final destPath = p.join(destDir.path, fileName);
      file.copySync(destPath);
      print('  + Archivo base copiado: $destPath');
    }
  }
}

Future<void> _generateFromGraphQL(String endpointUrl, String libRoot) async {
  print('Realizando introspección de esquema en: $endpointUrl');
  final introspector = GraphQLIntrospectionService();
  final modelGenerator = ModelGenerator(libRoot: libRoot);
  final builderGenerator = BuilderGenerator(libRoot: libRoot);
  final operationGenerator = OperationGenerator(libRoot: libRoot);
  try {
    final schema = await introspector.fetchSchema(endpointUrl); // Map con 'types' y 'directives'
    modelGenerator.generateModelsFromSchema(schema);
    builderGenerator.generateBuildersFromTypes(schema['types'] as List);
    operationGenerator.generateOperationsFromSchema({'types': schema['types']});
  } catch (e) {
    print('Error durante la introspección/generación: $e');
  }
}
