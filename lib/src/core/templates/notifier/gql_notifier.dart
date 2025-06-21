
String appGqlNotifier = r'''import 'package:agile_front/agile_front.dart';
import 'package:flutter/material.dart';

class GQLNotifier extends ChangeNotifier {
  final GqlConn gqlConn = GqlConn(
    apiURL: 'http://localhost:8081',
    wsURL: null,
    insecure: false,
  );
}''';