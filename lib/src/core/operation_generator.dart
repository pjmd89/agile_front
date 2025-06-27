import 'dart:io';

class OperationGenerator {
  final String libRoot;
  OperationGenerator({this.libRoot = 'lib'});

  void generateOperationsFromSchema(Map<String, dynamic> schema) {
    print('Generando operaciones GraphQL (queries, mutations, subscriptions)...');
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    // Buscar los root types de operaciones
    final queryType = types.firstWhere(
      (t) => t['name'] == 'Query',
      orElse: () => null,
    );
    final mutationType = types.firstWhere(
      (t) => t['name'] == 'Mutation',
      orElse: () => null,
    );
    final subscriptionType = types.firstWhere(
      (t) => t['name'] == 'Subscription',
      orElse: () => null,
    );

    // Extraer operaciones de cada root type
    final queries = queryType != null ? (queryType['fields'] as List? ?? []) : [];
    final mutations = mutationType != null ? (mutationType['fields'] as List? ?? []) : [];
    final subscriptions = subscriptionType != null ? (subscriptionType['fields'] as List? ?? []) : [];

    print('  - Queries encontradas: \\${queries.length}');
    print('  - Mutations encontradas: \\${mutations.length}');
    print('  - Subscriptions encontradas: \\${subscriptions.length}');

    // Acumular todos los archivos generados para el barrel global
    final allGeneratedFiles = <String>[];

    // Generar archivos para queries
    allGeneratedFiles.addAll(_generateOperationFiles(
      operationType: 'query',
      operations: queries,
      outDir: '$libRoot/src/domain/operation/queries',
    ));
    allGeneratedFiles.addAll(_generateOperationFiles(
      operationType: 'mutation',
      operations: mutations,
      outDir: '$libRoot/src/domain/operation/mutations',
    ));
    allGeneratedFiles.addAll(_generateOperationFiles(
      operationType: 'subscription',
      operations: subscriptions,
      outDir: '$libRoot/src/domain/operation/subscriptions',
    ));

    // Actualizar barrel global en /src/domain/operation/main.dart una sola vez
    final barrelPath = '${libRoot}/src/domain/operation/main.dart';
    final buffer = StringBuffer();
    for (final relPath in allGeneratedFiles) {
      buffer.writeln("export './$relPath';");
    }
    var barrelFile = File(barrelPath);
    if (!barrelFile.existsSync()) {
      barrelFile.writeAsStringSync(buffer.toString());
      print('  + Barrel global actualizado: $barrelPath');
    }
    
  }

  List<String> _generateOperationFiles({
    required String operationType, // 'query', 'mutation', 'subscription'
    required List operations,
    required String outDir,
  }) {
    // Agrupar por entidad (por convención: primer segmento del nombre de la operación)
    final Map<String, List> grouped = {};
    for (final op in operations) {
      final name = op['name'] as String;
      final entity = name.contains('_') ? name.split('_').last : name;
      grouped.putIfAbsent(entity, () => []).add(op);
    }
    // Crear carpetas y archivos
    final generatedFilesGlobal = <String>[];
    for (final entry in grouped.entries) {
      final entity = entry.key;
      final ops = entry.value;
      final entityDir = Directory('$outDir/$entity');
      if (!entityDir.existsSync()) {
        entityDir.createSync(recursive: true);
        print('  + Carpeta creada: \\${entityDir.path}');
      }
      for (final op in ops) {
        final opName = op['name'] as String;
        final fileName = '${opName.toLowerCase()}_${operationType}.dart';
        final filePath = '${entityDir.path}/$fileName';
        final file = File(filePath);
        // Generar la clase de operación usando builder si corresponde
        final opClass = _buildOperationClass(operationType, op);
        _writeIfNotExists(file, opClass);
        
        // Guardar ruta relativa para el barrel global
        final relPath = filePath.split('/src/domain/operation/').last;
        generatedFilesGlobal.add(relPath);
      }
    }
    return generatedFilesGlobal;
  }

