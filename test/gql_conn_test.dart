import 'package:agile_front/infraestructure/connection/graphql/conn.dart';
import 'package:test/test.dart';
import 'package:agile_front/infraestructure/operation.dart' as op;

class example implements op.Operation{
  @override
  String get name => 'example';

  @override
  String build() {
    return 'query example{__typename}';
  }
  @override
  Object result(Map<String, dynamic> data) {
    return data;
  }
}
void main() async{
  late DartGql gql;
  late GraphqlConn conn;
  setUp(() {
    gql = DartGql(
      apiURL: 'http://localhost:8081',
      insecure: true,
    );
    conn = GraphqlConn(client: gql);
  });
  test('Manejo de error de conexión', () async {
    var data = await conn.operation(
      operation: example(),
      callback: (Object ob) {
        print("objeto: ${ob.toString()}");
      },
    );
    print(data);
    expect(data, isNotNull);
  });
}
