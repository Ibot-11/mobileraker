import 'package:mobileraker/data/data_source/moonraker_database_client.dart';
import 'package:mobileraker/data/model/moonraker_db/device_fcm_settings.dart';
import 'package:mobileraker/data/repository/fcm_settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fcm_settings_repository_impl.g.dart';

@riverpod
FcmSettingsRepository fcmSettingsRepository(
    FcmSettingsRepositoryRef ref, String machineUUID) {
  return FcmSettingsRepositoryImpl(
      ref.watch(moonrakerDatabaseClientProvider(machineUUID)));
}

class FcmSettingsRepositoryImpl extends FcmSettingsRepository {
  FcmSettingsRepositoryImpl(this._databaseService);

  final MoonrakerDatabaseClient _databaseService;

  @override
  Future<DeviceFcmSettings?> get(String machineId) async {
    var json = await _databaseService.getDatabaseItem('mobileraker',
        key: 'fcm.$machineId');
    if (json == null) return null;
    return DeviceFcmSettings.fromJson(json);
  }

  @override
  Future<void> update(String machineId, DeviceFcmSettings fcmSettings) async {
    fcmSettings.lastModified = DateTime.now();

    await _databaseService.addDatabaseItem(
        'mobileraker', 'fcm.$machineId', fcmSettings);
  }
}