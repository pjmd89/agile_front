// CLI principal para el generador de proyectos GraphQL
// Aquí se implementarán los comandos para generar la estructura, modelos, routers, etc.

import 'package:agile_front/src/core/gql_error_arb_generator_http.dart';
import 'package:agile_front/src/core/usecase_generator.dart';
import 'package:agile_front/src/core/route_generator.dart';
import 'package:agile_front/src/core/main_routes_generator.dart';
import 'package:agile_front/src/core/page_generator.dart';
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
import '../lib/src/core/templates/main_flutter.dart';
import '../lib/src/core/templates/pubspec.yaml.dart';
import '../lib/src/core/templates/enviromnents/main.dart';
import '../lib/src/core/templates/enviromnents/dev.json.dart';
import '../lib/src/core/templates/enviromnents/test.json.dart';
import '../lib/src/core/templates/enviromnents/prod.json.dart';
import '../lib/src/core/templates/enviromnents/stag.json.dart';
import '../lib/src/core/templates/vscode/launch.json.dart';
import '../lib/src/core/templates/widgets/loading.dart';
import '../lib/src/core/templates/templates/basic_template.dart';
import '../lib/src/core/templates/error/error_manager.dart';
import '../lib/src/core/templates/readme.md.dart';


void main(List<String> arguments) async {
  final parser =
      ArgParser()
        ..addOption(
          'lib-root',
          abbr: 'l',
          help: 'Carpeta raíz de lib para la estructura generada',
        )
        ..addCommand('init')
        ..addCommand('generate')
        ..addFlag('back', abbr: 'b', defaultsTo: false, help: 'Activa el modo back');

  final argResults = parser.parse(arguments);
  final libRoot = argResults['lib-root'] ?? 'lib';
  final isBack = argResults['back'] as bool;

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
      _createBaseStructure(libRoot, isBack);
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
      await _generateFromGraphQL(endpointUrl, libRoot, isBack);
      break;
    default:
      print(
        'Comando no reconocido. Usa --help para ver los comandos disponibles.',
      );
  }
}

void _createBaseStructure(String libRoot, bool isBack) {
  final directories = [
    '$libRoot/l10n',
    '$libRoot/src/domain/entities',
    '$libRoot/src/domain/usecases',
    '$libRoot/src/infraestructure/services',
    '$libRoot/src/infraestructure/persistence',
    '$libRoot/src/infraestructure/utils',
    '$libRoot/src/infraestructure/error',
    '$libRoot/src/infraestructure/config',
    '$libRoot/src/presentation/core/themes',
    '$libRoot/src/presentation/core/templates',
    '$libRoot/src/presentation/core/templates/basic/',
    '$libRoot/src/presentation/core/navigation',
    '$libRoot/src/presentation/core/navigation/routes',
    '$libRoot/src/presentation/core/navigation/appbar',
    '$libRoot/src/presentation/pages',
    '$libRoot/src/presentation/widgets',
    '$libRoot/src/presentation/widgets/loading',
    '$libRoot/src/presentation/providers',
    
    '$libRoot/src/i18n',
    'test',
    '.env',
    '.vscode'
  ];

  for (final dir in directories) {
    if(isBack && dir.contains('src/presentation/')) {
      continue; // No crear rutas si es modo back
    }
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
    '${libRoot}/src/presentation/core/templates/basic/main.dart': basicTemplate,
    '${libRoot}/src/presentation/widgets/loading/main.dart': loadingWidget,
    '${libRoot}/src/infraestructure/error/error_manager.dart': errorTemplate,
    '${libRoot}/main.dart': mainFlutter,
    'pubspec.yaml.example': pubSpec,
    'readme_agile_front.md': readme,
    
  };
  
  files.forEach((path, content) {
    if(isBack && path.contains('src/presentation/')) {
      return; // No crear archivos si es modo back
    }
    if(isBack && path.contains('${libRoot}/main.dart')) {
      return; // No crear archivos si es modo back
    }
    if(isBack && path.contains('pubspec.yaml.example')) {
      return; // No crear archivos si es modo back
    }
    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      print('  + Archivo creado: ${file.path}');
    }
  });
  

  print('Estructura base creada correctamente.');
}

Future<void> _generateFromGraphQL(String endpointUrl, String libRoot, bool isBack) async {
  print('Realizando introspección de esquema en: $endpointUrl');
  final introspector = GraphQLIntrospectionService();
  final modelGenerator = ModelGenerator(libRoot: libRoot);
  final builderGenerator = BuilderGenerator(libRoot: libRoot);
  final operationGenerator = OperationGenerator(libRoot: libRoot);
  final useCaseGenerator = UseCaseGenerator(libRoot: libRoot);
  final pageGenerator = PageGenerator(libRoot: libRoot);
  final routeGenerator = RouteGenerator(libRoot: libRoot);
  final mainRouteGenerator = MainRoutesGenerator(libRoot: libRoot);
  final gqlErrorArbGenerator = GqlErrorArbGenerator(arbRoot: '$libRoot/src/i18n');
  try {
    final schema = await introspector.fetchSchema(endpointUrl); // Map con 'types' y 'directives'
    modelGenerator.generateModelsFromSchema(schema);
    builderGenerator.generateBuildersFromTypes(schema['types'] as List);
    operationGenerator.generateOperationsFromSchema({'types': schema['types']});
    useCaseGenerator.generateUseCasesFromSchema(schema);
    if(!isBack) {
      // Solo generar páginas y rutas si no es modo back
      pageGenerator.generatePagesFromSchema(schema);
      routeGenerator.generateRoutesFromSchema(schema);
      mainRouteGenerator.generateMainRoutesFromSchema(schema);
      gqlErrorArbGenerator.generateArbFromSchema(endpointUrl,schema);
    }
    
    
  } catch (e) {
    print('Error durante la introspección/generación: $e');
  }
}
