import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/services/simple_auth_service.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/services/api_service.dart';
import 'package:card_keep/services/offline_cache_service.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize offline cache
  await OfflineCacheService().initialize();

  runApp(const CardKeepApp());
}

class CardKeepApp extends StatelessWidget {
  const CardKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimpleAuthService()),
        ChangeNotifierProvider<CardService>(
          create: (context) {
            final authService = context.read<SimpleAuthService>();
            return CardService(
              ApiService(authService),
              authService, // Pass the same auth service instance
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'CardKeep',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          return const CardDashboard();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<SimpleAuthService>();
      bool success = false;

      if (_isSignUp) {
        success = await authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        success = await authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // Show error message if authentication failed
      if (!success && mounted) {
        String errorMessage = authService.errorMessage ??
            (_isSignUp ? 'Registration failed' : 'Sign in failed');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      } else if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isSignUp ? 'Account created successfully!' : 'Welcome back!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and branding
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.credit_card,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CardKeep',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep all your loyalty cards in one place',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                  });
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Don\'t have an account? Sign Up',
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Secure & Reliable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your data is encrypted and stored securely',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardDashboard extends StatefulWidget {
  const CardDashboard({super.key});

  @override
  State<CardDashboard> createState() => _CardDashboardState();
}

class _CardDashboardState extends State<CardDashboard> {
  bool _hasLoadedCards = false;

  @override
  void initState() {
    super.initState();
    // Load cards automatically when the dashboard is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedCards) {
        final cardService = context.read<CardService>();
        _loadCards(context, cardService, silent: true);
        _hasLoadedCards = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('My Loyalty Cards'),
            const SizedBox(width: 16),
            // User info display
            Consumer<SimpleAuthService>(
              builder: (context, authService, child) {
                final user = authService.currentUser;
                final userEmail = user?['email'] ?? 'User';
                final userName = _extractUserName(userEmail);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userName,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<SimpleAuthService>().signOut();
            },
          ),
        ],
      ),
      body: Consumer<CardService>(
        builder: (context, cardService, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Welcome Status Card
                Consumer<SimpleAuthService>(
                  builder: (context, authService, child) {
                    final user = authService.currentUser;
                    final userEmail = user?['email'] ?? 'User';
                    final userName = _extractUserName(userEmail);

                    return Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, $userName!',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Logged in as $userEmail',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Actions Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _loadCards(context, cardService),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Cards'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddCardDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Card'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cards List
                Expanded(
                  child: cardService.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : cardService.cards.isEmpty
                          ? _buildEmptyState(context)
                          : _buildCardsList(cardService.cards),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No loyalty cards yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first card to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(List<dynamic> cards) {
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.credit_card, color: Colors.blue),
            title: Text(card.cardName ?? 'Unnamed Card'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Barcode: ${card.barcodeData ?? 'No data'}'),
                Text(
                    'Type: ${card.barcodeType != null ? BarcodeTypeHelper.enumToString(card.barcodeType!) : 'Unknown'}'),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCard(context, card),
            ),
          ),
        );
      },
    );
  }

  void _loadCards(BuildContext context, CardService cardService,
      {bool silent = false}) async {
    try {
      await cardService.loadCards(context: context);
      if (context.mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cards loaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cards: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCardDialog(BuildContext context) {
    final cardNameController = TextEditingController();
    final barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cardNameController,
              decoration: const InputDecoration(
                labelText: 'Card Name',
                hintText: 'e.g., Starbucks, Walmart',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode Data',
                hintText: 'Enter barcode number',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (cardNameController.text.isNotEmpty &&
                  barcodeController.text.isNotEmpty) {
                Navigator.of(context).pop();
                await _addCard(
                    context, cardNameController.text, barcodeController.text);
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  Future<void> _addCard(
      BuildContext context, String cardName, String barcodeData) async {
    try {
      final cardService = context.read<CardService>();

      // Import the model at the top of the file and create a proper LoyaltyCard object
      final newCard = LoyaltyCard(
        cardName: cardName,
        barcodeData: barcodeData,
        barcodeType: BarcodeType.code128, // Default type
        createdAt: DateTime.now(),
      );

      await cardService.addCard(newCard, context: context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCard(BuildContext context, dynamic card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete "${card.cardName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && card.id != null) {
      try {
        final cardService = context.read<CardService>();
        await cardService.deleteCard(card.id, context: context);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete card: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _extractUserName(String email) {
    // Extract name from email (part before @)
    String name = email.split('@')[0];
    // Capitalize first letter and replace dots/underscores with spaces
    name = name.replaceAll(RegExp(r'[._]'), ' ');
    return name
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
