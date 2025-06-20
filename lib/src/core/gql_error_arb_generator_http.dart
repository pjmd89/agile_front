import 'dart:io';
import 'dart:convert';

class GqlErrorArbGenerator {
  final String arbRoot;
  GqlErrorArbGenerator({this.arbRoot = 'lib/l10n'});

  Future<void> generateArbFromSchema(String endpoint, Map<String, dynamic> schema) async {
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
      // Construir la query para obtener los valores del type
      final query = '''query { $name { message code level } }''';
      final response = await _doGraphQLQuery(endpoint, query);
      final data = response['data']?[name];
      if (data == null) {
        print('No se obtuvieron datos para $name');
        continue;
      }
      final file = File('$arbRoot/${name.toLowerCase()}_gql_error.arb');
      if (!file.existsSync()) {
        final arbContent = _buildArbContent(name, data);
        file.createSync(recursive: true);
        file.writeAsStringSync(arbContent);
        print('  + Archivo arb generado: ${file.path}');
      }
    }
  }

  Future<Map<String, dynamic>> _doGraphQLQuery(String endpoint, String query) async {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse(endpoint));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'query': query}));
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception('Error al consultar GraphQL: ${response.statusCode}\n$responseBody');
    }
  }

  String _buildArbContent(String typeName, dynamic data) {
    // data es un Map con las claves message, code, level
    final allowed = {'message', 'code', 'level'};
    final buffer = StringBuffer();
    buffer.writeln('{');
    bool first = true;
    for (final key in allowed) {
      if (data[key] != null) {
        if (!first) buffer.writeln(',');
        buffer.write('  "${typeName}Error_$key": "${data[key]}"');
        first = false;
      }
    }
    buffer.writeln('\n}');
    return buffer.toString();
  }
}
