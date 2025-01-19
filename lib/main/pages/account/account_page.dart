import 'package:flutter/material.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/widgets/layout/regular_Button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RegularButton(
          text: 'Sign Out',
          onPressed: () async {
            await supabase.auth.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
        ),
      ),
    );
  }
}
