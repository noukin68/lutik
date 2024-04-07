import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchUserName(int userId) async {
  final response =
      await http.get(Uri.parse('http://62.217.182.138:3000/user/${userId}'));

  if (response.statusCode == 200) {
    final userInfo = jsonDecode(response.body);
    final username = userInfo['username'];
    return username;
  } else {
    throw Exception('Failed to load username');
  }
}
