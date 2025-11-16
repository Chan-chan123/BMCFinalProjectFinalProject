import 'package:ecommerce_app/providers/cart_provider.dart'; // 1. Need this
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart'; // 2. Need this
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart'; // New import galing module 19

// 2. --- ADD OUR NEW APP COLOR PALETTE --- module 19
const Color kRichBlack = Color(0xFF1D1F24); // A dark, rich black
const Color kBrown = Color(0xFF8B5E3C); // Our main "coffee" brown
const Color kLightBrown = Color(0xFFD2B48C); // A lighter tan/beige
const Color kOffWhite = Color(0xFFF8F4F0); // A warm, off-white background
const Color kPeachPuff = Color(0xFFFFDAB9); // Soft peach background
const Color kOlive = Color(0xFF556B2F);
const Color kCream = Color(0xFFFFF2E6);
const Color kTaupe = Color(0xFFD2B48C);

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final cartProvider = CartProvider(); // module 12.5
  cartProvider.initializeAuthListener(); // module 12.5

  runApp(
    // We use ChangeNotifierProvider.value/module 12.5
    ChangeNotifierProvider.value(
      value: cartProvider, // We provide the instance we already created
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCommerce App',

      // 1. --- THIS IS THE NEW, COMPLETE THEME --- module 19
      theme: ThemeData(
        // 2. Set the main color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPeachPuff, // Our new primary color
          brightness: Brightness.light,
          primary: kBrown,
          onPrimary: kRichBlack,
          secondary: kLightBrown,
          background: kPeachPuff, // Our new app background
        ),
        useMaterial3: true,

        // 3. Set the background color for all screens
        scaffoldBackgroundColor: kPeachPuff, // Soft peach background
        // 4. --- (FIX) APPLY THE GOOGLE FONT ---
        // This applies "Lato" to all text in the app
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),

        // 5. --- (FIX) GLOBAL BUTTON STYLE ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kTaupe, // Use our new brown dito stop ko
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
        ),

        // 6. --- (FIX) GLOBAL TEXT FIELD STYLE ---
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          labelStyle: TextStyle(color: kBrown.withOpacity(0.8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrown, width: 2.0),
          ),
        ),

        // 7. --- (FIX) GLOBAL CARD STYLE ---
        cardTheme: CardThemeData(
          elevation: 1, // A softer shadow
          color: kTaupe, // Pure white cards on the off-white bg
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // 8. This ensures the images inside the card are rounded
          clipBehavior: Clip.antiAlias,
        ),

        // 9. --- (NEW) GLOBAL APPBAR STYLE ---
        appBarTheme: const AppBarTheme(
          backgroundColor: kTaupe, // Clean white AppBar
          foregroundColor: kRichBlack, // Black icons and text
          elevation: 0, // No shadow, modern look
          centerTitle: true,
        ),
      ),

      // --- END OF NEW THEME ---
      home: const AuthWrapper(),
    );
  }
}
