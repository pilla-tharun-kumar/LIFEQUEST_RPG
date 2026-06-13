import 'package:flutter/material.dart';
import '../core/theme.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarBase;
  final String? outfitId;
  final String? accessoryId;
  final double size;

  const AvatarWidget({
    super.key,
    required this.avatarBase,
    this.outfitId,
    this.accessoryId,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: RpgColors.cardBg,
        shape: BoxShape.circle,
        border: Border.all(color: RpgColors.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: RpgColors.primary.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: AvatarPainter(
            avatarBase: avatarBase,
            outfitId: outfitId,
            accessoryId: accessoryId,
          ),
        ),
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  final String avatarBase;
  final String? outfitId;
  final String? accessoryId;

  AvatarPainter({
    required this.avatarBase,
    this.outfitId,
    this.accessoryId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw Background Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          RpgColors.cardBg.withBlue(60),
          RpgColors.background,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    final basePaint = Paint()..isAntiAlias = true;

    // 1. Draw Body/Torso
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.25, size.height);
    bodyPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.65,
      size.width * 0.5, size.height * 0.65,
    );
    bodyPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.65,
      size.width * 0.75, size.height);
    bodyPath.close();

    // Body Base Color based on avatar archetype
    if (avatarBase == 'knight') {
      basePaint.color = Colors.blueGrey.shade700;
    } else if (avatarBase == 'mage') {
      basePaint.color = Colors.indigo.shade800;
    } else { // cyberpunk
      basePaint.color = Colors.purple.shade900;
    }
    canvas.drawPath(bodyPath, basePaint);

    // 2. Draw Outfits
    if (outfitId == 'outfit_hoodie') {
      // Grey Hoodie
      final outfitPaint = Paint()..color = Colors.grey.shade700;
      canvas.drawPath(bodyPath, outfitPaint);
      
      // Draw zipper/drawstrings
      final stringPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.65), Offset(size.width * 0.5, size.height), stringPaint);
    } else if (outfitId == 'outfit_armor') {
      // Plate Armor
      final outfitPaint = Paint()..color = Colors.blueGrey.shade200;
      canvas.drawPath(bodyPath, outfitPaint);

      // Gold Trim
      final trimPaint = Paint()
        ..color = RpgColors.accent
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawPath(bodyPath, trimPaint);
    } else if (outfitId == 'outfit_robe') {
      // Purple Robe
      final outfitPaint = Paint()..color = Colors.purple.shade700;
      canvas.drawPath(bodyPath, outfitPaint);

      // Gold Collar
      final collarPaint = Paint()..color = RpgColors.accent;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.68), 12, collarPaint);
    }

    // 3. Draw Head/Face Base
    final headCenter = Offset(size.width * 0.5, size.height * 0.45);
    final headRadius = size.width * 0.22;
    
    final skinPaint = Paint()..color = const Color(0xfffcdbb0); // Standard peach skin
    canvas.drawCircle(headCenter, headRadius, skinPaint);

    // 4. Draw Eyes
    final eyePaint = Paint()..color = Colors.black;
    final leftEye = Offset(size.width * 0.42, size.height * 0.42);
    final rightEye = Offset(size.width * 0.58, size.height * 0.42);
    
    if (avatarBase == 'cyberpunk') {
      // Glowing green/cyan eyes
      eyePaint.color = RpgColors.primary;
      canvas.drawCircle(leftEye, 5, eyePaint);
      canvas.drawCircle(rightEye, 5, eyePaint);
    } else {
      canvas.drawCircle(leftEye, 4, eyePaint);
      canvas.drawCircle(rightEye, 4, eyePaint);
    }

    // 5. Draw Hair / Hats / Visors
    if (avatarBase == 'knight') {
      // Silver helmet top
      final helmPaint = Paint()..color = Colors.blueGrey.shade500;
      final helmPath = Path();
      helmPath.moveTo(size.width * 0.25, size.height * 0.4);
      helmPath.quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width * 0.75, size.height * 0.4);
      helmPath.close();
      canvas.drawPath(helmPath, helmPaint);

      // Red helmet plume
      final plumePaint = Paint()..color = RpgColors.secondary;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), 10, plumePaint);
    } else if (avatarBase == 'mage') {
      // Pointy wizard hat
      final hatPaint = Paint()..color = Colors.indigo.shade900;
      final hatPath = Path();
      hatPath.moveTo(size.width * 0.2, size.height * 0.38);
      hatPath.lineTo(size.width * 0.5, size.height * 0.08);
      hatPath.lineTo(size.width * 0.8, size.height * 0.38);
      hatPath.close();
      canvas.drawPath(hatPath, hatPaint);

      // Hat rim
      final rimPaint = Paint()
        ..color = RpgColors.accent
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(size.width * 0.18, size.height * 0.38), Offset(size.width * 0.82, size.height * 0.38), rimPaint);
    } else { // cyberpunk
      // Glowing neon magenta hair
      final hairPaint = Paint()..color = RpgColors.secondary;
      final hairPath = Path();
      hairPath.moveTo(size.width * 0.25, size.height * 0.4);
      hairPath.quadraticBezierTo(size.width * 0.35, size.height * 0.2, size.width * 0.5, size.height * 0.22);
      hairPath.quadraticBezierTo(size.width * 0.65, size.height * 0.2, size.width * 0.75, size.height * 0.4);
      hairPath.lineTo(size.width * 0.7, size.height * 0.3);
      hairPath.lineTo(size.width * 0.5, size.height * 0.35);
      hairPath.lineTo(size.width * 0.3, size.height * 0.3);
      hairPath.close();
      canvas.drawPath(hairPath, hairPaint);
    }

    // 6. Draw Accessories
    if (accessoryId == 'acc_glasses') {
      // Neon Cybergoggles
      final glassPaint = Paint()..color = RpgColors.secondary.withAlpha(200);
      final framePaint = Paint()
        ..color = RpgColors.primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final visorRect = Rect.fromLTRB(
        size.width * 0.35,
        size.height * 0.37,
        size.width * 0.65,
        size.height * 0.47,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(4)), glassPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(4)), framePaint);
    } else if (accessoryId == 'acc_sword') {
      // Giant sword drawing over shoulder
      final metalPaint = Paint()..color = Colors.grey.shade400;
      final hiltPaint = Paint()..color = RpgColors.accent;
      
      final swordPath = Path();
      swordPath.moveTo(size.width * 0.75, size.height * 0.5);
      swordPath.lineTo(size.width * 0.9, size.height * 0.1);
      swordPath.lineTo(size.width * 0.95, size.height * 0.15);
      swordPath.lineTo(size.width * 0.8, size.height * 0.55);
      swordPath.close();
      canvas.drawPath(swordPath, metalPaint);

      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.52), 6, hiltPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AvatarPainter oldDelegate) {
    return oldDelegate.avatarBase != avatarBase ||
        oldDelegate.outfitId != outfitId ||
        oldDelegate.accessoryId != accessoryId;
  }
}
