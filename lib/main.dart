import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'navigation/app_routes.dart';
import 'pages/create_note_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const NoteLookApp());
}

class NoteLookApp extends StatelessWidget {
  const NoteLookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'notelook',
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.create: (context) => const CreateNotePage(),
      },
    );
  }
}
