import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'client.dart';
import 'package:graphql/client.dart';

class GraphQLNotifier {
  HttpLink? _apilink;
  HttpLink? _contactApiLink;
  late WebSocketLink _webSocketLink;
  late GraphQLClient _apiClient;
  late GraphQLClient _contactApiClient;
  String _contactApiToken = "";
  //final AuthLink _authLink = AuthLink(getToken: () => valueCookie, headerKey: 'Cookie');
  
  get apiClient => _apiClient;
  get contactApiClient => _contactApiClient;
  get contactApiToken => _contactApiToken;
  final Policies policies = Policies(
    fetch: FetchPolicy.noCache,
    cacheReread: CacheRereadPolicy.ignoreAll,
  );

  GraphQLNotifier({String apiURL = "", String contactApiURL = "", String apiWSURL = "", String? apiToken}) {
    if (apiToken != null) {
      _contactApiToken = apiToken;
    }

    final http.Client httpApiClient = http.Client();
    if (httpApiClient is BrowserClient) {
      httpApiClient.withCredentials = true;
    }
    final http.Client httpContactApiClient = http.Client();
    if (httpContactApiClient is BrowserClient) {
      httpContactApiClient.withCredentials = true;
    }

    _apilink = HttpLink(apiURL, httpClient:httpApiClient);
    _contactApiLink = HttpLink(contactApiURL, httpClient:httpApiClient);
    Link link;
    _webSocketLink = WebSocketLink(
      apiWSURL,
      subProtocol: GraphQLProtocol.graphqlTransportWs,
      config: SocketClientConfig(
        headers: {
          "Cookie": valueCookie,
        }
      )
    );
    link = _apilink!;
    if (apiWSURL != ""){
      link = Link.split((request) => request.isSubscription, _webSocketLink, _apilink!);
    }
    //link = _authLink.concat(_link);
    _apiClient = GraphQLClient(
      link: link,
      queryRequestTimeout: Duration(seconds: 10),
      
      defaultPolicies: DefaultPolicies(
        watchQuery: policies,
        query: policies,
        mutate: policies,
        watchMutation: policies,
        subscribe: policies,
      ),
      cache: GraphQLCache(),
    );
    _contactApiClient = GraphQLClient(
      link: _contactApiLink!,
      defaultPolicies: DefaultPolicies(
        watchQuery: policies,
        query: policies,
        mutate: policies,
        watchMutation: policies,
        subscribe: policies,
      ),
      cache: GraphQLCache(),
    );
  }
  /*
  String _errorParser({required BuildContext context, required String errCode}){
    String errMessage = ListBackendError(context, errCode).errorMessage;
    return errMessage;
  }

  String Function({required BuildContext context, required String errCode}) get errorParser => _errorParser;
  */
}