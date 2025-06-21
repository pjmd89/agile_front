import 'package:graphql/client.dart';

interface class ErrorConnManager{
  void handleGraphqlError(List<GraphQLError> errors) {}
  void handleHttpError(QueryResult result) {}
}