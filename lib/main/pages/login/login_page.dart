import 'package:flutter/material.dart';
import 'package:lookapp/widgets/layout/sign_in_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/wrappers/home_wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeWrapper(),
          ),
        );
      }
    });
  }

  Future<AuthResponse> _googleSignIn() async {
    /// Web Client ID that you registered with Google Cloud.
    const webClientId =
        '1021030016467-q3vjqj0ef4jg70gpe1o5gn6mqrp3rl54.apps.googleusercontent.com';

    /// iOS Client ID that you registered with Google Cloud.
    const iosClientId =
        '1021030016467-7qi2scjkecgs7qjl82omco5qvkuuoslg.apps.googleusercontent.com';

    // Google sign in on Android will work without providing the Android
    // Client ID registered on Google Cloud.

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LooK',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 84,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              SignInButton(
                text: 'Sign in with Google',
                iconPath: 'assets/logos/google_light.png',
                color: Colors.white,
                onPressed: () async {
                  try {
                    await _googleSignIn();
                  } catch (e) {
                    if (mounted) {
                      // Sign in cancelled by user
                      return;
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              SignInButton(
                text: 'Sign in with Apple',
                iconPath: 'assets/logos/apple_light.png',
                color: Colors.black,
                iconSize: 20,
                textColor: Colors.white,
                onPressed: () async {},
              ),
              const SizedBox(height: 32),
              SignInButton(
                text: 'Sign in with Facebook',
                iconPath: 'assets/logos/facebook.png',
                color: const Color.fromRGBO(44, 100, 246, 1),
                iconSize: 26,
                textColor: Colors.white,
                onPressed: () async {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
