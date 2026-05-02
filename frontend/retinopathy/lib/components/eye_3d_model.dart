import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class Eye3DModel extends StatefulWidget {
  final double size;
  final bool autoRotate;
  final bool showAIBadge;

  const Eye3DModel({
    super.key,
    this.size = 200,
    this.autoRotate = true,
    this.showAIBadge = true,
  });

  @override
  State<Eye3DModel> createState() => _Eye3DModelState();
}

class _Eye3DModelState extends State<Eye3DModel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0;
  double _rotationY = 0;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition != null) {
      final delta = details.localPosition - _lastPanPosition!;
      setState(() {
        _rotationY += delta.dx * 0.01;
        _rotationX -= delta.dy * 0.01;
        _rotationX = _rotationX.clamp(-0.5, 0.5);
        _rotationY = _rotationY.clamp(-0.5, 0.5);
      });
    }
    _lastPanPosition = details.localPosition;
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final autoRotate = widget.autoRotate;

    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final rotation = autoRotate ? _controller.value * 2 * math.pi : 0.0;
            final combinedRotationY = rotation + _rotationY;
            final combinedRotationX = _rotationX;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(combinedRotationY)
                ..rotateX(combinedRotationX),
              child: _buildEyeStructure(size),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEyeStructure(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sclera (white outer part) - with 3D depth
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, -size * 0.1),
          child: Container(
            width: size,
            height: size * 0.7,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(size * 0.35),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFE8E8E8),
                  Color(0xFFF5F5F5),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),

        // Iris base (colored part) - with depth
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.05),
          child: Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFF4A4A4A), // Dark outer ring
                  Color(0xFF6B6B6B), // Medium
                  Color(0xFF4A4A4A), // Dark inner
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Iris pattern - radial lines
                CustomPaint(
                  size: Size(size * 0.5, size * 0.5),
                  painter: IrisPatternPainter(),
                ),
                // Iris color overlay (brown/hazel)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B4513).withOpacity(0.6), // Brown
                        const Color(0xFF654321).withOpacity(0.8),
                        const Color(0xFF4A4A4A).withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pupil (black center)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.1),
          child: Container(
            width: size * 0.25,
            height: size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF000000),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ),

        // Cornea highlight/reflection
        Positioned(
          top: size * 0.15,
          left: size * 0.2,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.15),
            child: Container(
              width: size * 0.15,
              height: size * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFFFFF).withOpacity(0.8),
                    const Color(0xFFFFFFFF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Eyelid shadow (top)
        Positioned(
          top: 0,
          child: Container(
            width: size,
            height: size * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size * 0.35),
                topRight: Radius.circular(size * 0.35),
              ),
            ),
          ),
        ),

        // Eyelid shadow (bottom)
        Positioned(
          bottom: 0,
          child: Container(
            width: size,
            height: size * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(size * 0.35),
                bottomRight: Radius.circular(size * 0.35),
              ),
            ),
          ),
        ),

        // AI Badge overlay
        if (widget.showAIBadge)
          Positioned(
            top: size * 0.05,
            right: size * 0.05,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.2),
              child: Container(
                padding: EdgeInsets.all(size * 0.03),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppTheme.white,
                  size: size * 0.08,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Custom painter for iris pattern
class IrisPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radial lines for iris pattern
    for (int i = 0; i < 24; i++) {
      final angle = (i * math.pi * 2) / 24;
      final startRadius = radius * 0.3;
      final endRadius = radius * 0.9;
      
      final startX = center.dx + math.cos(angle) * startRadius;
      final startY = center.dy + math.sin(angle) * startRadius;
      final endX = center.dx + math.cos(angle) * endRadius;
      final endY = center.dy + math.sin(angle) * endRadius;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      final circleRadius = radius * (0.3 + i * 0.2);
      canvas.drawCircle(center, circleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

