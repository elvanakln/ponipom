import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/core/enums.dart';
import 'package:pomolocal/data/models/task_model.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';
import 'package:pomolocal/logic/providers/settings_provider.dart';
import 'package:pomolocal/logic/providers/task_provider.dart';
import 'package:pomolocal/ui/widgets/circular_timer.dart';
import 'package:pomolocal/ui/widgets/calendar_timer.dart';
import 'package:pomolocal/ui/widgets/minimal_timer.dart';
import 'package:pomolocal/ui/widgets/timer_controls.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<TimerProvider, SettingsProvider, TaskProvider>(
      builder: (context, timer, settings, taskProv, _) {
        final activeTask = taskProv.activeTask;
        final taskColor = activeTask?.taskColor != null
            ? Color(activeTask!.taskColor!)
            : null;

        return SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Aktif görev bilgisi
              if (activeTask != null) _ActiveTaskBadge(task: activeTask),

              // Pomodoro noktaları
              _PomodoroDotsRow(
                timer: timer,
                activeTask: activeTask,
                taskColor: taskColor,
              ),

              const SizedBox(height: 32),

              // Sayaç
              _buildTimerDisplay(timer, settings.timerDisplayStyle),

              const SizedBox(height: 40),

              // Kontroller
              TimerControls(
                timerState: timer.state,
                color: taskColor ?? timer.currentColor,
                onStart: timer.start,
                onPause: timer.pause,
                onResume: timer.resume,
                onReset: timer.reset,
                onSkip: timer.skipToNext,
              ),

              const Spacer(flex: 3),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay(TimerProvider timer, TimerDisplayStyle style) {
    switch (style) {
      case TimerDisplayStyle.circular:
        return CircularTimer(
          progress: timer.progress,
          timeText: timer.timeDisplay,
          label: timer.currentLabel,
          color: timer.currentColor,
        );
      case TimerDisplayStyle.calendar:
        return CalendarTimer(
          progress: timer.progress,
          timeText: timer.timeDisplay,
          label: timer.currentLabel,
          color: timer.currentColor,
        );
      case TimerDisplayStyle.minimal:
        return MinimalTimer(
          progress: timer.progress,
          timeText: timer.timeDisplay,
          label: timer.currentLabel,
          color: timer.currentColor,
        );
    }
  }
}

/// Aktif görev etiketi
class _ActiveTaskBadge extends StatelessWidget {
  final Task task;
  const _ActiveTaskBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = task.taskColor != null
        ? Color(task.taskColor!)
        : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              task.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (task.focusDuration > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${task.focusDuration}dk',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pomodoro noktaları
class _PomodoroDotsRow extends StatelessWidget {
  final TimerProvider timer;
  final Task? activeTask;
  final Color? taskColor;

  const _PomodoroDotsRow({
    required this.timer,
    required this.activeTask,
    this.taskColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = activeTask?.pomodorosTarget ?? 4;
    final spent = activeTask?.pomodorosSpent ?? (timer.completedPomodoros % 4);
    final color = taskColor ?? timer.currentColor;
    final displayTotal = total > 10 ? 10 : total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(displayTotal, (i) {
            final filled = i < spent;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: filled ? 12 : 10,
                height: filled ? 12 : 10,
                decoration: BoxDecoration(
                  color: filled ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: filled ? color : color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: filled
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
        if (activeTask != null) ...[
          const SizedBox(height: 8),
          Text(
            '$spent / $total pomodoro',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
