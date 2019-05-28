import 'package:http/http.dart' as http;

class Api {
  Future<http.Response> getData(String link) async {
    return await http.get(link);
  }
}
