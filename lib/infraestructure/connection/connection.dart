import 'package:agile_front/infraestructure/connection/connection_type_enum.dart';

import 'service.dart';

class Connection {
  ConnectionTypeEnum type;
  Service connectionService;
  Connection({
    this.type = ConnectionTypeEnum.graphql,
    required this.connectionService,
  }) {
    this.type = type;
    
  }


}