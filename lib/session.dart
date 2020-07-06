import 'dart:convert';

import 'package:http/http.dart' as http;

class Session {
  static Map<String, String> headers = {};


  static Future<http.Response> login(email, password) async{
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$email:$password'));

    var response = await http.post('http://192.168.0.101:5000/auth/login', headers: {'Authorization': basicAuth});
    print(response.headers);
    updateCookie(response);
    return response;
  }

  static Future<http.Response> get(String url) async {
    http.Response response = await http.get(url, headers: headers);
    updateCookie(response);
    return response;
  }

  static Future<http.Response> post(String url, dynamic data) async {
    http.Response response = await http.post(url, body: data, headers: headers);
    updateCookie(response);
    return response;
  }

  static void updateCookie(response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] =
      (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }
}