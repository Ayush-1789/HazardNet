import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_safety_app/core/constants/app_constants.dart';
import 'package:event_safety_app/models/captured_hazard_model.dart';

/// Persists captured hazard images (image + metadata).
class CapturedHazardStore {
  Future<String> _ensureStorageDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/${AppConstants.capturedHazardFolder}');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder.path;
  }

  Future<List<CapturedHazardModel>> loadHazards() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.keyCapturedHazards);
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(data) as List<dynamic>;
      final hazards = <CapturedHazardModel>[];
      for (final item in decoded) {
        try {
          hazards.add(CapturedHazardModel.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          // Skip malformed entries
        }
      }
      return hazards;
    } catch (_) {
      return [];
    }
  }

  Future<CapturedHazardModel> saveHazard({
    required CapturedHazardModel hazard,
    required Uint8List imageBytes,
  }) async {
    final storagePath = await _ensureStorageDir();
    final imageFile = File('$storagePath/${hazard.id}.jpg');
    await imageFile.writeAsBytes(imageBytes, flush: true);

    final hazardWithPath = hazard.copyWith(imagePath: imageFile.path);

    final current = await loadHazards();
    final updated = [...current, hazardWithPath];

    // Enforce storage limit by trimming oldest items
    updated.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final trimmed = updated.length > AppConstants.maxStoredCaptures
        ? updated.sublist(updated.length - AppConstants.maxStoredCaptures)
        : updated;

    final retainedIds = trimmed.map((e) => e.id).toSet();
    for (final entry in updated) {
      if (!retainedIds.contains(entry.id)) {
        final stale = File('$storagePath/${entry.id}.jpg');
        if (await stale.exists()) {
          await stale.delete();
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyCapturedHazards,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );

    return hazardWithPath;
  }

  Future<void> deleteHazard(String hazardId) async {
    final storagePath = await _ensureStorageDir();
    final imageFile = File('$storagePath/$hazardId.jpg');
    if (await imageFile.exists()) {
      await imageFile.delete();
    }

    final prefs = await SharedPreferences.getInstance();
    final current = await loadHazards();
    current.removeWhere((element) => element.id == hazardId);
    await prefs.setString(
      AppConstants.keyCapturedHazards,
      jsonEncode(current.map((e) => e.toJson()).toList()),
    );
  }
}
