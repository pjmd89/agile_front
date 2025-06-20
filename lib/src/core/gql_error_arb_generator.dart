import 'dart:io';

class GqlErrorArbGenerator {
  final String arbRoot;
  GqlErrorArbGenerator({this.arbRoot = 'lib/l10n'});

  void generateArbFromSchema(Map<String, dynamic> schema) {
    print('Generando archivos arb para errores GraphQL...');
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    // Filtrar types que tengan en la descripción la cadena '-gqlError'
    final errorTypes = types.where((t) =>
      t is Map &&
      t['description'] is String &&
      (t['description'] as String).contains('-gqlError')
    );
    if (errorTypes.isEmpty) {
      print('No se encontraron types con "-gqlError" en la descripción.');
      return;
    }
    for (final type in errorTypes) {
      final name = type['name'] as String;
      final fields = (type['fields'] as List?) ?? [];
      final file = File('$arbRoot/${name.toLowerCase()}_gql_error.arb');
      if (!file.existsSync()) {
        final arbContent = _buildArbContent(name, fields);
        file.createSync(recursive: true);
        file.writeAsStringSync(arbContent);
        print('  + Archivo arb generado: ${file.path}');
      }
    }
  }

  String _buildArbContent(String typeName, List fields) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final fieldName = field['name'];
      buffer.write('  "${typeName}Error_$fieldName": "$fieldName"');
      if (i < fields.length - 1) buffer.writeln(',');
    }
    buffer.writeln('\n}');
    return buffer.toString();
  }
}
