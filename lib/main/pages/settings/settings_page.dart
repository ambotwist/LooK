import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/settings/account/account_page.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/main/pages/settings/style_preferences/style_preferences_page.dart';
import 'package:lookapp/widgets/layout/regular_Button.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsButtonContainer(
              title: 'General',
              children: [
                SettingsButton(
                  title: 'Language',
                  icon: Ionicons.language_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Style Preferences',
                  icon: Ionicons.shirt_outline,
                  iconSize: 22,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const StylePreferencesPage()),
                    );
                  },
                ),
                SettingsButton(
                  title: 'Notifications',
                  icon: Ionicons.notifications_outline,
                  iconSize: 24,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Account',
                  icon: Ionicons.person_outline,
                  iconSize: 22,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const AccountPage()),
                    );
                  },
                ),
              ],
            ),
            SettingsButtonContainer(
              title: 'Data',
              children: [
                SettingsButton(
                  title: 'Liked Items',
                  icon: Ionicons.heart_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Disliked Items',
                  icon: Ionicons.close_outline,
                  iconSize: 26,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Reset Recommendations',
                  icon: Ionicons.refresh_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
              ],
            ),
            SettingsButtonContainer(
              title: 'App Information',
              children: [
                SettingsButton(
                  title: 'Privacy Policy',
                  icon: Ionicons.shield_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Terms of Service',
                  icon: Ionicons.file_tray_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'About',
                  icon: Ionicons.information_circle_outline,
                  iconSize: 26,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Help Center & FAQs',
                  icon: Ionicons.help_circle_outline,
                  iconSize: 26,
                  onPressed: () {},
                ),
                SettingsButton(
                  title: 'Contact Us',
                  icon: Ionicons.mail_outline,
                  iconSize: 22,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
