import 'package:flutter/material.dart';

/// Animated radar/seismograph pulse showing the app is alive and listening.
/// When [active] it emits expanding concentric waves; otherwise it sits still.
class PulseIndicator extends StatefulWidget {
  const PulseIndicator({
    super.key,
    required this.color,
    required this.active,
    this.icon = Icons.graphic_eq,
    this.size = 200,
  });

  final Color color;
  final bool active;
  final IconData icon;
  final double size;

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant PulseIndicator old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: _PulsePainter(
                t: _c.value,
                color: widget.color,
                active: widget.active,
              ),
            ),
          ),
          Icon(widget.icon, size: widget.size * 0.20, color: Colors.white),
        ],
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.t, required this.color, required this.active});

  final double t;
  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    final coreR = maxR * 0.24;

    if (active) {
      const waves = 3;
      for (var i = 0; i < waves; i++) {
        final phase = (t + i / waves) % 1.0;
        final r = coreR + (maxR - coreR) * phase;
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color.withValues(alpha: (1.0 - phase) * 0.5);
        canvas.drawCircle(center, r, paint);
      }
    }

    // soft glow + solid core
    canvas.drawCircle(
      center,
      coreR * 1.7,
      Paint()..color = color.withValues(alpha: active ? 0.18 : 0.10),
    );
    canvas.drawCircle(center, coreR, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) =>
      old.t != t || old.color != color || old.active != active;
}
