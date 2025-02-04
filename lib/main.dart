import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookapp/themes/app_theme.dart';
import 'package:lookapp/main/wrappers/auth_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with original configuration
  await Supabase.initialize(
    url: 'https://vwkurdhiepsexgevmakb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3a3VyZGhpZXBzZXhnZXZtYWtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMTA3NzYsImV4cCI6MjA1MjY4Njc3Nn0.5_sUC64pbN8UeD2rZXSS1mh4Z_yDNGrLfCzcAu1p04o',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
    debug: true,
  );

  runApp(const ProviderScope(child: MainApp()));
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LooK',
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}
