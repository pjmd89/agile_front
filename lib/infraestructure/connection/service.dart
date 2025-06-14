abstract class Service{
  operation({
    required String operation,
    required Function(Map<String, dynamic>) callback,
    Map<String, dynamic>? variables,
  });
}