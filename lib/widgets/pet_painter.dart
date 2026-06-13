import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

class PetWidget extends StatefulWidget {
  final String stage; // 'egg', 'baby', 'young', 'adult', 'legendary'
  final String visualType; // 'slime', 'dragon', 'griffin'
  final double size;

  const PetWidget({
    super.key,
    required this.stage,
    required this.visualType,
    this.size = 180,
  });

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

class _PetWidgetState extends State<PetWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: PetPainter(
            stage: widget.stage,
            visualType: widget.visualType,
            bounceValue: _controller.value,
          ),
        );
      },
    );
  }
}

class PetPainter extends CustomPainter {
  final String stage;
  final String visualType;
  final double bounceValue;

  PetPainter({
    required this.stage,
    required this.visualType,
    required this.bounceValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Bounce Offset: pet breathes (squashes and stretches) and floats
    final floatOffset = bounceValue * 8; // Float up/down by 8 pixels
    final squashX = 1 + (bounceValue * 0.05); // Width stretches slightly
    final squashY = 1 - (bounceValue * 0.05); // Height squashes slightly

    canvas.save();
    // Apply floating and squash/stretch matrix transformations
    canvas.translate(center.dx, center.dy + floatOffset);
    canvas.scale(squashX, squashY);
    canvas.translate(-center.dx, -center.dy);

    final mainPaint = Paint()..isAntiAlias = true;

    if (stage == 'egg') {
      _drawEgg(canvas, size, mainPaint);
    } else {
      if (visualType == 'slime') {
        _drawSlime(canvas, size, mainPaint);
      } else if (visualType == 'dragon') {
        _drawDragon(canvas, size, mainPaint);
      } else {
        _drawGriffin(canvas, size, mainPaint);
      }
    }

    canvas.restore();
  }

  void _drawEgg(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw shadow
    final shadowPaint = Paint()..color = Colors.black.withAlpha(50);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, size.height * 0.8), width: size.width * 0.4, height: 10),
      shadowPaint,
    );

    // Egg Shape Path
    final eggPath = Path();
    eggPath.moveTo(size.width * 0.5, size.height * 0.2);
    eggPath.cubicTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.25, size.height * 0.8,
      size.width * 0.5, size.height * 0.8,
    );
    eggPath.cubicTo(
      size.width * 0.75, size.height * 0.8,
      size.width * 0.75, size.height * 0.2,
      size.width * 0.5, size.height * 0.2,
    );
    eggPath.close();

    // Color based on type
    if (visualType == 'slime') {
      paint.shader = const LinearGradient(
        colors: [Color(0xff00ff87), Color(0xff60efff)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(eggPath.getBounds());
    } else if (visualType == 'dragon') {
      paint.shader = const LinearGradient(
        colors: [Color(0xffff007f), Color(0xffffaa00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(eggPath.getBounds());
    } else {
      paint.shader = const LinearGradient(
        colors: [RpgColors.primary, RpgColors.accent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(eggPath.getBounds());
    }

    canvas.drawPath(eggPath, paint);

    // Draw spots/scales on the egg
    final spotPaint = Paint()..color = Colors.white.withAlpha(60);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.45), 8, spotPaint);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.58), 12, spotPaint);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.65), 6, spotPaint);
  }

  void _drawSlime(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height * 0.55);
    double radius = size.width * 0.25;

    // Adjust scale based on stage
    if (stage == 'baby') radius = size.width * 0.16;
    if (stage == 'young') radius = size.width * 0.22;
    if (stage == 'adult') radius = size.width * 0.28;
    if (stage == 'legendary') radius = size.width * 0.32;

    // Slime Body Path
    final slimePath = Path();
    slimePath.moveTo(center.dx - radius, center.dy);
    slimePath.cubicTo(
      center.dx - radius, center.dy - radius * 1.3,
      center.dx + radius, center.dy - radius * 1.3,
      center.dx + radius, center.dy,
    );
    slimePath.cubicTo(
      center.dx + radius, center.dy + radius * 0.7,
      center.dx - radius, center.dy + radius * 0.7,
      center.dx - radius, center.dy,
    );
    slimePath.close();

    // Fill Color
    paint.shader = LinearGradient(
      colors: stage == 'legendary' 
          ? [const Color(0xffda22ff), const Color(0xff9733ee)]
          : [RpgColors.primary, RpgColors.primary.withBlue(240)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(slimePath.getBounds());

    canvas.drawPath(slimePath, paint);

    // Face drawing
    final eyePaint = Paint()..color = Colors.black;
    final cheekPaint = Paint()..color = Colors.pinkAccent.withAlpha(150);

    final leftEye = Offset(center.dx - radius * 0.35, center.dy - radius * 0.1);
    final rightEye = Offset(center.dx + radius * 0.35, center.dy - radius * 0.1);

    canvas.drawCircle(leftEye, radius * 0.1, eyePaint);
    canvas.drawCircle(rightEye, radius * 0.1, eyePaint);
    
    // Blush cheeks
    canvas.drawCircle(Offset(leftEye.dx - 4, leftEye.dy + 8), radius * 0.12, cheekPaint);
    canvas.drawCircle(Offset(rightEye.dx + 4, rightEye.dy + 8), radius * 0.12, cheekPaint);

    // Smile mouth
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: radius * 0.25, height: radius * 0.15),
      0, pi, false, mouthPaint,
    );

    // Unlocks/Cosmetics based on stage
    if (stage == 'young' || stage == 'adult' || stage == 'legendary') {
      // Golden Crown
      final crownPaint = Paint()..color = RpgColors.accent;
      final crownPath = Path();
      crownPath.moveTo(center.dx - radius * 0.3, center.dy - radius * 0.95);
      crownPath.lineTo(center.dx - radius * 0.4, center.dy - radius * 1.35);
      crownPath.lineTo(center.dx - radius * 0.1, center.dy - radius * 1.15);
      crownPath.lineTo(center.dx, center.dy - radius * 1.45);
      crownPath.lineTo(center.dx + radius * 0.1, center.dy - radius * 1.15);
      crownPath.lineTo(center.dx + radius * 0.4, center.dy - radius * 1.35);
      crownPath.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.95);
      crownPath.close();
      canvas.drawPath(crownPath, crownPaint);
    }

    if (stage == 'legendary') {
      // Little angel/slime wings
      final wingPaint = Paint()..color = Colors.white.withAlpha(180);
      final wingPathLeft = Path();
      wingPathLeft.moveTo(center.dx - radius * 0.9, center.dy - radius * 0.2);
      wingPathLeft.quadraticBezierTo(
        center.dx - radius * 1.5, center.dy - radius * 0.8,
        center.dx - radius * 1.6, center.dy - radius * 0.3,
      );
      wingPathLeft.quadraticBezierTo(
        center.dx - radius * 1.2, center.dy + radius * 0.1,
        center.dx - radius * 0.9, center.dy - radius * 0.2,
      );
      canvas.drawPath(wingPathLeft, wingPaint);

      final wingPathRight = Path();
      wingPathRight.moveTo(center.dx + radius * 0.9, center.dy - radius * 0.2);
      wingPathRight.quadraticBezierTo(
        center.dx + radius * 1.5, center.dy - radius * 0.8,
        center.dx + radius * 1.6, center.dy - radius * 0.3,
      );
      wingPathRight.quadraticBezierTo(
        center.dx + radius * 1.2, center.dy + radius * 0.1,
        center.dx + radius * 0.9, center.dy - radius * 0.2,
      );
      canvas.drawPath(wingPathRight, wingPaint);
    }
  }

  void _drawDragon(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height * 0.55);
    double radius = size.width * 0.25;

    if (stage == 'baby') radius = size.width * 0.15;
    if (stage == 'young') radius = size.width * 0.22;
    if (stage == 'adult') radius = size.width * 0.28;
    if (stage == 'legendary') radius = size.width * 0.32;

    // Dragon head/body path
    final headRect = Rect.fromCenter(center: center, width: radius * 1.8, height: radius * 1.8);
    paint.shader = LinearGradient(
      colors: stage == 'legendary' 
          ? [RpgColors.accent, const Color(0xffff3300)]
          : [const Color(0xffff3d00), const Color(0xffff9100)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(headRect);

    // Draw base head rounded rect
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(radius * 0.6)), paint);

    // Draw Horns
    final hornPaint = Paint()..color = RpgColors.accent;
    final leftHorn = Path();
    leftHorn.moveTo(center.dx - radius * 0.6, center.dy - radius * 0.8);
    leftHorn.lineTo(center.dx - radius * 0.9, center.dy - radius * 1.4);
    leftHorn.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.8);
    leftHorn.close();
    canvas.drawPath(leftHorn, hornPaint);

    final rightHorn = Path();
    rightHorn.moveTo(center.dx + radius * 0.6, center.dy - radius * 0.8);
    rightHorn.lineTo(center.dx + radius * 0.9, center.dy - radius * 1.4);
    rightHorn.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.8);
    rightHorn.close();
    canvas.drawPath(rightHorn, hornPaint);

    // Draw Snout
    final snoutPaint = Paint()..color = const Color(0xffd84315);
    final snoutRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.25),
      width: radius * 1.1,
      height: radius * 0.7,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(snoutRect, Radius.circular(radius * 0.3)), snoutPaint);

    // Draw Nostrils
    final nostrilPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy + radius * 0.2), 3, nostrilPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.2, center.dy + radius * 0.2), 3, nostrilPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    final leftEye = Offset(center.dx - radius * 0.45, center.dy - radius * 0.25);
    final rightEye = Offset(center.dx + radius * 0.45, center.dy - radius * 0.25);
    
    // Draw eye backings (yellow reptilian eyes)
    final yellowPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(leftEye, radius * 0.18, yellowPaint);
    canvas.drawCircle(rightEye, radius * 0.18, yellowPaint);
    
    canvas.drawCircle(leftEye, radius * 0.08, eyePaint);
    canvas.drawCircle(rightEye, radius * 0.08, eyePaint);

    // Draw Wings for Young / Adult / Legendary
    if (stage != 'baby') {
      final wingPaint = Paint()..color = const Color(0xffd84315).withAlpha(220);
      
      final leftWing = Path();
      leftWing.moveTo(center.dx - radius * 0.8, center.dy);
      leftWing.quadraticBezierTo(
        center.dx - radius * 2.0, center.dy - radius * 1.2,
        center.dx - radius * 2.1, center.dy - radius * 0.5,
      );
      leftWing.lineTo(center.dx - radius * 1.5, center.dy + radius * 0.1);
      leftWing.close();
      canvas.drawPath(leftWing, wingPaint);

      final rightWing = Path();
      rightWing.moveTo(center.dx + radius * 0.8, center.dy);
      rightWing.quadraticBezierTo(
        center.dx + radius * 2.0, center.dy - radius * 1.2,
        center.dx + radius * 2.1, center.dy - radius * 0.5,
      );
      rightWing.lineTo(center.dx + radius * 1.5, center.dy + radius * 0.1);
      rightWing.close();
      canvas.drawPath(rightWing, wingPaint);
    }
  }

  void _drawGriffin(Canvas canvas, Size size, Paint paint) {
    // Falls back to a cute sky bird (Griffin representation)
    final center = Offset(size.width / 2, size.height * 0.55);
    double radius = size.width * 0.25;

    if (stage == 'baby') radius = size.width * 0.15;
    if (stage == 'young') radius = size.width * 0.22;
    if (stage == 'adult') radius = size.width * 0.28;
    if (stage == 'legendary') radius = size.width * 0.32;

    paint.color = Colors.lightBlue.shade300;
    canvas.drawCircle(center, radius, paint);

    // Beak
    final beakPaint = Paint()..color = RpgColors.accent;
    final beakPath = Path();
    beakPath.moveTo(center.dx - 5, center.dy + 2);
    beakPath.lineTo(center.dx + 15, center.dy + 8);
    beakPath.lineTo(center.dx - 5, center.dy + 15);
    beakPath.close();
    canvas.drawPath(beakPath, beakPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.35, center.dy - radius * 0.2), radius * 0.12, eyePaint);
  }

  @override
  bool shouldRepaint(covariant PetPainter oldDelegate) {
    return oldDelegate.stage != stage ||
        oldDelegate.visualType != visualType ||
        oldDelegate.bounceValue != bounceValue;
  }
}
