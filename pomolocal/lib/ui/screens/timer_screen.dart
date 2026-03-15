import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';
import 'package:pomolocal/ui/widgets/circular_timer.dart';
import 'package:pomolocal/ui/widgets/timer_controls.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Pomodoro counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < (timer.completedPomodoros % 4);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                      color: filled
                          ? timer.currentColor
                          : timer.currentColor.withOpacity(0.3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Circular timer
              CircularTimer(
                progress: timer.progress,
                timeText: timer.timeDisplay,
                label: timer.currentLabel,
                color: timer.currentColor,
              ),

              const SizedBox(height: 48),

              // Controls
              TimerControls(
                timerState: timer.state,
                color: timer.currentColor,
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
}
