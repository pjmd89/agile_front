abstract class Operation{
  String get name;
  String build();
  Object result(Map<String, dynamic> data);
}