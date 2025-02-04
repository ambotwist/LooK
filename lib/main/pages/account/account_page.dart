import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/main.dart';
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
          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Gender Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: Sex.values.map((gender) {
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
