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
        final theme = Theme.of(context);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              // ── Başlık ──
              Text(
                'Ayarlar',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Uygulamayı kişiselleştir',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // ═══ Tema ═══
              _SettingsSection(
                title: 'Görünüm',
                icon: Icons.palette_outlined,
                theme: theme,
                children: [
                  const SizedBox(height: 14),
                  _ThemeSelector(
                    current: settings.themeMode,
                    onChanged: (mode) => settings.update(themeMode: mode),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sayaç Stili',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DisplayStyleSelector(
                    current: settings.timerDisplayStyle,
                    onChanged: (style) =>
                        settings.update(timerDisplayStyle: style),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ═══ Süreler ═══
              _SettingsSection(
                title: 'Süre Ayarları',
                icon: Icons.timer_outlined,
                theme: theme,
                children: [
                  const SizedBox(height: 8),
                  _DurationTile(
                    title: 'Odaklanma',
                    icon: Icons.center_focus_strong_rounded,
                    value: settings.focusDuration,
                    min: 1,
                    max: 90,
                    color: const Color(0xFFE53935),
                    onChanged: (v) {
                      settings.update(focusDuration: v);
                      _syncTimer(context);
                    },
                    theme: theme,
                  ),
                  _DurationTile(
                    title: 'Kısa Mola',
                    icon: Icons.coffee_rounded,
                    value: settings.shortBreak,
                    min: 1,
                    max: 30,
                    color: const Color(0xFF43A047),
                    onChanged: (v) {
                      settings.update(shortBreak: v);
                      _syncTimer(context);
                    },
                    theme: theme,
                  ),
                  _DurationTile(
                    title: 'Uzun Mola',
                    icon: Icons.self_improvement_rounded,
                    value: settings.longBreak,
                    min: 1,
                    max: 60,
                    color: const Color(0xFF1E88E5),
                    onChanged: (v) {
                      settings.update(longBreak: v);
                      _syncTimer(context);
                    },
                    theme: theme,
                  ),
                  _DurationTile(
                    title: 'Uzun Mola Aralığı',
                    icon: Icons.repeat_rounded,
                    value: settings.longBreakInterval,
                    min: 2,
                    max: 8,
                    suffix: 'oturum',
                    color: const Color(0xFF8E24AA),
                    onChanged: (v) {
                      settings.update(longBreakInterval: v);
                      _syncTimer(context);
                    },
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ═══ Davranış ═══
              _SettingsSection(
                title: 'Davranış',
                icon: Icons.tune_rounded,
                theme: theme,
                children: [
                  const SizedBox(height: 4),
                  _ToggleTile(
                    title: 'Otomatik başlat',
                    subtitle: 'Sonraki oturumu otomatik başlat',
                    icon: Icons.play_circle_outline_rounded,
                    value: settings.autoStart,
                    onChanged: (v) {
                      settings.update(autoStart: v);
                      _syncTimer(context);
                    },
                    theme: theme,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Uygulama bilgisi ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'PomoLocal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sıfır Sunucu, Tam Gizlilik, Maksimum Odak.',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
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

// ═══════════════════════════════════════
// Ayarlar Bölüm Kartı
// ═══════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          ...children,
        ],
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: 0.3,
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
                ? theme.colorScheme.primaryContainer.withOpacity(0.6)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Süre Ayarı ──

class _DurationTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final Color color;
  final ValueChanged<int> onChanged;
  final ThemeData theme;

  const _DurationTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    this.suffix = 'dk',
    required this.color,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniStepperBtn(
                  icon: Icons.remove_rounded,
                  enabled: value > min,
                  onTap: () => onChanged(value - 1),
                  theme: theme,
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '$value $suffix',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                _MiniStepperBtn(
                  icon: Icons.add_rounded,
                  enabled: value < max,
                  onTap: () => onChanged(value + 1),
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStepperBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MiniStepperBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}

// ── Toggle Tile ──

class _ToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
