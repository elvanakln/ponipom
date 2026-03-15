import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/app.dart';
import 'package:pomolocal/data/models/session_model.dart';
import 'package:pomolocal/data/models/settings_model.dart';
import 'package:pomolocal/data/repositories/session_repository.dart';
import 'package:pomolocal/data/repositories/settings_repository.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';
import 'package:pomolocal/logic/providers/settings_provider.dart';
import 'package:pomolocal/logic/providers/stats_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(SettingsAdapter());

  final sessionBox = await Hive.openBox<Session>('sessions');
  final settingsBox = await Hive.openBox<Settings>('settings');

  final sessionRepo = SessionRepository(sessionBox);
  final settingsRepo = SettingsRepository(settingsBox);

  runApp(
    MultiProvider(
      providers: [
        Provider<SessionRepository>.value(value: sessionRepo),
        Provider<SettingsRepository>.value(value: settingsRepo),
        ChangeNotifierProvider(create: (_) => TimerProvider(sessionRepo)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsRepo)),
        ChangeNotifierProvider(create: (_) => StatsProvider(sessionRepo)),
      ],
      child: const App(),
    ),
  );
}
