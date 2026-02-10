import 'package:flutter/material.dart';
import 'package:athar_app/features/auth/screens/signup_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
          child: const Text('Logout → Sign Up'),
        ),
      ),
    );
  }
}