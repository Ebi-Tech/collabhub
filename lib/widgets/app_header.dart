import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:collabhub/utils/constants.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(Icons.group_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CollabHub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface(context),
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Find Your Team',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.46;
    final stroke = size.width * 0.18;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red arc  (top-right → top-left, ~90°)
    paint.color = AppColors.googleRed;
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.55, false, paint);

    // Yellow arc (left, ~90°)
    paint.color = AppColors.googleYellow;
    canvas.drawArc(rect, -math.pi * 1.25, math.pi * 0.55, false, paint);

    // Green arc (bottom, ~90°)
    paint.color = AppColors.googleGreen;
    canvas.drawArc(rect, math.pi * 0.45, math.pi * 0.55, false, paint);

    // Blue arc (bottom-right → right, ~80°)
    paint.color = AppColors.googleBlue;
    canvas.drawArc(rect, math.pi * 1.0, math.pi * 0.42, false, paint);

    // Blue horizontal bar on the right half
    paint.strokeWidth = stroke;
    paint.strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r, cy),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}
