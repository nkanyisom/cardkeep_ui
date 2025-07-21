import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔧 Starting CardKeep debug version...');

    // Initialize Firebase with detailed logging
    print('🔧 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    runApp(const DebugCardKeepApp());
  } catch (e, stackTrace) {
    print('❌ Initialization error: $e');
    print('❌ Stack trace: $stackTrace');

    // Run a minimal error app
    runApp(
        DebugErrorApp(error: e.toString(), stackTrace: stackTrace.toString()));
  }
}

class DebugCardKeepApp extends StatelessWidget {
  const DebugCardKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardKeep Debug',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DebugScreen(),
    );
  }
}

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<String> debugInfo = [];

  @override
  void initState() {
    super.initState();
    _gatherDebugInfo();
  }

  void _gatherDebugInfo() {
    debugInfo = [
      '✅ Flutter app started successfully',
      '✅ Material app loaded',
      '✅ Debug screen rendered',
      '📱 Platform: Android',
      '🔥 Firebase status: ${Firebase.apps.isNotEmpty ? 'Connected' : 'Not connected'}',
      '📦 App package: za.co.jbrew.sto_karata_ui',
      '⚡ Build mode: Debug',
      '📅 Build time: ${DateTime.now()}',
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CardKeep Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Version',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                        'This is a diagnostic version of CardKeep to help identify startup issues.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'System Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: debugInfo.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.info, color: Colors.blue),
                      title: Text(debugInfo[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _testFirebase,
                child: const Text('Test Firebase Connection'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    debugInfo.add('🔄 Manual refresh at ${DateTime.now()}');
                  });
                },
                child: const Text('Refresh Debug Info'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testFirebase() {
    try {
      if (Firebase.apps.isNotEmpty) {
        setState(() {
          debugInfo.add(
              '✅ Firebase test passed - ${Firebase.apps.length} app(s) initialized');
          debugInfo.add(
              '📋 App names: ${Firebase.apps.map((app) => app.name).join(', ')}');
        });
      } else {
        setState(() {
          debugInfo.add('❌ Firebase test failed - No apps initialized');
        });
      }
    } catch (e) {
      setState(() {
        debugInfo.add('❌ Firebase test error: $e');
      });
    }
  }
}

class DebugErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;

  const DebugErrorApp(
      {super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardKeep Debug Error',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CardKeep Debug - Error'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Card(
                  color: Colors.red,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white, size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Startup Error Detected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error Details:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      error,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      stackTrace,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      main(); // Retry initialization
                    },
                    child: const Text('Retry Initialization'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
