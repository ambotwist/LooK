import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/account/account_button.dart';
import 'package:lookapp/main/pages/account/account_button_container.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/widgets/layout/regular_Button.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/providers/discover_provider.dart';
import 'package:lookapp/providers/item_provider.dart';
import 'package:lookapp/enums/item_enums.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AccountButtonContainer(
            title: 'General',
            children: [
              AccountButton(
                title: 'Style Preferences',
                icon: Ionicons.shirt_outline,
                iconSize: 22,
              ),
              AccountButton(
                title: 'Notifications',
                icon: Ionicons.notifications_outline,
                iconSize: 24,
              ),
              AccountButton(
                title: 'Account',
                icon: Ionicons.person_outline,
                iconSize: 22,
              ),
            ],
          ),
          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop For',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: Sex.values.map((gender) {
                  if (gender == Sex.unisex) {
                    return const SizedBox.shrink();
                  } else {
                    return FilterChip(
                      label: Text(gender.displayName),
                      selected: userPrefs.sex == gender,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(userPreferencesProvider.notifier)
                              .updateSex(gender);
                          // Reset discover state and refresh items
                          ref.read(discoverProvider.notifier).updateState(
                            currentIndex: 0,
                            currentImageIndex: 0,
                            previousIndices: [],
                          );
                          ref.invalidate(itemsProvider);
                        }
                      },
                    );
                  }
                }).toList(),
              ),
            ],
          ),

          const Spacer(),
          Center(
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
        ],
      ),
    );
  }
}
