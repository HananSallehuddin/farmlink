import 'package:flutter/material.dart';

class Styles {
  // Define the font family (replace with your custom font if needed)
  static const String fontFamily = 'Roboto';

  // Color Palette
  // Green background color
  static const Color primaryColor = Color(0xFFB9C89F); // Lighter green
  static const Color secondaryColor = Color(0xFFB9C89F); // A lighter shade of the original color
  static const Color accentColor = Color(0xFFFFA726); // Example: Orange for accents
  static const Color backgroundColor = Colors.white; // Default background color
  static const Color textColor = Colors.black87; // Default text color
  static const Color subtitleColor = Colors.black54; // Subtle text color
  static const Color buttonColor = Color(0xFF94B699); // Button background

  // Header Styles
  static const TextStyle header1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: textColor,
  );

  static const TextStyle header2 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: textColor,
  );

  static const TextStyle header3 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: subtitleColor,
  );

  // Body Text Styles
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16.0,
    fontFamily: fontFamily,
    color: textColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14.0,
    fontFamily: fontFamily,
    color: subtitleColor,
  );

  // Caption Text Style
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontFamily: fontFamily,
    color: Colors.grey,
  );
}