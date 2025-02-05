import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main/pages/settings/account/account_page.dart';
import 'package:lookapp/main/pages/settings/notifications/notifications_page.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';
import 'package:lookapp/main/pages/settings/style_preferences/style_preferences_page.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.read(userPreferencesProvider).language;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Français', 'Español'].map((language) {
            return ListTile(
              title: Text(language),
              trailing: language == currentLanguage
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              onTap: () {
                ref
                    .read(userPreferencesProvider.notifier)
                    .updateLanguage(language);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(userPreferencesProvider).language;

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
                  subtitle: selectedLanguage,
                  onPressed: () => _showLanguageDialog(context, ref),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const NotificationsPage()),
                    );
                  },
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
              title: 'Support',
              children: [
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
                SettingsButton(
                  title: 'Report a Problem',
                  icon: Ionicons.alert_circle_outline,
                  iconSize: 24,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
