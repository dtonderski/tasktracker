import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:tasktracker/extensions.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);
  String getRedirectUrl() {
    if (kIsWeb) {
      // Get the current URL and use it as the redirect URL
      final uri = Uri.base;
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
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
