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

    // Generar archivos para queries
    _generateOperationFiles(
      operationType: 'query',
      operations: queries,
      outDir: '$libRoot/src/domain/operation/queries',
    );
    // Lo mismo se podrá hacer para mutations y subscriptions
  }

  void _generateOperationFiles({
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
    for (final entry in grouped.entries) {
      final entity = entry.key;
      final ops = entry.value;
      final entityDir = Directory('$outDir/$entity');
      if (!entityDir.existsSync()) {
        entityDir.createSync(recursive: true);
        print('  + Carpeta creada: ${entityDir.path}');
      }
      for (final op in ops) {
        final opName = op['name'] as String;
        final fileName = '${opName.toLowerCase()}_${operationType}.dart';
        final filePath = '${entityDir.path}/$fileName';
        final file = File(filePath);
        // Generar la clase de operación usando builder si corresponde
        final opClass = _buildOperationClass(operationType, op);
        file.writeAsStringSync(opClass);
        print('    + Archivo generado: $filePath');
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
    for (final arg in args) {
      final argName = arg['name'];
      final isRequired = (arg['type']['kind'] == 'NON_NULL');
      final dartType = 'dynamic'; // TODO: mapear tipo GraphQL a Dart
      fields.add('  final $dartType $argName;');
      params.add(isRequired ? 'required this.$argName' : 'this.$argName');
    }
    // Agregar el builder como parámetro obligatorio si hay tipo de retorno objeto
    String builderField = '';
    String builderParam = '';
    String builderUsage = '';
    String importBuilder = '';
    if (builderType != null) {
      builderField = '  final $builderType builder;';
      builderParam = 'required this.builder';
      builderUsage = '\n    final fields = builder.build();';
      importBuilder = "import '../../operation/fields_builders/main.dart';\n";
    }
    final fieldsStr = [if (builderField.isNotEmpty) builderField, ...fields].join('\n');
    final paramsStr = [if (builderParam.isNotEmpty) builderParam, ...params].join(', ');
    // Construir el string de campos para la operación
    return """
${importBuilder}class $className {
$fieldsStr

  $className({$paramsStr});

  String buildOperation() {
    ${builderUsage.isNotEmpty ? builderUsage : ''}
    return '''
$operationType $name {
  \\${builderType != null ? 'fields' : ''}
}
''';
  }
}
""";
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  String _toCamelCase(String s) {
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((w) => _capitalize(w)).join();
  }
}
