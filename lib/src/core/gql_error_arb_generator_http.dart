import 'dart:io';
import 'dart:convert';

class GqlErrorArbGenerator {
  final String arbRoot;
  GqlErrorArbGenerator({this.arbRoot = 'lib/l10n'});

  Future<void> generateArbFromSchema(String endpoint, Map<String, dynamic> schema) async {
    print('Generando archivos arb para errores GraphQL...');
    // Buscar el root type Query
    final types = schema['types'] as List?;
    if (types == null) {
      print('No se encontraron tipos en el schema.');
      return;
    }
    final queryType = types.firstWhere(
      (t) => t is Map && t['name'] == 'Query',
      orElse: () => null,
    );
    if (queryType == null) {
      print('No se encontró el root type Query.');
      return;
    }
    final fields = queryType['fields'] as List? ?? [];
    // Filtrar queries con '-gqlError' en la descripción
    final errorQueries = fields.where((f) =>
      f is Map &&
      f['description'] is String &&
      (f['description'] as String).contains('-gqlError')
    );
    if (errorQueries.isEmpty) {
      print('No se encontraron queries con "-gqlError" en la descripción.');
      return;
    }
    for (final query in errorQueries) {
      final name = query['name'] as String;
      // Construir la query para obtener los valores
      final gql = '''query { $name { message code level } }''';
      final response = await _doGraphQLQuery(endpoint, gql);
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

  String _buildArbContent(String queryName, dynamic data) {
    // data puede ser un Map o una List
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.write('  "@@locale": "es",\n');
    bool first = true;
    if (data is List) {
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        if (item != null && item['code'] != null && item['message'] != null) {
          if (!first) buffer.writeln(',');
          buffer.write('  "err_${item['code']}": "${item['message']}",\n');
          buffer.write('  "@err_${item['code']}": {\n    "description": ""\n  }');
          first = false;
        }
      }
    } else if (data is Map) {
      if (data['code'] != null && data['message'] != null) {
        buffer.write('  "err_${data['code']}": "${data['message']}",\n');
        buffer.write('  "@err_${data['code']}": {\n    "description": ""\n  }');
      }
    }
    buffer.writeln('\n}');
    return buffer.toString();
  }
}
