import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/app.dart';
import 'package:pomolocal/data/models/session_model.dart';
import 'package:pomolocal/data/models/settings_model.dart';
import 'package:pomolocal/data/models/note_model.dart';
import 'package:pomolocal/data/models/task_model.dart';
import 'package:pomolocal/data/repositories/session_repository.dart';
import 'package:pomolocal/data/repositories/settings_repository.dart';
import 'package:pomolocal/data/repositories/note_repository.dart';
import 'package:pomolocal/data/repositories/task_repository.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';
import 'package:pomolocal/logic/providers/settings_provider.dart';
import 'package:pomolocal/logic/providers/stats_provider.dart';
import 'package:pomolocal/logic/providers/notes_provider.dart';
import 'package:pomolocal/logic/providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(SessionAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(TaskAdapter());

  final sessionBox = await Hive.openBox<Session>('sessions');
  final settingsBox = await Hive.openBox<Settings>('settings');
  final noteBox = await Hive.openBox<Note>('notes');
  final taskBox = await Hive.openBox<Task>('tasks');

  final sessionRepo = SessionRepository(sessionBox);
  final settingsRepo = SettingsRepository(settingsBox);
  final noteRepo = NoteRepository(noteBox);
  final taskRepo = TaskRepository(taskBox);

  final timerProvider = TimerProvider(sessionRepo);
  final taskProvider = TaskProvider(taskRepo);

  // Odak oturumu tamamlanınca aktif görevin pomodoro sayacını artır
  timerProvider.onFocusComplete = () {
    taskProvider.incrementActiveTaskPomodoro();
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: timerProvider),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider(settingsRepo)),
        ChangeNotifierProvider(create: (_) => StatsProvider(sessionRepo)),
        ChangeNotifierProvider(create: (_) => NotesProvider(noteRepo)),
      ],
      child: const App(),
    ),
  );
}
