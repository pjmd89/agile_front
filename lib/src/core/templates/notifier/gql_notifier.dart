
String appGqlNotifier = r'''import 'package:agile_front/agile_front.dart';
import 'package:flutter/material.dart';
import '/src/infraestructure/config/env.dart';

class GQLNotifier extends ChangeNotifier {
  final GqlConn gqlConn = GqlConn(
    apiURL: Environment.backendApiUrl,
    wsURL: Environment.backendApiUrlWS,
    insecure: Environment.env == EnvEnum.dev,
  );
}''';