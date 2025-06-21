import 'package:graphql/client.dart';
export 'package:graphql/client.dart'
    show GraphQLError, QueryResult;
interface class ErrorConnManager{
  void handleGraphqlError(List<GraphQLError> errors) {}
  void handleHttpError(QueryResult result) {}
}