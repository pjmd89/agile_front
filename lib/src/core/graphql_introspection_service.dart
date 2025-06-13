import 'dart:convert';
import 'dart:io';

class GraphQLIntrospectionService {
  static const String introspectionQuery = '''
    query IntrospectionQuery {
      __schema {
        types { name kind fields { name type { name kind ofType { name kind } } } inputFields { name type { name kind ofType { name kind } } } enumValues { name } }
      }
    }
  ''';

  Future<List> fetchTypes(String endpointUrl) async {
    final response =
        await HttpClient().postUrl(Uri.parse(endpointUrl))
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({'query': introspectionQuery.replaceAll("\n", " ")}),
          );
    final httpResponse = await response.close();
    final responseBody = await utf8.decoder.bind(httpResponse).join();
    if (httpResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['data']?['__schema']?['types'] ?? [];
    } else {
      throw Exception(
        'Error al obtener el esquema: ${httpResponse.statusCode}\n$responseBody',
      );
    }
  }
}
