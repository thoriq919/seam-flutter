import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._()
      : _remoteConfig = FirebaseRemoteConfig.instance;
  static FirebaseRemoteConfigService? _instance;
  factory FirebaseRemoteConfigService() =>
      _instance ??= FirebaseRemoteConfigService._();

  final FirebaseRemoteConfig _remoteConfig;

  String getString(String key) => _remoteConfig.getString(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  double getDouble(String key) => _remoteConfig.getDouble(key);

  String get fontColor =>
      _remoteConfig.getString(FirebaseRemoteConfigKeys.fontColor);
  String get fontSize =>
      _remoteConfig.getString(FirebaseRemoteConfigKeys.fontSize);

  Future<void> _setConfigSetting() async => _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 0),
        ),
      );
  Future<void> _setDefaults() async => _remoteConfig.setDefaults(
        const {
          FirebaseRemoteConfigKeys.fontColor: '#ff0000',
          FirebaseRemoteConfigKeys.fontSize: 18,
        },
      );
  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();

    if (updated) {
      print('The config has been updated.');
    } else {
      print('The config is not updated..');
    }
  }

  Future<void> initialize() async {
    await _setConfigSetting();
    await _setDefaults();
    await fetchAndActivate();
  }
}

final message = FirebaseRemoteConfigService().fontColor;
final size = FirebaseRemoteConfigService().fontSize;

class FirebaseRemoteConfigKeys {
  static const String fontColor = 'font_color';
  static const String fontSize = 'font_size';
}
