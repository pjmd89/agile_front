
String appGqlNotifier = r'''import 'package:agile_front/agile_front.dart';
import 'package:flutter/material.dart';
import '/src/infraestructure/error/error_manager.dart';
import '/src/infraestructure/config/env.dart';
typedef ErrorHandler = void Function(List<GraphQLError> errors);
class GQLNotifier extends ChangeNotifier {
  final BuildContext context;
  late GqlConn gqlConn;
  
  GQLNotifier({required this.context}){
    Map<String, ErrorHandler> errorHandlers = {
      'error1': error1,
    };
    gqlConn = GqlConn(
      apiURL: Environment.backendApiUrl,
      errorManager: ErrorManager(handlers: errorHandlers),
      wsURL: Environment.backendApiUrlWS,
      insecure: Environment.env == EnvEnum.dev,
    );
  }
  error1(List<GraphQLError> errors){

  }
}''';