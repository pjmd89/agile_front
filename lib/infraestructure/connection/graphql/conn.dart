import 'package:agile_front/infraestructure/connection/service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:agile_front/infraestructure/operation.dart' as op;

class GraphqlConn extends Service{
  final GraphQLClient _client;
  GraphqlConn({required GraphQLClient client}) : _client = client;
  @override
  operation({required op.Operation operation, required void Function(Object) callback, Map<String, dynamic>? variables}) async{
    final queryVariables = variables ?? {};
    final response = await _client.query(
      QueryOptions(
        document: gql(operation.build()), 
        variables: queryVariables,
      ),
    );
    if (response.hasException) {
      final errors = response.exception?.graphqlErrors ?? [];
      if (errors.isNotEmpty) {
        // Handle exceptions here, e.g., log them or show a message
        //print('GraphQL Errors: ${errors.map((e) => e.message).join(', ')}');
      }
      return;
    }
    callback(operation.result(response.data ?? {}));
  }
}
