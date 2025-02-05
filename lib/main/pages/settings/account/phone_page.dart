import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';

class PhonePage extends ConsumerStatefulWidget {
  const PhonePage({super.key});

  @override
  ConsumerState<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends ConsumerState<PhonePage> {
  final _phoneController = TextEditingController();
  String? _completePhoneNumber;
  String _initialCountryCode = 'US'; // Default to US

  @override
  void initState() {
    super.initState();
    final userPrefs = ref.read(userPreferencesProvider);
    _completePhoneNumber = userPrefs.phoneNumber;

    // Set initial country code from saved preferences
    if (userPrefs.isoCode != null) {
      _initialCountryCode = userPrefs.isoCode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leading: const Text(''),
        title: const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_completePhoneNumber != null) {
                ref
                    .read(userPreferencesProvider.notifier)
                    .updatePhoneNumber(_completePhoneNumber);
              }
              Navigator.of(context).pop();
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              IntlPhoneField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (phone) {
                  _completePhoneNumber = phone.completeNumber;
                  // Save the dial code and ISO code separately
                  ref.read(userPreferencesProvider.notifier)
                    ..updateDialCode(phone.countryCode)
                    ..updateIsoCode(phone.countryISOCode);
                },
                initialCountryCode: _initialCountryCode,
                initialValue: ref.read(userPreferencesProvider).phoneNumber,
              ),
              const SizedBox(height: 12),
              Text(
                'Your phone number will be used for order updates and delivery notifications.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