  void _writeIfNotExists(File file, String content, {bool showMessage = true}) {
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      if (showMessage) {
        print('    + Archivo generado: ${file.path}');
      }
    }
  }

  String _buildOperationClass(String operationType, Map op) {
    final name = op['name'] as String;
    final className = _capitalize(_toCamelCase(name)) + _capitalize(operationType);
    final args = op['args'] as List? ?? [];
    // Obtener el tipo de retorno de la operación
    final returnType = op['type'];
    String? returnTypeName;
    String? builderType;
    dynamic t = returnType;
    while (t is Map && (t['kind'] == 'NON_NULL' || t['kind'] == 'LIST')) {
      t = t['ofType'];
    }
    if (t is Map) {
      if (t['kind'] == 'OBJECT') {
        returnTypeName = t['name'];
        builderType = '${returnTypeName}FieldsBuilder';
      }
    }
    // Definir campos y parámetros del constructor
    final fields = <String>[];
    final params = <String>[];
    final gqlArgsMap = <String, dynamic>{};
    for (final arg in args) {
      final argName = arg['name'];
      final isRequired = (arg['type']['kind'] == 'NON_NULL');
      final dartType = 'dynamic'; // TODO: mapear tipo GraphQL a Dart
      fields.add('  final $dartType $argName;');
      params.add(isRequired ? 'required this.$argName' : 'this.$argName');
      gqlArgsMap[argName] = '\$argName';
    }
    // Alias, args y directivas opcionales
    fields.add('  final String _name = \'$name\';');
    fields.add('  Map<String,String>? declarativeArgs;');
    fields.add('  final String? alias;');
    params.add('this.declarativeArgs');
    params.add('this.alias');
    fields.add('  Map<String, dynamic>? opArgs;');
    params.add('this.opArgs');
    fields.add('  List<Directive>? directives;');
    params.add('this.directives');
    // Agregar el builder como parámetro obligatorio si hay tipo de retorno objeto
    String builderField = '';
    String builderParam = '';
    String builderUsage = '';
    String importBuilder = '';
    String importModels = '';
    String importHelper = '';
    String importOperation = '';
    if (builderType != null) {
      builderField = '  final $builderType builder;';
      builderParam = 'required this.builder';
      builderUsage = '\n    final fields = builder.build();';
      importBuilder = "import '/src/domain/operation/fields_builders/main.dart';\n";
      importModels = "import '/src/domain/entities/main.dart';\n";
      importHelper = "import 'package:agile_front/infraestructure/graphql/helpers.dart';\n";
      importOperation = "import 'package:agile_front/infraestructure/operation.dart';\n";
    }
    final fieldsStr = [if (builderField.isNotEmpty) builderField, ...fields].join('\n');
    final paramsStr = [if (builderParam.isNotEmpty) builderParam, ...params].join(', ');
    // Preparar el método result según el tipo de retorno
    String resultMethod;
    if (returnTypeName != null) {
      resultMethod = '''
  @override
  $returnTypeName result(Map<String, dynamic> data) {
    String name;
    name = alias ?? _name;
    return $returnTypeName.fromJson(data[name]);
  }
''';
    } else {
      resultMethod = '''
  @override
  Object result(Map<String, dynamic> data) {
    return data;
  }
''';
    }
    // Construir el string de campos para la operación usando formatField
    return """
${importBuilder}${importModels}${importOperation}${importHelper}class $className implements Operation{
$fieldsStr

  @override
  get name => _name;
  $className({$paramsStr});
  @override
  String build({String? alias, Map<String, String>? declarativeArgs, Map<String, dynamic>? args, List<Directive>? directives}) {
    ${builderUsage.isNotEmpty ? builderUsage : ''}
    // Construir declaración de variables GraphQL
    final variableDecl = declarativeArgs ?? this.declarativeArgs ?? {};
    final variablesStr = variableDecl.isNotEmpty ? '(\${variableDecl.entries.map((e) => '\\\$\${e.key}:\${e.value}').join(',')})' : ''; 
    
    final body = formatField(
      _name,
      alias: alias ?? this.alias,
      args: args ?? opArgs,
      directives: directives ?? this.directives,
      selection: ${builderType != null ? 'fields' : 'null'},
    );
    return '''
      $operationType \$_name\$variablesStr {
        \$body
      }
    ''';
  }
$resultMethod
}
""";
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  String _toCamelCase(String s) {
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((w) => _capitalize(w)).join();
  }
}
