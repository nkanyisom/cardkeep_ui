import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:card_keep/screens/home_screen.dart';
import 'package:card_keep/services/simple_auth_service.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/services/api_service.dart';
import 'package:card_keep/services/firebase_messaging_service.dart';
import 'package:card_keep/services/offline_cache_service.dart';
import 'package:card_keep/services/sync_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize offline cache (skip on web for now)
  if (!kIsWeb) {
    await OfflineCacheService().initialize();
  }

  // Initialize Firebase Messaging (skip on web for now)
  if (!kIsWeb) {
    await FirebaseMessagingService().initializeMessaging();
  }

  runApp(const LoyaltyCardApp());
}

class LoyaltyCardApp extends StatelessWidget {
  const LoyaltyCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimpleAuthService()),
        ChangeNotifierProvider<SyncService>(
          create: (context) => SyncService(context.read<SimpleAuthService>()),
        ),
        ChangeNotifierProvider<CardService>(
          create: (context) => CardService(
            ApiService(context.read<SimpleAuthService>()),
            context.read<SimpleAuthService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Loyalty Card App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
