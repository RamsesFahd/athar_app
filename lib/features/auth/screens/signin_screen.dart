import 'package:flutter/material.dart';
import 'signup_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const SignUpScreen(),
              ),
            );
          },
          child: const Text('Back to Sign Up'),
        ),
      ),
    );
  }
}