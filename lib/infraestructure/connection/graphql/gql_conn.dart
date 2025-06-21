import 'package:agile_front/infraestructure/connection/error_manager.dart';
import 'package:agile_front/infraestructure/connection/graphql/graphql_conn.dart';
class GqlConn extends GraphqlConn {
  GqlConn({
    required String apiURL,
    required ErrorConnManager errorManager,
    String? wsURL,
    bool insecure = false,
  }) :
  super(
    client: DartGql(
      apiURL: apiURL,
      wsURL: wsURL,
      insecure: insecure,
    ),
    errorManager: errorManager,
  );
}