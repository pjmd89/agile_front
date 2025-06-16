import 'package:agile_front/infraestructure/operation.dart';

abstract class Service{
  Future<dynamic> operation({
    required Operation operation,
    Map<String, dynamic>? variables,
  });
}