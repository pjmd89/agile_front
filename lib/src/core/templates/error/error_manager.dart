
String errorTemplate = r'''import 'package:agile_front/agile_front.dart';

class ErrorManager implements ErrorConnManager{
  @override
  void handleGraphqlError(List<GraphQLError> errors) {}
  @override
  void handleHttpError(QueryResult result) {}
}''';