import 'dart:ui' as ui;
import 'package:win_daily/theme/wddl_design_system.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WinCardGenerator {
  static Future<void> generateAndShareWinCard(
    BuildContext context,
    Map<String, dynamic> winData,
  ) async {
    try {
      // Create a custom painter for the win card
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(80.w, 100.h);

      // Paint the win card
      await _paintWinCard(canvas, size, winData, context);

      // Convert to image
      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Share the image
      await Share.shareXFiles([
        XFile.fromData(
          pngBytes,
          name: 'win_card_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ], text: 'Check out my daily win! 🎉');

      // Show success feedback
      HapticFeedback.mediumImpact();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Win card created and ready to share!'),
            backgroundColor: WDDLDesignSystem.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error gracefully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to create win card. Please try again.'),
            backgroundColor: WDDLDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  static Future<void> _paintWinCard(
    Canvas canvas,
    Size size,
    Map<String, dynamic> winData,
    BuildContext context,
  ) async {
    final theme = Theme.of(context);
    final paint = Paint();

    // Background
    paint.color = theme.cardColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    // Add subtle border
    paint
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      paint,
    );

    // Reset paint for text
    paint.style = PaintingStyle.fill;

    // App branding at top
    final brandingPainter = TextPainter(
      text: TextSpan(
        text: 'Win Daily',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    brandingPainter.layout();
    brandingPainter.paint(canvas, Offset(24, 24));

    // Date
    final datePainter = TextPainter(
      text: TextSpan(
        text: winData['date'] ?? '',
        style: TextStyle(
          color: theme.colorScheme.secondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    datePainter.layout();
    datePainter.paint(canvas, Offset(24, 80));

    // Title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: winData['title'] ?? '',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    titlePainter.layout(maxWidth: size.width - 48);
    titlePainter.paint(canvas, Offset(24, 120));

    // Reflection (if available)
    final reflection = winData['reflection'] ?? '';
    if (reflection.isNotEmpty) {
      final reflectionPainter = TextPainter(
        text: TextSpan(
          text: reflection,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 5,
      );
      reflectionPainter.layout(maxWidth: size.width - 48);
      reflectionPainter.paint(canvas, Offset(24, 200));
    }

    // Mood indicator
    final mood = winData['mood'] ?? 3;
    final moodColor = _getMoodColor(mood);

    paint.color = moodColor;
    canvas.drawCircle(Offset(24, size.height - 80), 12, paint);

    final moodTextPainter = TextPainter(
      text: TextSpan(
        text: 'Mood: $mood/5',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    moodTextPainter.layout();
    moodTextPainter.paint(canvas, Offset(48, size.height - 88));

    // Bottom branding
    final bottomBrandingPainter = TextPainter(
      text: TextSpan(
        text: 'Created with Win Daily',
        style: TextStyle(
          color: theme.colorScheme.secondary.withValues(alpha: 0.7),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    bottomBrandingPainter.layout();
    bottomBrandingPainter.paint(
      canvas,
      Offset(
        size.width - bottomBrandingPainter.width - 24,
        size.height - 32,
      ),
    );
  }

  static Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return const Color(0xFFE53E3E); // Red
      case 2:
        return const Color(0xFFD69E2E); // Orange
      case 3:
        return const Color(0xFF4A5568); // Gray
      case 4:
        return const Color(0xFF2B6CB0); // Blue
      case 5:
        return const Color(0xFF38A169); // Green
      default:
        return const Color(0xFF4A5568);
    }
  }
}
