// CLI principal para el generador de proyectos GraphQL
// Aquí se implementarán los comandos para generar la estructura, modelos, routers, etc.

import 'package:agile_front/src/core/gql_error_arb_generator_http.dart';
import 'package:agile_front/src/core/usecase_generator.dart';
import 'package:args/args.dart';
import 'dart:io';
import '../lib/src/core/graphql_introspection_service.dart';
import '../lib/src/core/model_generator.dart';
import '../lib/src/core/operation_generator.dart';
import '../lib/src/core/builder_generator.dart';
import '../lib/src/core/templates/notifier/locale_notifier.dart';
import '../lib/src/core/templates/notifier/gql_notifier.dart';
import '../lib/src/core/templates/notifier/loading_notifier.dart';
import '../lib/src/core/templates/locales/app_en.arb.dart';
import '../lib/src/core/templates/locales/app_es.arb.dart';
import '../lib/src/core/templates/locales/l10n.yaml.dart';
import '../lib/src/core/templates/themes/purple.dart';
import '../lib/src/core/templates/themes/teal.dart';
import '../lib/src/core/templates/notifier/theme_brightness_notifier.dart';
import '../lib/src/core/templates/templates/main_template.dart';
import '../lib/src/core/templates/navigation/main_navigation.dart';
import '../lib/src/core/templates/main_flutter.dart';
import '../lib/src/core/templates/enviromnents/main.dart';
import '../lib/src/core/templates/enviromnents/dev.json.dart';
import '../lib/src/core/templates/enviromnents/test.json.dart';
import '../lib/src/core/templates/enviromnents/prod.json.dart';
import '../lib/src/core/templates/enviromnents/stag.json.dart';
import '../lib/src/core/templates/vscode/launch.json.dart';
import '../lib/src/core/templates/widgets/loading.dart';


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
    '$libRoot/l10n',
    '$libRoot/src/domain/entities',
    '$libRoot/src/domain/usecases',
    '$libRoot/src/infraestructure/services',
    '$libRoot/src/infraestructure/persistence',
    '$libRoot/src/infraestructure/utils',
    '$libRoot/src/infraestructure/config',
    '$libRoot/src/presentation/core/themes',
    '$libRoot/src/presentation/core/templates',
    '$libRoot/src/presentation/core/navigation',
    '$libRoot/src/presentation/core/navigation/routes',
    '$libRoot/src/presentation/core/navigation/appbar',
    '$libRoot/src/presentation/pages',
    '$libRoot/src/presentation/widgets',
    '$libRoot/src/presentation/providers',
    '$libRoot/src/i18n',
    'test',
    '.env',
    '.vscode'
  ];

  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('  + Carpeta creada: $dir');
    }
  }

  final l10nDir = Directory('$libRoot/l10n');
  if (!l10nDir.existsSync()) {
    l10nDir.createSync(recursive: true);
  }

  // Copiar template de locale_notifier.dart.template a providers/locale_notifier.dart
  
  
  var files = {
    '${libRoot}/l10n/app_es.arb': appEsArb,
    '${libRoot}/l10n/app_en.arb': appEnArb,
    'l10n.yaml': appL10n,
    '.env/dev.json': devEnvironment,
    '.env/prod.json': prodEnvironment,
    '.env/stag.json': stagEnvironment,
    '.env/test.json': testEnvironment,
    '.vscode/launch.json': vscodeLaunchJson,
    '${libRoot}/src/infraestructure/config/env.dart': environment,
    '${libRoot}/src/presentation/providers/gql_notifier.dart': appGqlNotifier,
    '${libRoot}/src/presentation/providers/locale_notifier.dart': appLocaleNotifier,
    '${libRoot}/src/presentation/providers/loading_notifier.dart': loadingNotifier,
    '${libRoot}/src/presentation/providers/theme_brightness_notifier.dart': themeBrightnessNotifier,
    '${libRoot}/src/presentation/core/themes/purple.dart': themePurple,
    '${libRoot}/src/presentation/core/themes/teal.dart': themeTeal,
    '${libRoot}/src/presentation/core/templates/main.dart': mainTemplate,
    '${libRoot}/src/presentation/core/navigation/routes/main.dart': mainNavigation,
    '${libRoot}/src/presentation/widgets/loading/main.dart': loadingWidget,
    '${libRoot}/main.dart': mainFlutter,
    
  };

  files.forEach((path, content) {
    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      print('  + Archivo creado: ${file.path}');
    }
  });
  

  print('Estructura base creada correctamente.');
}

Future<void> _generateFromGraphQL(String endpointUrl, String libRoot) async {
  print('Realizando introspección de esquema en: $endpointUrl');
  final introspector = GraphQLIntrospectionService();
  final modelGenerator = ModelGenerator(libRoot: libRoot);
  final builderGenerator = BuilderGenerator(libRoot: libRoot);
  final operationGenerator = OperationGenerator(libRoot: libRoot);
  final useCaseGenerator = UseCaseGenerator(libRoot: libRoot);
  final pageGenerator = PageGenerator(libRoot: libRoot);
  final gqlErrorArbGenerator = GqlErrorArbGenerator(arbRoot: '$libRoot/src/i18n');
  try {
    final schema = await introspector.fetchSchema(endpointUrl); // Map con 'types' y 'directives'
    modelGenerator.generateModelsFromSchema(schema);
    builderGenerator.generateBuildersFromTypes(schema['types'] as List);
    operationGenerator.generateOperationsFromSchema({'types': schema['types']});
    useCaseGenerator.generateUseCasesFromSchema(schema);
    pageGenerator.generatePagesFromSchema(schema);
    gqlErrorArbGenerator.generateArbFromSchema(endpointUrl,schema);
    
  } catch (e) {
    print('Error durante la introspección/generación: $e');
  }
}
