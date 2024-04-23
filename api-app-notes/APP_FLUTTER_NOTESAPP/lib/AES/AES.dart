// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'dart:convert';
import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AES {
  final String? _key;

  AES(this._key);

   Uint8List generate128BitKeyFromUid(String? uid) {
    // Chuyển UID thành một chuỗi UTF-8
    List<int> bytes = utf8.encode(uid!);

    // Sử dụng hàm băm SHA-256 để tạo ra một chuỗi 256 bit từ UID
    Digest digest = sha256.convert(bytes);

    // Chuyển đổi digest thành danh sách byte
    List<int> keyBytes = digest.bytes;

    // Lấy 16 byte đầu tiên từ digest để tạo thành khóa 128-bit
    Uint8List truncatedKey = Uint8List.fromList(keyBytes.sublist(0, 16));
    // print("Key ${truncatedKey.length}");
    return truncatedKey;
  }


  // Hàm mã hóa
  String encryptData(String? data) {

    final key = encrypt.Key(generate128BitKeyFromUid(_key));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    if(data == null) {
      return "";
    }
    final encrypted = encrypter.encrypt(data, iv: iv);
    return iv.base64 + encrypted.base64;
  }

  // Hàm giải mã
  String decryptData(String? encryptedData) {
    if(encryptedData == null) {
      return "";
    }
    if(encryptedData == ""){
      return "";
    }
    final key = encrypt.Key(generate128BitKeyFromUid(_key));
    final ivBytes = base64.decode(encryptedData.substring(0, 24)); // Lấy IV từ dữ liệu đã mã hóa
    final iv = encrypt.IV(ivBytes);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedText = encryptedData.substring(24); // Lấy phần dữ liệu đã mã hóa
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
