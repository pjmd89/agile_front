import 'package:agile_front/infraestructure/connection/service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class GraphqlConn extends Service{
  final GraphQLClient _client;
  GraphqlConn(GraphQLClient client) : _client = client;
  @override
  operation({required String operation, required Function(Map<String, dynamic>) callback, Map<String, dynamic>? variables}) async{
    final queryVariables = variables ?? {};
    final response = await _client.query(
      QueryOptions(
        document: gql(operation), 
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
    callback(response.data ?? {});
  }
}
