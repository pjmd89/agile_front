
import 'package:agile_front/infraestructure/service.dart';
import 'package:agile_front/infraestructure/operation.dart';
import 'dart:async';
import 'package:dart_gql/main.dart';
export 'package:dart_gql/main.dart';
class GraphqlConn extends Service{
  final DartGql _gql;
  GraphqlConn({required DartGql client}) : _gql = client;
  @override
  Future<dynamic> operation({required Operation operation, void Function(Object)? callback, Map<String, dynamic>? variables}) async{
    final queryVariables = variables ?? {};
    final response = await _gql.query(
      QueryOptions(
        operationName: operation.name,
        document: gql(operation.build()), 
        variables: queryVariables,
      ),
    );
    if (response.hasException) {
      final errors = response.exception?.graphqlErrors ?? [];
      if (errors.isNotEmpty) {
        // Handle exceptions here, e.g., log them or show a message
        return errors;
      }
      return response;
    }
    var data = operation.result(response.data ?? {});
    if (callback != null){
      callback(data);
    }
    return data;
  }
}
