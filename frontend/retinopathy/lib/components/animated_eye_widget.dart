import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AnimatedEyeWidget extends StatefulWidget {
  final double size;
  final bool autoRotate;
  final bool showAIBadge;

  const AnimatedEyeWidget({
    super.key,
    this.size = 200,
    this.autoRotate = true,
    this.showAIBadge = true,
  });

  @override
  State<AnimatedEyeWidget> createState() => _AnimatedEyeWidgetState();
}

class _AnimatedEyeWidgetState extends State<AnimatedEyeWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _blinkController;
  late AnimationController _pupilController;
  late AnimationController _glowController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _blinkAnimation;
  late Animation<double> _pupilAnimation;
  late Animation<double> _glowAnimation;
  
  double _rotationX = 0;
  double _rotationY = 0;
  Offset? _lastPanPosition;

  @override
  void initState() {
    super.initState();
    
    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    
    // Blink animation (random blinking)
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.05).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
    _startRandomBlinking();
    
    // Pupil dilation animation (breathing effect)
    _pupilController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pupilAnimation = Tween<double>(begin: 0.2, end: 0.28).animate(
      CurvedAnimation(parent: _pupilController, curve: Curves.easeInOut),
    );
    
    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startRandomBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + (math.Random().nextInt(3000))), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startRandomBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _blinkController.dispose();
    _pupilController.dispose();
    _glowController.dispose();
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
          animation: Listenable.merge([
            _rotationController,
            _blinkController,
            _pupilController,
            _glowController,
          ]),
          builder: (context, child) {
            final rotation = autoRotate ? _rotationAnimation.value : 0.0;
            final combinedRotationY = rotation + _rotationY;
            final combinedRotationX = _rotationX;
            final blinkHeight = _blinkAnimation.value;
            final pupilSize = _pupilAnimation.value;
            final glowOpacity = _glowAnimation.value;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(combinedRotationY)
                ..rotateX(combinedRotationX),
              child: _buildEyeStructure(size, blinkHeight, pupilSize, glowOpacity),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEyeStructure(double size, double blinkHeight, double pupilSize, double glowOpacity) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        Container(
          width: size * 1.2,
          height: size * 1.2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primaryBlue.withOpacity(glowOpacity * 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Sclera (white outer part)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, -size * 0.1),
          child: Container(
            width: size,
            height: size * 0.7 * blinkHeight,
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
        // Iris base with animated colors
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.05),
          child: Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFF4A90E2),
                    const Color(0xFF2ECC71),
                    math.sin(_glowController.value * math.pi * 2) * 0.5 + 0.5,
                  )!,
                  const Color(0xFF6B6B6B),
                  const Color(0xFF4A4A4A),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(glowOpacity * 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated iris pattern
                CustomPaint(
                  size: Size(size * 0.5, size * 0.5),
                  painter: AnimatedIrisPatternPainter(_glowController.value),
                ),
                // Iris color overlay with animation
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color.lerp(
                          const Color(0xFF8B4513).withOpacity(0.6),
                          const Color(0xFF4A90E2).withOpacity(0.4),
                          math.sin(_glowController.value * math.pi * 2) * 0.5 + 0.5,
                        )!,
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
        // Animated Pupil (breathing effect)
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..translate(0.0, 0.0, size * 0.1),
          child: Container(
            width: size * pupilSize,
            height: size * pupilSize,
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
        // Animated Cornea highlight/reflection
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
        // Eyelid shadows
        Positioned(
          top: 0,
          child: Container(
            width: size,
            height: size * 0.15 * (1 - blinkHeight),
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
        Positioned(
          bottom: 0,
          child: Container(
            width: size,
            height: size * 0.15 * (1 - blinkHeight),
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
        // AI Badge overlay with pulse
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
                      color: AppTheme.primaryBlue.withOpacity(_glowAnimation.value * 0.5),
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

// Animated iris pattern painter
class AnimatedIrisPatternPainter extends CustomPainter {
  final double animationValue;

  AnimatedIrisPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3 + math.sin(animationValue * math.pi * 2) * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw radial lines for iris pattern
    for (int i = 0; i < 24; i++) {
      final angle = (i * math.pi * 2) / 24 + animationValue * 0.1;
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
  bool shouldRepaint(covariant AnimatedIrisPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

