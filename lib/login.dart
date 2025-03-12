import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:tasktracker/extensions.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});
  String getRedirectUrl() {
    if (kIsWeb) {
      // Check if running on GitHub Pages
      final uri = Uri.base;
      if (uri.host == 'dtonderski.github.io') {
        return 'https://dtonderski.github.io/tasktracker/';
      } else {
        // For local development (e.g., localhost:8000)
        return '${uri.scheme}://${uri.host}:${uri.port}';
      }
    }
    // For mobile and other platforms, use the app's custom URI scheme
    return 'com.example.tasktracker://login-callback';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // Ensures the Column takes up the full height of the screen
        mainAxisSize: MainAxisSize.max,
        // Centers its children vertically
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Optionally, you can use Align to control horizontal alignment
          // By default, Column's crossAxisAlignment is center
          SupaSocialsAuth(
            socialProviders: const [
              OAuthProvider.google,
            ],
            colored: true,
            redirectUrl: kIsWeb
                ? getRedirectUrl()
                : 'com.example.tasktracker://login-callback',
            onSuccess: (Session response) {
              onLoginSuccess();
            },
            onError: (error) {
              context.showSnackBar('Login failed: $error', isError: true);
            },
          ),
        ],
      ),
    );
  }
}
