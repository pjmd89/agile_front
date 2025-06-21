
String errorTemplate = r'''import 'package:agile_front/agile_front.dart';
import 'package:flutter/material.dart';
typedef ErrorHandler = void Function(List<GraphQLError> errors);
class ErrorManager implements ErrorConnManager{
  final Map<String,ErrorHandler> handlers;
  ErrorManager({required this.handlers});
  @override
  void handleGraphqlError(List<GraphQLError> errors) {
    for (var err in errors) {
      if(handlers.containsKey(err.extensions?['code'])){
        handlers[err.extensions?['code']]!(errors);
      }else{
        debugPrint('Unhandled GraphQL error: ${err.message}');
      }
    }
  }
  @override
  void handleHttpError(QueryResult result) {}
}''';