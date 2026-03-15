import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/core/enums.dart';
import 'package:pomolocal/core/theme.dart';
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
                'Ayarlar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              _SectionTitle('Tema'),
              const SizedBox(height: 12),
              _ThemeSelector(
                current: settings.themeMode,
                onChanged: (mode) => settings.update(themeMode: mode),
              ),

              const SizedBox(height: 24),

              _SectionTitle('Sayaç Görünümü'),
              const SizedBox(height: 12),
              _DisplayStyleSelector(
                current: settings.timerDisplayStyle,
                onChanged: (style) =>
                    settings.update(timerDisplayStyle: style),
              ),

              const SizedBox(height: 24),

              _SectionTitle('Süre Ayarları'),
              const SizedBox(height: 8),
              _DurationTile(
                title: 'Odaklanma',
                value: settings.focusDuration,
                min: 1,
                max: 90,
                onChanged: (v) {
                  settings.update(focusDuration: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Kısa Mola',
                value: settings.shortBreak,
                min: 1,
                max: 30,
                onChanged: (v) {
                  settings.update(shortBreak: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Uzun Mola',
                value: settings.longBreak,
                min: 1,
                max: 60,
                onChanged: (v) {
                  settings.update(longBreak: v);
                  _syncTimer(context);
                },
              ),
              _DurationTile(
                title: 'Uzun Mola Aralığı',
                value: settings.longBreakInterval,
                min: 2,
                max: 8,
                suffix: 'oturum',
                onChanged: (v) {
                  settings.update(longBreakInterval: v);
                  _syncTimer(context);
                },
              ),

              const SizedBox(height: 24),

              _SectionTitle('Davranış'),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Otomatik başlat'),
                subtitle: const Text('Sonraki oturumu otomatik başlat'),
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

// ── Tema Seçici ──

class _ThemeSelector extends StatelessWidget {
  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeChip(
          label: 'Açık',
          icon: Icons.light_mode_rounded,
          color: const Color(0xFFFAF8F5),
          textColor: Colors.black87,
          isSelected: current == AppThemeMode.light,
          onTap: () => onChanged(AppThemeMode.light),
        ),
        const SizedBox(width: 10),
        _ThemeChip(
          label: 'Koyu',
          icon: Icons.dark_mode_rounded,
          color: const Color(0xFF1A1A1A),
          textColor: Colors.white,
          isSelected: current == AppThemeMode.dark,
          onTap: () => onChanged(AppThemeMode.dark),
        ),
        const SizedBox(width: 10),
        _ThemeChip(
          label: 'Pembe',
          icon: Icons.favorite_rounded,
          color: const Color(0xFFE91E63),
          textColor: Colors.white,
          isSelected: current == AppThemeMode.pink,
          onTap: () => onChanged(AppThemeMode.pink),
        ),
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Görünüm Seçici ──

class _DisplayStyleSelector extends StatelessWidget {
  final TimerDisplayStyle current;
  final ValueChanged<TimerDisplayStyle> onChanged;

  const _DisplayStyleSelector({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _styleOption(theme, 'Halka', Icons.radio_button_unchecked,
            TimerDisplayStyle.circular),
        const SizedBox(width: 10),
        _styleOption(theme, 'Yaprak', Icons.calendar_today_rounded,
            TimerDisplayStyle.calendar),
        const SizedBox(width: 10),
        _styleOption(theme, 'Minimal', Icons.text_fields_rounded,
            TimerDisplayStyle.minimal),
      ],
    );
  }

  Widget _styleOption(
      ThemeData theme, String label, IconData icon, TimerDisplayStyle style) {
    final isSelected = current == style;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(style),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bölüm Başlığı ──

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

// ── Süre Ayarı ──

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
    this.suffix = 'dk',
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
            width: 64,
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
