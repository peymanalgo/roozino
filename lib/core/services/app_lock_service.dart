import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const _pinHashKey = 'app_lock_pin_hash';
  static const _pinSaltKey = 'app_lock_pin_salt';
  static const _biometricEnabledKey = 'app_lock_biometric_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isLockEnabled() async {
    try {
      final hash = await _storage.read(key: _pinHashKey);
      final salt = await _storage.read(key: _pinSaltKey);

      return hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<void> setPin(String pin) async {
    if (!_isValidPin(pin)) {
      throw ArgumentError('PIN باید بین ۴ تا ۶ رقم باشد.');
    }

    final salt = _generateSalt();
    final hash = _hashPin(pin: pin, salt: salt);

    await _storage.write(key: _pinSaltKey, value: salt);

    await _storage.write(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    if (!_isValidPin(pin)) {
      return false;
    }

    try {
      final storedSalt = await _storage.read(key: _pinSaltKey);

      final storedHash = await _storage.read(key: _pinHashKey);

      if (storedSalt == null ||
          storedSalt.isEmpty ||
          storedHash == null ||
          storedHash.isEmpty) {
        return false;
      }

      final enteredHash = _hashPin(pin: pin, salt: storedSalt);

      return _constantTimeEquals(enteredHash, storedHash);
    } on PlatformException {
      return false;
    }
  }

  Future<void> removeLock() async {
    await _storage.delete(key: _pinHashKey);

    await _storage.delete(key: _pinSaltKey);

    await _storage.delete(key: _biometricEnabledKey);
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;

      if (!canCheckBiometrics) {
        return false;
      }

      final biometrics = await _localAuth.getAvailableBiometrics();

      return biometrics.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _biometricEnabledKey);

      return value == 'true';
    } on PlatformException {
      return false;
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (!enabled) {
      await _storage.write(key: _biometricEnabledKey, value: 'false');

      return true;
    }

    final lockEnabled = await isLockEnabled();

    if (!lockEnabled) {
      return false;
    }

    final biometricAvailable = await isBiometricAvailable();

    if (!biometricAvailable) {
      return false;
    }

    final authenticated = await authenticateWithBiometrics();

    if (!authenticated) {
      return false;
    }

    await _storage.write(key: _biometricEnabledKey, value: 'true');

    return true;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final biometricAvailable = await isBiometricAvailable();

      if (!biometricAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'برای باز کردن روزینو هویت خود را تأیید کنید.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException {
      // Nothing to do if no authentication is active.
    }
  }

  bool _isValidPin(String pin) {
    return RegExp(r'^\d{4,6}$').hasMatch(pin);
  }

  String _generateSalt() {
    final random = Random.secure();

    final bytes = List<int>.generate(32, (_) => random.nextInt(256));

    return base64UrlEncode(bytes);
  }

  String _hashPin({required String pin, required String salt}) {
    final bytes = utf8.encode('$salt:$pin');

    return sha256.convert(bytes).toString();
  }

  bool _constantTimeEquals(String first, String second) {
    if (first.length != second.length) {
      return false;
    }

    var difference = 0;

    for (var i = 0; i < first.length; i++) {
      difference |= first.codeUnitAt(i) ^ second.codeUnitAt(i);
    }

    return difference == 0;
  }
}
