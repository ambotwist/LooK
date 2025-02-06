import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main.dart';
import 'package:lookapp/main/pages/login/login_page.dart';
import 'package:lookapp/main/pages/settings/account/address_page.dart';
import 'package:lookapp/main/pages/settings/account/basic_info_page.dart';
import 'package:lookapp/main/pages/settings/account/email_page.dart';
import 'package:lookapp/main/pages/settings/account/phone_page.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/providers/address_provider.dart';
import 'package:lookapp/models/address.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leadingWidth: 120,
        leading: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Ionicons.chevron_back),
            ),
            Transform.translate(
              offset: const Offset(-12, 0),
              child: TextButton(
                onPressed: Navigator.of(context).pop,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                    title: 'Name',
                    icon: Ionicons.person_outline,
                    iconSize: 22,
                    subtitle: ref.watch(userPreferencesProvider).firstName !=
                            null
                        ? '${ref.watch(userPreferencesProvider).firstName} ${ref.watch(userPreferencesProvider).lastName}'
                        : null,
                    subtitleStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BasicInfoPage(),
                        ),
                      );
                    },
                  ),
                  SettingsButton(
                    title: 'Address',
                    icon: Ionicons.home_outline,
                    iconSize: 22,
                    subtitle: ref.watch(addressesProvider).when(
                          data: (addresses) {
                            final billingAddress = addresses.firstWhere(
                              (a) => a.type == 'billing',
                              orElse: () => Address(
                                userId: '',
                                type: 'billing',
                                street: '',
                                houseNumber: '',
                                zipCode: '',
                                city: '',
                                country: '',
                                countryCode: '',
                              ),
                            );
                            return billingAddress.city;
                          },
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                    subtitleStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddressPage(),
                        ),
                      );
                    },
                  ),
                  SettingsButton(
                    title: 'Phone Number',
                    icon: Ionicons.call_outline,
                    iconSize: 22,
                    subtitle: ref.watch(userPreferencesProvider).phoneNumber,
                    subtitleStyle: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PhonePage(),
                        ),
                      );
                    },
                  ),
                  SettingsButton(
                    title: 'Email',
                    icon: Ionicons.mail_outline,
                    iconSize: 22,
                    subtitle: supabase.auth.currentUser?.email,
                    subtitleStyle: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EmailPage(),
                        ),
                      );
                    },
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
                      final shouldSignOut = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          final platform = Theme.of(context).platform;
                          return platform == TargetPlatform.iOS
                              ? CupertinoAlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                      'Are you sure you want to sign out?'),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: const Text('Sign Out'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                )
                              : AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                      'Are you sure you want to sign out?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                    ),
                                    TextButton(
                                      child: const Text('Sign Out'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                    ),
                                  ],
                                );
                        },
                      );

                      if (shouldSignOut == true && context.mounted) {
                        await supabase.auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  SettingsButton(
                    title: 'Delete Account',
                    icon: Ionicons.trash_outline,
                    iconSize: 22,
                    onPressed: () {},
                    iconColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).colorScheme.error,
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
