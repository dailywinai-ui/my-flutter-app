// File: lib/widgets/responsive_app_logo.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Static responsive SVG logo: sizes from screen width with safe clamps.
/// Why: Flutter layout controls size; SVG is vector and will scale cleanly.
class ResponsiveAppLogo extends StatelessWidget {
  const ResponsiveAppLogo({
    super.key,
    this.assetPath = 'assets/images/the_node_logo.svg',
    this.widthFactor = 0.90, // bigger
    this.minWidth = 260,     // never tiny on small phones
    this.maxWidth = 820,     // allows iPad / big layouts to look legit
  });


  final String assetPath;
  final double widthFactor;
  final double minWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Your auth screen has horizontal padding 24+24=48, so use available width.
    final available = (screenWidth - 48).clamp(0.0, screenWidth);
    final width = (available * widthFactor).clamp(minWidth, maxWidth);

    return Center(
      child: SvgPicture.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
