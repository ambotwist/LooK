import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lookapp/main/wrappers/auth_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lookapp/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/providers/user_profile_provider.dart';
import 'package:lookapp/widgets/layout/connection_status_snackbar.dart';

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

  runApp(
    ProviderScope(
      overrides: [
        // Initialize and watch the userProfileProvider at app start
        userProfileProvider,
      ],
      child: const MainApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  // Tracks the current internet connection state
  bool isConnectedToInternet = false;
  // Tracks if we were previously disconnected, used to show "back online" message
  bool wasDisconnected = false;
  // Subscription to the internet connection status stream
  late StreamSubscription internetListener;
  // Global key to access the ScaffoldMessenger from anywhere in the app
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Helper method to reload app data when internet connection is restored
  void _reloadAppData() {
    // Trigger a reload of the user profile data through the Riverpod provider
    ref.read(userProfileProvider.notifier).loadUserProfile();
  }

  @override
  void initState() {
    super.initState();

    // Check the initial internet connection state when the app starts
    InternetConnection().hasInternetAccess.then((hasAccess) {
      // Update the connection state in the widget
      setState(() => isConnectedToInternet = hasAccess);
    });

    // Start listening to internet connection status changes
    internetListener = InternetConnection().onStatusChange.listen((status) {
      // Convert the status to a boolean for easier handling
      final isConnected = status == InternetStatus.connected;

      // Update the widget state with the new connection status
      setState(() {
        // Update the current connection state
        isConnectedToInternet = isConnected;

        if (isConnected) {
          // If we're connected and were previously disconnected
          if (wasDisconnected) {
            // Hide any existing snackbar (like the "no connection" message)
            _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            // Show the "back online" snackbar
            _scaffoldMessengerKey.currentState?.showSnackBar(
              createConnectionStatusSnackBar(
                message: 'Back online!',
                isConnected: true,
                duration: const Duration(seconds: 3),
              ),
            );
            // Reset the disconnected flag since we're back online
            wasDisconnected = false;
            // Reload any data that might have failed while offline
            _reloadAppData();
          }
        } else {
          // If we've lost connection
          // Set the flag so we know to show "back online" message later
          wasDisconnected = true;
          // Hide any existing snackbar
          _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          // Show the "no connection" snackbar
          _scaffoldMessengerKey.currentState?.showSnackBar(
            createConnectionStatusSnackBar(
              message: 'No internet connection',
              isConnected: false,
              duration: const Duration(days: 1),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // Clean up the connection listener when the widget is disposed
    internetListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the user profile provider active
    ref.watch(userProfileProvider);

    return MaterialApp(
      // Attach the scaffold messenger key to enable showing snackbars
      scaffoldMessengerKey: _scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'LooK',
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}
