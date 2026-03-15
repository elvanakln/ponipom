import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/logic/providers/settings_provider.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Timer durations
              _SectionTitle('Timer Durations'),
              const SizedBox(height: 8),
              _DurationTile(
                title: 'Focus',
                value: settings.focusDuration,
                min: 1,
                max: 90,
                onChanged: (v) {
                  settings.update(focusDuration: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Short Break',
                value: settings.shortBreak,
                min: 1,
                max: 30,
                onChanged: (v) {
                  settings.update(shortBreak: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Long Break',
                value: settings.longBreak,
                min: 1,
                max: 60,
                onChanged: (v) {
                  settings.update(longBreak: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Long Break Interval',
                value: settings.longBreakInterval,
                min: 2,
                max: 8,
                suffix: 'sessions',
                onChanged: (v) {
                  settings.update(longBreakInterval: v);
                  _syncTimer(context);
                },
              ),

              const SizedBox(height: 24),

              // Behavior
              _SectionTitle('Behavior'),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Auto-start next session'),
                subtitle: const Text('Automatically start the next timer'),
                value: settings.autoStart,
                onChanged: (v) {
                  settings.update(autoStart: v);
                  _syncTimer(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _syncTimer(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    context.read<TimerProvider>().updateSettings(
          focusDuration: settings.focusDuration,
          shortBreak: settings.shortBreak,
          longBreak: settings.longBreak,
          longBreakInterval: settings.longBreakInterval,
          autoStart: settings.autoStart,
        );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _DurationTile extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _DurationTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.suffix = 'min',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$value $suffix',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
