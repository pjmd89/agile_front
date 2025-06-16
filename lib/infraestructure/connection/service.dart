import 'package:agile_front/infraestructure/operation.dart';

abstract class Service{
  Future<dynamic> operation({
    required Operation operation,
    void Function(Object)? callback,
    Map<String, dynamic>? variables,
  });
}