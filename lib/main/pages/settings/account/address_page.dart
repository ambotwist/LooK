import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/models/address.dart';
import 'package:lookapp/providers/address_provider.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';
import 'package:lookapp/widgets/buttons/look_button.dart';

const Map<String, String> countries = {
  'United Kingdom': 'GB',
  'Netherlands': 'NL',
  'Belgium': 'BE',
  'France': 'FR',
  'Germany': 'DE',
  'Switzerland': 'CH',
  'Spain': 'ES',
};

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final _billingFormKey = GlobalKey<_AddressFormState>();
  final _deliveryFormKey = GlobalKey<_AddressFormState>();
  bool _sameAsBilling = false;

  @override
  void initState() {
    super.initState();
    _sameAsBilling =
        ref.read(userPreferencesProvider).useBillingAddressForDelivery;
  }

  void _handleSameAsBillingChanged(bool? value) {
    setState(() {
      _sameAsBilling = value ?? false;
    });
    ref
        .read(userPreferencesProvider.notifier)
        .updateUseBillingAddressForDelivery(value ?? false);
  }

  Future<void> _saveAddresses() async {
    if (_billingFormKey.currentState?.validate() != true) {
      return;
    }

    if (!_sameAsBilling && _deliveryFormKey.currentState?.validate() != true) {
      return;
    }

    // Save billing address
    final billingSuccess =
        await _billingFormKey.currentState?.saveAddress('billing');
    if (billingSuccess != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save billing address')),
      );
      return;
    }

    // Save delivery address if different from billing
    if (!_sameAsBilling) {
      final deliverySuccess =
          await _deliveryFormKey.currentState?.saveAddress('delivery');
      if (deliverySuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save delivery address')),
        );
        return;
      }
    } else {
      // Copy billing address to delivery
      final billingState = _billingFormKey.currentState;
      if (billingState != null) {
        final success =
            await ref.read(addressNotifierProvider.notifier).upsertAddress(
                  'delivery',
                  street: billingState._streetController.text,
                  houseNumber: billingState._houseNumberController.text,
                  additionalInfo: billingState._additionalInfoController.text,
                  zipCode: billingState._zipCodeController.text,
                  city: billingState._cityController.text,
                  country: billingState._countryController.text,
                  countryCode: billingState._countryCode,
                );
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save delivery address')),
          );
          return;
        }
      }
    }

    // Refresh the addresses list
    ref.invalidate(addressesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        leading: const Text(''),
        title: const Text(
          'Address',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveAddresses();
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
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
          final deliveryAddress = addresses.firstWhere(
            (a) => a.type == 'delivery',
            orElse: () => Address(
              userId: '',
              type: 'delivery',
              street: '',
              houseNumber: '',
              zipCode: '',
              city: '',
              country: '',
              countryCode: '',
            ),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Billing Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                AddressForm(
                  key: _billingFormKey,
                  address: billingAddress,
                  type: 'billing',
                ),
                const SizedBox(height: 24),
                CheckboxListTile(
                  title: const Text('Use billing address for delivery'),
                  value: _sameAsBilling,
                  onChanged: _handleSameAsBillingChanged,
                ),
                if (!_sameAsBilling) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  AddressForm(
                    key: _deliveryFormKey,
                    address: deliveryAddress,
                    type: 'delivery',
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class AddressForm extends ConsumerStatefulWidget {
  final Address? address;
  final String type;

  const AddressForm({
    super.key,
    this.address,
    required this.type,
  });

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  String _countryCode = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _streetController.text = widget.address!.street;
      _houseNumberController.text = widget.address!.houseNumber;
      _additionalInfoController.text = widget.address!.additionalInfo ?? '';
      _zipCodeController.text = widget.address!.zipCode;
      _cityController.text = widget.address!.city;
      _countryController.text = widget.address!.country;
      _countryCode = widget.address!.countryCode;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _additionalInfoController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<bool> saveAddress(String type) async {
    if (!validate()) return false;

    return await ref.read(addressNotifierProvider.notifier).upsertAddress(
          type,
          street: _streetController.text,
          houseNumber: _houseNumberController.text,
          additionalInfo: _additionalInfoController.text.isEmpty
              ? null
              : _additionalInfoController.text,
          zipCode: _zipCodeController.text,
          city: _cityController.text,
          country: _countryController.text,
          countryCode: _countryCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 14,
    );
    final inputStyle = TextStyle(
      color: theme.colorScheme.onPrimary,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Street and House Number row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _streetController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'Street',
                    labelStyle: labelStyle,
                    floatingLabelStyle: labelStyle,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a street name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _houseNumberController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'No.',
                    labelStyle: labelStyle,
                    floatingLabelStyle: labelStyle,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Additional Info
          TextFormField(
            controller: _additionalInfoController,
            style: inputStyle,
            decoration: InputDecoration(
              labelText: 'Additional Info (Optional)',
              labelStyle: labelStyle,
              floatingLabelStyle: labelStyle,
            ),
          ),
          const SizedBox(height: 16),
          // ZIP Code and City row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _zipCodeController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'ZIP Code',
                    labelStyle: labelStyle,
                    floatingLabelStyle: labelStyle,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  style: inputStyle,
                  decoration: InputDecoration(
                    labelText: 'City',
                    labelStyle: labelStyle,
                    floatingLabelStyle: labelStyle,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a city';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // TODO: Replace with country selector
          DropdownButtonFormField<String>(
            value: _countryController.text.isEmpty
                ? null
                : _countryController.text,
            style: inputStyle,
            decoration: InputDecoration(
              labelText: 'Country',
              labelStyle: labelStyle,
              floatingLabelStyle: labelStyle,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a country';
              }
              return null;
            },
            items: countries.keys.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _countryController.text = newValue;
                  _countryCode = countries[newValue]!;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
