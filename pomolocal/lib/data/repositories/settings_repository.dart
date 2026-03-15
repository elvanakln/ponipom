import 'package:hive/hive.dart';
import 'package:pomolocal/data/models/settings_model.dart';

class SettingsRepository {
  final Box<Settings> _box;

  SettingsRepository(this._box);

  Settings get() {
    final settings = _box.get('settings');
    if (settings != null) return settings;

    final defaults = Settings.defaults();
    save(defaults);
    return defaults;
  }

  Future<void> save(Settings settings) async {
    await _box.put('settings', settings);
  }
}
