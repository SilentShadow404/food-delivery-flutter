import 'package:encrypt/encrypt.dart' as enc;

/// AES-256-CBC encryption/decryption service.
///
/// Used to protect sensitive user data (delivery address, payment preference)
/// before it is stored locally or transmitted over the wire.
class EncryptionService {
  EncryptionService._();

  static final EncryptionService instance = EncryptionService._();

  // 32-byte key (256-bit AES).  In a real app store this in secure storage
  // (e.g. flutter_secure_storage) and never hard-code it.
  static const String _rawKey = 'FoodDash@SecureK3y#AES256Encrypt';
  // 16-byte IV — for a real app generate a random IV per encrypt call and
  // store it alongside the ciphertext.
  static const String _rawIv = 'FD_IV_1234567890';

  late final enc.Key _key = enc.Key.fromUtf8(_rawKey);
  late final enc.IV _iv = enc.IV.fromUtf8(_rawIv);
  late final enc.Encrypter _encrypter =
      enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  /// Returns a Base64-encoded ciphertext string.
  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decodes a Base64 ciphertext produced by [encrypt] and returns plaintext.
  /// Returns [fallback] (default empty string) if decryption fails.
  String decrypt(String cipherBase64, {String fallback = ''}) {
    try {
      final encrypted = enc.Encrypted.fromBase64(cipherBase64);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (_) {
      return fallback;
    }
  }

  /// Convenience: encrypt only when [value] is non-empty.
  String? encryptOrNull(String? value) =>
      (value == null || value.isEmpty) ? null : encrypt(value);

  /// Convenience: decrypt only when [value] looks like valid base64.
  String decryptSafe(String? value) {
    if (value == null || value.isEmpty) return '';
    // Quick sanity check – real base64 strings are multiples of 4 chars
    if (value.length % 4 != 0) return value;
    return decrypt(value);
  }
}

/// Top-level convenience accessor.
final crypto = EncryptionService.instance;
