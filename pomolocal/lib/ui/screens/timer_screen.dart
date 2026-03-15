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

              // Pomodoro noktaları (görev varsa görev hedefine göre)
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
    final color =
        task.taskColor != null ? Color(task.taskColor!) : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              task.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (task.focusDuration > 0) ...[
            const SizedBox(width: 8),
            Text(
              '${task.focusDuration}dk',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pomodoro noktaları — görev varsa hedef sayısına göre
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
    final total = activeTask?.pomodorosTarget ?? 4;
    final spent = activeTask?.pomodorosSpent ?? (timer.completedPomodoros % 4);
    final color = taskColor ?? timer.currentColor;

    // Çok fazla nokta olmasın, max 10
    final displayTotal = total > 10 ? 10 : total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(displayTotal, (i) {
            final filled = i < spent;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: filled ? color : color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
        if (activeTask != null) ...[
          const SizedBox(height: 6),
          Text(
            '$spent / $total pomodoro',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
