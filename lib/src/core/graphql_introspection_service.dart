import 'dart:convert';
import 'dart:io';

class GraphQLIntrospectionService {
  static const String introspectionQuery = '''
    query IntrospectionQuery {
      __schema {
        directives {
          name
          description
          locations
          args {
            name
            description
            type {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                }
              }
            }
            defaultValue
          }
        }
        types {
          name
          description
          kind
          fields {
            name
            description
            type {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                      ofType {
                        kind
                        name
                      }
                    }
                  }
                }
              }
            }
          }
          inputFields {
            name
            type {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                      ofType {
                        kind
                        name
                      }
                    }
                  }
                }
              }
            }
          }
          enumValues { name }
        }
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

  Future<Map<String, dynamic>> fetchSchema(String endpointUrl) async {
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
      final schema = data['data']?['__schema'] ?? {};
      return {
        'types': schema['types'] ?? [],
        'directives': schema['directives'] ?? [],
      };
    } else {
      throw Exception(
        'Error al obtener el esquema: \\${httpResponse.statusCode}\\n$responseBody',
      );
    }
  }
}
