import 'package:flutter/material.dart';

class Styles {
  // Define the font family
  static const String fontFamily = 'Roboto';

  // Color Palette
  static const Color primaryColor = Color(0xFFB9C89F); // Light green
  static const Color secondaryColor = Color(0xFF94B699); // Darker green for contrast
  static const Color accentColor = Color(0xFFFFA726); // Orange for accents
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color subtitleColor = Colors.black54;
  static const Color errorColor = Color(0xFFD32F2F);

  // Text Styles
  static const TextStyle header1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: textColor,
  );

  static const TextStyle header2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: textColor,
  );

  static const TextStyle header3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: textColor,
  );

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

  static const TextStyle buttonText = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: Colors.white,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
    color: primaryColor,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: BorderSide(color: primaryColor),
    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );

  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  );

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration productCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  // App Bar Theme
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: textColor,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: textColor),
  );

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData bottomNavBarTheme = BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
    type: BottomNavigationBarType.fixed,
  );

  // Loader Style
  static Widget loader = CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
  );

  // Status Colors
  static const Map<String, Color> statusColors = {
    'available': Color(0xFF4CAF50),
    'out of stock': Color(0xFFFF9800),
    'recycled': Color(0xFFF44336),
    'pending': Color(0xFFFFC107),
    'processing': Color(0xFF2196F3),
    'shipped': Color(0xFF673AB7),
    'delivered': Color(0xFF4CAF50),
    'cancelled': Color(0xFFF44336),
  };

  // Helper Methods
  static Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? Colors.grey;
  }

  // Spacing Constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;

  // Theme Data
  static ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    fontFamily: fontFamily,
    appBarTheme: appBarTheme,
    bottomNavigationBarTheme: bottomNavBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: secondaryButtonStyle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
    ),
  );
}