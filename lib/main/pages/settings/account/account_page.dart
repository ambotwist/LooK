import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';
import 'package:lookapp/widgets/layout/regular_Button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        title: const Text(
          'Account',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SettingsButtonContainer(
                title: 'Personal Information',
                children: [
                  SettingsButton(
                    title: 'Address',
                    icon: Ionicons.home_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                  SettingsButton(
                    title: 'Phone Number',
                    icon: Ionicons.call_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                ],
              ),
              SettingsButtonContainer(
                title: 'Orders',
                children: [
                  SettingsButton(
                    title: 'Purchase History',
                    icon: Ionicons.receipt_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                  SettingsButton(
                    title: 'Track Order',
                    icon: Ionicons.map_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                ],
              ),
              SettingsButtonContainer(
                title: 'Account Settings',
                children: [
                  SettingsButton(
                    title: 'Sign out',
                    icon: Ionicons.log_out_outline,
                    iconSize: 22,
                    onPressed: () async {
                      await supabase.auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      }
                    },
                  ),
                  SettingsButton(
                    title: 'Delete Account',
                    icon: Ionicons.trash_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
