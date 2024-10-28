import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasktracker/env.dart';
import 'package:tasktracker/login.dart';
import 'package:tasktracker/main_app/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // usePathUrlStrategy();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();

    // Check initial authentication status
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() {
        isAuthenticated = true;
      });
    }

    // Listen for authentication changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      setState(() {
        isAuthenticated = event == AuthChangeEvent.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isAuthenticated
          ? const MainAppScreen()
          : LoginScreen(
              onLoginSuccess: () {
                setState(() {
                  isAuthenticated = true;
                });
              },
            ),
    );
  }
}
