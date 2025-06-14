import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

String valueCookie = '';
class ClientWithCookies extends http.BaseClient {
  late http.Client _inner;
  
  ClientWithCookies(){
    final http.Client cookieEnabledClient = http.Client();
    if (cookieEnabledClient is BrowserClient) {
      cookieEnabledClient.withCredentials = true;
    }
    _inner = cookieEnabledClient;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async{
    return _inner.send(request).then((response) {
      final cookies = response.headers['set-cookie'] ?? '';
      if (cookies.isNotEmpty) {
        final cookie = cookies.split(';')[0]; 
        valueCookie = cookie;
      }
      return response;
    });
  }
}