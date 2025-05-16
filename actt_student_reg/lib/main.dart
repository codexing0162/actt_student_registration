import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting
  await initializeDateFormatting();
  
  // Set preferred orientations (portrait mode only for better UX)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize app constants
  Constants.init();
  
  // Run the app
  runApp(
    // This wrapper helps to avoid bottom overflow errors in dialogs and forms
    MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
      child: App(),
    ),
  );
}