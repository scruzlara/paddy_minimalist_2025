import 'package:flutter/material.dart';

// Import the prediction screen from previous implementation
// Assuming it's in a file called 'prediction_screen.dart'
import 'prediction_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      theme: ThemeData(
        // Use Material 3 design
        useMaterial3: true,

        // Define the color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),

        // Customize the app bar theme
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        // Customize the elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Customize the card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Enable dark mode theme
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),

      // Use system theme mode
      themeMode: ThemeMode.system,

      // Disable debug banner
      debugShowCheckedModeBanner: false,

      // Set home screen
      home: PredictionScreen(),
    );
  }
}
