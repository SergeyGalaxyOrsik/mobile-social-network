import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password); // преобразуем в байты
  final digest = sha256.convert(bytes); // хэшируем SHA-256
  return digest.toString();
}
