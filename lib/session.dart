import 'dart:convert';

import 'package:http/http.dart' as http;

class Session {
  static Map<String, String> headers = {};
  static final String host = "http://192.168.0.101:5000";

  static Future<http.Response> login(email, password) async{


    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$email:$password'));

    print('$host/auth/login');
    print({'Authorization': basicAuth});

    var response = await http.post('http://192.168.0.101:5000/auth/login', headers: {'Authorization': basicAuth});
    print(response.headers);
    updateCookie(response);
    print(headers);
    return response;
  }

  static Future<http.Response> get(String url) async {
    http.Response response = await http.get('$host$url', headers: headers);
    updateCookie(response);
    return response;
  }

  static Future<http.Response> post(String url, dynamic data) async {
    print('$host$url');
    print(data);
    print(headers);
    http.Response response = await http.post('$host$url', body: data, headers: headers);
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