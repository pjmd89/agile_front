import 'package:agile_front/infraestructure/operation.dart' as af;
import 'dart:async';

abstract class Service{
  Future<dynamic> operation({
    required af.Operation operation,
    void Function(Object)? callback,
    Map<String, dynamic>? variables,
  });
}