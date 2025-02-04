import 'package:flutter/material.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/main/wrappers/home_wrapper.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final session = supabase.auth.currentSession;
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (supabase.auth.currentSession != null) {
      return const HomeWrapper();
    }

    return const LoginPage();
  }
}
