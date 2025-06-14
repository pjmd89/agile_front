import 'dart:developer';

import 'package:agile_front/infraestructure/connection/connection_type_enum.dart';

class Connection {
  ConnectionTypeEnum type;
  Service connectionService = Service();
  Connection({
    this.type = ConnectionTypeEnum.graphql,
  }) {
    this.type = type;
    
  }


}