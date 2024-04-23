import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app/AES/AES.dart';

class UserClientDTO {
  final String email;
  final String name;
  final String phone;
  late final String pin;

  UserClientDTO({
    required this.email,
    required this.name,
    required this.phone,
    required this.pin,
  });

  factory UserClientDTO.fromJson(Map<String, dynamic> json, String uid) {
    AES aes = AES(uid);
    return UserClientDTO(
      email: json['email'],
      name: aes.decryptData(json['name']),
      phone: aes.decryptData(json['phone']),
      pin: aes.decryptData(json['pin']),
    );
  }
  Map<String, dynamic> toJson(String uid) {
    AES aes = AES(uid);
    return {
      'email': email,
      'name': aes.encryptData(name),
      'phone': aes.encryptData(phone),
      'pin': pin != ""?aes.encryptData(pin): "",
    };
  }
}

const String URL_API = 'http://192.168.38.86:7046';

Future<UserClientDTO> fetchUserByEmail(String? uid, String? email) async {
  if (uid == null || email == null) {
    throw Exception('thiếu uid hoặc email');
  }
  final response = await http.get(Uri.parse('$URL_API/api/UserClient/$email'));

  if (response.statusCode == 200) {
    return UserClientDTO.fromJson(jsonDecode(response.body), uid);
  } else if (response.statusCode == 400) {
    throw Exception('tài khoản không tồn tại !');
  } else {
    throw Exception('API_no_connect');

  }
}
Future<bool> addUser(UserClientDTO user, String uid) async {
  final response = await http.post(
    Uri.parse('$URL_API/api/UserClient/AddUser'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(user.toJson(uid)),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('API_no_connect');
  }
}
Future<bool> updateUserPinAPI(String uid, UserClientDTO user) async {
  final response = await http.put(
    Uri.parse('$URL_API/api/UserClient/UpdatePin/${user.email}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(user.toJson(uid)),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update user pin');
  }
}