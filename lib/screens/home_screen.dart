import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/services/simple_auth_service.dart';
import 'package:card_keep/screens/login_screen.dart';
import 'package:card_keep/screens/cards_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const CardsListScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
