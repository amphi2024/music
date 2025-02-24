import 'dart:math';

String randomAlphabet() {
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  String alphabet = chars[Random().nextInt(chars.length)];
  return alphabet;
}