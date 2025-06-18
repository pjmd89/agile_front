import 'dart:developer';

import 'package:agile_front/infraestructure/connection/service.dart';

import 'package:agile_front/infraestructure/operation.dart' as op;
import 'dart:async';

import 'package:dart_gql/main.dart';
import 'package:graphql/client.dart';
class GraphqlConn extends Service{
  final DartGql _gql;
  GraphqlConn({required DartGql client}) : _gql = client;
  @override
  Future<dynamic> operation({required op.Operation operation, void Function(Object)? callback, Map<String, dynamic>? variables}) async{
    final queryVariables = variables ?? {};
    log(operation.build());
    final response = await _gql.client.query(
      QueryOptions(
        operationName: operation.name,
        document: gql(operation.build()), 
        variables: queryVariables,
      ),
    );
    if (response.hasException) {
      log("es un error ${response}");
      final errors = response.exception?.graphqlErrors ?? [];
      if (errors.isNotEmpty) {
        log("llego al not empty");
        // Handle exceptions here, e.g., log them or show a message
        return response.exception?.graphqlErrors;
      }
      return;
    }
    var data = operation.result(response.data ?? {});
    log("ejecuto");
    if (callback != null){
      log("llego al callback");
      callback(data);
    }
    return data;
  }
}
