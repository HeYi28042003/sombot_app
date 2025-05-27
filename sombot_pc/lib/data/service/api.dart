// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final storage = FlutterSecureStorage();

// class APi {
//   Future<bool> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('http://192.168.1.180:1111/api/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'email': email, 'password': password}),
//     );
//     print('Response status: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       await storage.write(key: 'token', value: data['token']);
//       return true;
//     } else {
//       return false;
//     }
//   }

//   Future<void> fetchUser() async {
//     final token = await storage.read(key: 'token');
//     final response = await http.get(
//       Uri.parse('http://192.168.1.180:1111/api/user'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Accept': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       print('User data: ${response.body}');
//     } else {
//       print('Unauthorized');
//     }
//   }
// }
