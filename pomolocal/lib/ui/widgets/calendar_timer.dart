import 'package:flutter/material.dart';

/// Flip clock görünümü — büyük rakam panelleri, orta çizgi
class CalendarTimer extends StatelessWidget {
  final double progress;
  final String timeText;
  final String label;
  final Color color;

  const CalendarTimer({
    super.key,
    required this.progress,
    required this.timeText,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = timeText.split(':');
    final minutes = parts[0];
    final seconds = parts[1];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Oturum etiketi
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        // Flip clock panelleri
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FlipPanel(digit: minutes[0], color: color, theme: theme),
            const SizedBox(width: 4),
            _FlipPanel(digit: minutes[1], color: color, theme: theme),

            // İki nokta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),

            _FlipPanel(digit: seconds[0], color: color, theme: theme),
            const SizedBox(width: 4),
            _FlipPanel(digit: seconds[1], color: color, theme: theme),
          ],
        ),

        const SizedBox(height: 10),

        // dk / sn etiketleri
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 116,
              child: Center(
                child: Text(
                  'dakika',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            SizedBox(
              width: 116,
              child: Center(
                child: Text(
                  'saniye',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // İlerleme çubuğu
        SizedBox(
          width: 262,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tek rakam paneli — flip clock kartı
class _FlipPanel extends StatefulWidget {
  final String digit;
  final Color color;
  final ThemeData theme;

  const _FlipPanel({
    required this.digit,
    required this.color,
    required this.theme,
  });

  @override
  State<_FlipPanel> createState() => _FlipPanelState();
}

class _FlipPanelState extends State<_FlipPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _oldDigit = '';
  String _newDigit = '';

  @override
  void initState() {
    super.initState();
    _oldDigit = widget.digit;
    _newDigit = widget.digit;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant _FlipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _oldDigit = oldWidget.digit;
      _newDigit = widget.digit;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const w = 56.0;
    const h = 80.0;
    final panelColor = widget.theme.colorScheme.surfaceContainerHigh;
    final textColor = widget.theme.colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final showNew = _controller.value > 0.5;
        final displayDigit = showNew ? _newDigit : _oldDigit;

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              // Üst yarı — her zaman yeni rakamı gösterir (alttan görünür)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: h / 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: panelColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: h,
                      child: _digitText(_newDigit, h, textColor),
                    ),
                  ),
                ),
              ),

              // Alt yarı
              Positioned(
                top: h / 2,
                left: 0,
                right: 0,
                height: h / 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: panelColor.withOpacity(0.92),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                    child: OverflowBox(
                      alignment: Alignment.bottomCenter,
                      maxHeight: h,
                      child: _digitText(displayDigit, h, textColor),
                    ),
                  ),
                ),
              ),

              // Orta çizgi
              Positioned(
                top: h / 2 - 1,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: widget.color.withOpacity(0.12),
                ),
              ),

              // Sol-sağ küçük çentikler (flip clock detayı)
              Positioned(
                top: h / 2 - 3,
                left: 0,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(3),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: h / 2 - 3,
                right: 0,
                child: Container(
                  width: 4,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _digitText(String digit, double h, Color textColor) {
    return SizedBox(
      height: h,
      child: Center(
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w300,
            color: textColor,
            height: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// AnimatedWidget builder
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
