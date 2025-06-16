import 'package:agile_front/infraestructure/utils/env_enum.dart';
import 'package:agile_front/infraestructure/utils/isWeb.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'http_client_stub.dart'
    if (dart.library.html) 'http_client_web.dart';

String valueCookie = '';
class ClientWithCookies extends IOClient {
  ClientWithCookies._({
    required HttpClient httpClient
  }) : super(
    httpClient
  );

  factory ClientWithCookies.createFromEnvironment({EnvEnum env = EnvEnum.dev}) {
    ClientWithCookies clientWithCookies;
    HttpClient httpClient = HttpClient();

    if (env == EnvEnum.dev) {
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    }
    clientWithCookies = ClientWithCookies._(httpClient: httpClient);
    return clientWithCookies;
  }
  
  @override
  Future<IOStreamedResponse> send(request) async {
    return super.send(request).then((response) {
      final cookies = response.headers['set-cookie'] ?? '';
      if (cookies.isNotEmpty) {
        final cookie = cookies.split(';')[0]; 
        valueCookie = cookie;
      }
      return response;
    });
  }
}

class GqlClient{
  late HttpLink _httpApiLink;
  late WebSocketLink _webSocketLink;
  GraphQLClient? _gqlClient;
  final AuthLink _authLink = AuthLink(
    getToken: () => valueCookie, 
    headerKey: 'Cookie'
  );
  final Policies _policies = Policies(
    fetch: FetchPolicy.noCache,
    cacheReread: CacheRereadPolicy.ignoreAll,
  );
  get gqlClient => _gqlClient;
  
  GqlClient({
    required String apiURL,
    String apiWSURL = "",
    EnvEnum env = EnvEnum.dev
  }) {
    Link apiLink;
    _webSocketLink = WebSocketLink(
      apiWSURL,
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        headers: {
          "Cookie": valueCookie,
        },
      ),
    );

    if(isWeb){
      http.Client httpApiClient = createHttpClient();
      
      _httpApiLink = HttpLink(apiURL, httpClient:httpApiClient);
      apiLink = _httpApiLink;

      if (apiWSURL.trim() != ""){
        apiLink = Link.split((request) => request.isSubscription, _webSocketLink, _httpApiLink);
      }
    }
    else{
      _httpApiLink = HttpLink(apiURL, httpClient: ClientWithCookies.createFromEnvironment(env: env));
      apiLink = _authLink.concat(_httpApiLink);

      if (apiWSURL.trim() != ""){
        apiLink = Link.split((request) => request.isSubscription, _webSocketLink, _authLink.concat(_httpApiLink));
      }
    }

    _gqlClient = GraphQLClient(
      link: apiLink,
      queryRequestTimeout: Duration(seconds: 10),
      defaultPolicies: DefaultPolicies(
        watchQuery: _policies,
        query: _policies,
        mutate: _policies,
        watchMutation: _policies,
        subscribe: _policies,
      ),
      cache: GraphQLCache(),
    );
  }
}