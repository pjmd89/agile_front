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
        // Por ahora solo generamos el string GraphQL de la operación
        final gqlString = _buildGraphQLOperationString(operationType, op);
        file.writeAsStringSync(gqlString);
        print('    + Archivo generado: $filePath');
      }
    }
  }

  String _buildGraphQLOperationString(String operationType, Map op) {
    // Por ahora solo el string básico de la operación
    final name = op['name'];
    return '''
$operationType $name {
  // ...campos...
}
''';
  }
}
