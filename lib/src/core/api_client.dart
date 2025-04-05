import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  Future<dynamic> fetchData({required String urlPath, Map<String, String>? headers, Duration? timeOut}) async {
    final response = await http
        .get(Uri.parse(urlPath), headers: headers)
        .timeout(timeOut ?? const Duration(seconds: 20), onTimeout: () => throw Exception("request took too long"));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.body;
      return data;
    } else {
      throw Exception(response.body);
    }
  }
}
