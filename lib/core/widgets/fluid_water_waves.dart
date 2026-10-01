import 'dart:math' as math;
import 'package:flutter/material.dart';

class FluidWaterWaveWidget extends StatefulWidget {
  const FluidWaterWaveWidget({
    super.key,
    required this.child,
    this.primaryColor,
    this.duration = const Duration(seconds: 3),
    this.active = true,
  });

  final Widget child;
  final Color? primaryColor;
  final Duration duration;
  final bool active;

  @override
  State<FluidWaterWaveWidget> createState() => _FluidWaterWaveWidgetState();
}

class _FluidWaterWaveWidgetState extends State<FluidWaterWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.active) {
      _startWave();
    }
  }

  @override
  void didUpdateWidget(covariant FluidWaterWaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _startWave();
    }
  }

  void _startWave() {
    setState(() => _isPlaying = true);
    _controller.reset();
    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.primaryColor ?? Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final progress = _controller.value;
                  // Fade in quickly, wave across, then fade out towards 3s
                  final opacity = (1.0 - progress).clamp(0.0, 1.0);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: opacity,
                      child: CustomPaint(
                        painter: _WaterWavePainter(
                          progress: progress,
                          color: waveColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  _WaterWavePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wave 1 - Foreground faster wave
    final p1 = Path();
    final p2 = Path();

    final baseLevel = h * (0.85 - 0.25 * math.sin(progress * math.pi));
    final amp1 = 8.0 * (1.0 - progress * 0.5);
    final amp2 = 6.0 * (1.0 - progress * 0.5);
    final phase1 = progress * 6 * math.pi;
    final phase2 = progress * 4 * math.pi + 1.2;

    p1.moveTo(0, h);
    p1.lineTo(0, baseLevel);

    p2.moveTo(0, h);
    p2.lineTo(0, baseLevel + 2);

    for (double x = 0; x <= w; x += 3) {
      final y1 = baseLevel + amp1 * math.sin((x / w) * 3 * math.pi + phase1);
      final y2 = baseLevel + amp2 * math.cos((x / w) * 2.5 * math.pi + phase2);
      p1.lineTo(x, y1);
      p2.lineTo(x, y2);
    }

    p1.lineTo(w, h);
    p1.close();

    p2.lineTo(w, h);
    p2.close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.28),
          color.withValues(alpha: 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(p2, paint2);
    canvas.drawPath(p1, paint1);
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
