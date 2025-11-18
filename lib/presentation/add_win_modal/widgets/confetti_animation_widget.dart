import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiAnimationWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onComplete;

  const ConfettiAnimationWidget({
    super.key,
    required this.isVisible,
    this.onComplete,
  });

  @override
  State<ConfettiAnimationWidget> createState() =>
      _ConfettiAnimationWidgetState();
}

class _ConfettiAnimationWidgetState extends State<ConfettiAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particles = List.generate(20, (index) => ConfettiParticle());

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ConfettiAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(_particles, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle() {
    final random = math.Random();
    x = random.nextDouble();
    y = 0.3 + random.nextDouble() * 0.2; // Start from middle area
    vx = (random.nextDouble() - 0.5) * 2;
    vy = random.nextDouble() * 2 + 1;

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
    ];
    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 4 + 2;
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = (random.nextDouble() - 0.5) * 10;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final currentX = particle.x * size.width + particle.vx * progress * 100;
      final currentY = particle.y * size.height + particle.vy * progress * 200;
      final currentRotation =
          particle.rotation + particle.rotationSpeed * progress;

      // Apply gravity effect
      final gravity = progress * progress * 300;
      final finalY = currentY + gravity;

      // Only draw if particle is within screen bounds
      if (currentX >= -10 &&
          currentX <= size.width + 10 &&
          finalY >= -10 &&
          finalY <= size.height + 10) {
        paint.color = particle.color.withValues(
          alpha: (1.0 - progress * 0.5).clamp(0.0, 1.0),
        );

        canvas.save();
        canvas.translate(currentX, finalY);
        canvas.rotate(currentRotation);

        // Draw confetti as small rectangles
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            const Radius.circular(1),
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
