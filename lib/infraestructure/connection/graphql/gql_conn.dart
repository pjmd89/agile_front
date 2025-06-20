import 'package:agile_front/infraestructure/connection/graphql/graphql_conn.dart';
class GqlConn extends GraphqlConn {
  late String _apiURL;
  late String? _wsURL;
  
  String get apiURL => _apiURL;
  String? get wsURL => _wsURL;

  GqlConn({
    required String apiURL,
    String? wsURL,
    bool insecure = false,
  }) : super(
    client: DartGql(
      apiURL: apiURL,
      wsURL: wsURL,
      insecure: insecure,
    ),
  ) {
    _apiURL = apiURL;
    _wsURL = wsURL;
  }
  

}