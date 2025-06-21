import 'package:graphql/client.dart';
export 'package:graphql/client.dart'
    show GraphQLError, QueryResult;
class ErrorReturned{
  final List<GraphQLError>? gqlError;
  final QueryResult? httpError;
  ErrorReturned({this.gqlError, this.httpError});
}
interface class ErrorConnManager{
  ErrorReturned handleGraphqlError(List<GraphQLError> errors) {
    return ErrorReturned(
      gqlError: errors,
      httpError: null,
    );
  }
  ErrorReturned handleHttpError(QueryResult result) {
    return ErrorReturned(
      gqlError: null,
      httpError: result,
    );
  }
}