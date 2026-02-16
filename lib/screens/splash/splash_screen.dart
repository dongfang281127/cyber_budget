import 'dart:math';
import 'package:flutter/material.dart';
import '../root_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late AnimationController _textController;

  final Color cyan = const Color(0xFF00E5FF);
  final Color green = const Color(0xFF00FF41);
  final Color bg = const Color(0xFF050505);

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartController.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RootPage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: GridPainter(color: cyan.withValues(alpha: 0.08)),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(320, 200),
                  painter: StockChartPainter(
                    progress: _chartController.value,
                    color: cyan,
                    glowColor: green,
                  ),
                );
              },
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 180),

                FadeTransition(
                  opacity: _textController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _textController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: Text(
                      "FINCORE",
                      style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: cyan,
                        shadows: [
                          Shadow(
                            color: cyan.withValues(alpha: 0.6),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _textController,
                  child: Text(
                    "Capital Awakening",
                    style: TextStyle(
                      fontFamily: "Courier",
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StockChartPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  StockChartPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.8);
    path.cubicTo(w * 0.1, h * 0.8, w * 0.15, h * 0.9, w * 0.25, h * 0.6);
    path.cubicTo(w * 0.35, h * 0.3, w * 0.4, h * 0.8, w * 0.5, h * 0.5);
    path.cubicTo(w * 0.6, h * 0.2, w * 0.7, h * 0.9, w * 0.8, h * 0.1);
    path.lineTo(w, h * 0.05);

    final metrics = path.computeMetrics();
    final drawPath = Path();

    for (final metric in metrics) {
      drawPath.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    canvas.drawPath(drawPath, glowPaint);
    canvas.drawPath(drawPath, linePaint);

    if (progress > 0.02) {
      final metric = drawPath.computeMetrics().last;
      final tangent = metric.getTangentForOffset(metric.length);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          5,
          Paint()..color = Colors.white,
        );

        canvas.drawCircle(
          tangent.position,
          12,
          Paint()..color = color.withValues(alpha: 0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant StockChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
