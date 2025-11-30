import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'debug_logger.dart';

/// Service to generate consistent device-based player IDs
/// This prevents ghost players from accumulating on reinstalls
class DeviceIdService {
  static const String _keyDevicePlayerId = 'device_player_id';
  static final _logger = DebugLogger();

  /// Get or generate a consistent player ID based on device hardware
  /// This ID will be the same across reinstalls on the same device
  static Future<String> getOrCreateDevicePlayerId() async {
    final prefs = await SharedPreferences.getInstance();

    // First check if we already have a device-based ID stored
    final existingId = prefs.getString(_keyDevicePlayerId);
    if (existingId != null && existingId.startsWith('massiv_')) {
      _logger.log('Using existing device-based player ID: $existingId');
      return existingId;
    }

    // Generate new device-based ID
    final deviceId = await _generateDeviceId();
    final playerId = 'massiv_$deviceId';

    // Store it
    await prefs.setString(_keyDevicePlayerId, playerId);
    _logger.log('Generated new device-based player ID: $playerId');

    return playerId;
  }

  /// Generate a consistent device identifier from hardware info
  static Future<String> _generateDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceIdentifier;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Use a combination of hardware identifiers that survive reinstalls
        // Note: androidId may change on factory reset, but fingerprint is more stable
        deviceIdentifier = [
          androidInfo.fingerprint, // Build fingerprint (hardware + software)
          androidInfo.hardware,    // Hardware name
          androidInfo.device,      // Device name
          androidInfo.model,       // Model name
          androidInfo.brand,       // Brand
        ].join('|');
        _logger.log('Android device info: ${androidInfo.model} (${androidInfo.device})');
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // iOS identifierForVendor persists across reinstalls (but not across uninstall+reinstall)
        // Combine with model info for additional uniqueness
        deviceIdentifier = [
          iosInfo.identifierForVendor ?? '',
          iosInfo.model,
          iosInfo.name,
          iosInfo.systemName,
        ].join('|');
        _logger.log('iOS device info: ${iosInfo.model} (${iosInfo.name})');
      } else {
        // Fallback for other platforms
        deviceIdentifier = 'unknown_platform_${DateTime.now().millisecondsSinceEpoch}';
        _logger.log('Unknown platform, using timestamp-based ID');
      }
    } catch (e) {
      _logger.log('Error getting device info: $e');
      // Fallback to timestamp if device info fails
      deviceIdentifier = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Hash the device identifier to create a consistent, shorter ID
    final bytes = utf8.encode(deviceIdentifier);
    final hash = sha256.convert(bytes);

    // Take first 12 characters of the hash for a manageable ID
    return hash.toString().substring(0, 12);
  }

  /// Check if we're using a legacy random UUID (for migration purposes)
  static Future<bool> isUsingLegacyId() async {
    final prefs = await SharedPreferences.getInstance();
    final builtinId = prefs.getString('builtin_player_id');
    final deviceId = prefs.getString(_keyDevicePlayerId);

    // If we have a builtin_player_id but no device_player_id, we're on legacy
    if (builtinId != null && deviceId == null) {
      return true;
    }
    // If builtin_player_id doesn't start with 'massiv_', it's a legacy UUID
    if (builtinId != null && !builtinId.startsWith('massiv_')) {
      return true;
    }
    return false;
  }

  /// Migrate from legacy random UUID to device-based ID
  /// Returns the new device-based ID
  static Future<String> migrateToDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyId = prefs.getString('builtin_player_id');

    _logger.log('Migrating from legacy ID: $legacyId');

    // Generate new device-based ID
    final newId = await getOrCreateDevicePlayerId();

    // Update the builtin_player_id to use the new device-based ID
    await prefs.setString('builtin_player_id', newId);

    _logger.log('Migrated to device-based ID: $newId');

    return newId;
  }
}
