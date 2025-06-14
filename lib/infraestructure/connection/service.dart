import 'package:agile_front/infraestructure/operation.dart';

abstract class Service{
  operation({
    required Operation operation,
    required Function(Object) callback,
    Map<String, dynamic>? variables,
  });
}