import 'package:flutter/material.dart';
import 'package:pomolocal/core/enums.dart';

class TimerControls extends StatelessWidget {
  final TimerState timerState;
  final Color color;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const TimerControls({
    super.key,
    required this.timerState,
    required this.color,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (timerState != TimerState.idle)
          IconButton.filled(
            onPressed: onReset,
            icon: const Icon(Icons.stop_rounded),
            iconSize: 32,
            style: IconButton.styleFrom(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
            ),
          ),
        const SizedBox(width: 16),
        _buildMainButton(),
        const SizedBox(width: 16),
        IconButton.filled(
          onPressed: onSkip,
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    switch (timerState) {
      case TimerState.idle:
        return FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.play_arrow_rounded, size: 32),
          label: const Text('Başla', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );
      case TimerState.running:
        return FilledButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_rounded, size: 32),
          label: const Text('Duraklat', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );
      case TimerState.paused:
        return FilledButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.play_arrow_rounded, size: 32),
          label: const Text('Devam', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );
    }
  }
}
