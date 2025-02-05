import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lookapp/providers/user_preferences_provider.dart';

class AddressPage extends ConsumerWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // TODO: Save addresses
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddressSection(
              context,
              'Billing Address',
              const BillingAddressForm(),
            ),
            const Divider(height: 32),
            _buildAddressSection(
              context,
              'Delivery Address',
              const DeliveryAddressForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(
      BuildContext context, String title, Widget addressForm) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          addressForm,
        ],
      ),
    );
  }
}

class BillingAddressForm extends ConsumerStatefulWidget {
  const BillingAddressForm({super.key});

  @override
  ConsumerState<BillingAddressForm> createState() => _BillingAddressFormState();
}

class _BillingAddressFormState extends ConsumerState<BillingAddressForm> {
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _townController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _additionalInfoController.dispose();
    _zipCodeController.dispose();
    _townController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _buildTextField(
                controller: _streetController,
                label: 'Street',
                hint: 'Enter street name',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: _houseNumberController,
                label: 'Number',
                hint: '#',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _additionalInfoController,
          label: 'Additional Info',
          hint: 'Apartment, suite, unit, etc.',
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: _buildTextField(
                controller: _zipCodeController,
                label: 'ZIP Code',
                hint: 'ZIP code',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: _buildTextField(
                controller: _townController,
                label: 'City',
                hint: 'City',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _countryController,
          label: 'Country',
          hint: 'Enter country',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class DeliveryAddressForm extends ConsumerStatefulWidget {
  const DeliveryAddressForm({super.key});

  @override
  ConsumerState<DeliveryAddressForm> createState() =>
      _DeliveryAddressFormState();
}

class _DeliveryAddressFormState extends ConsumerState<DeliveryAddressForm> {
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _townController = TextEditingController();
  final _countryController = TextEditingController();
  bool _sameAsBilling = false;

  @override
  void dispose() {
    _streetController.dispose();
    _houseNumberController.dispose();
    _additionalInfoController.dispose();
    _zipCodeController.dispose();
    _townController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          value: _sameAsBilling,
          onChanged: (value) {
            setState(() {
              _sameAsBilling = value ?? false;
            });
          },
          title: const Text('Same as billing address'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (!_sameAsBilling) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildTextField(
                  controller: _streetController,
                  label: 'Street',
                  hint: 'Enter street name',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _buildTextField(
                  controller: _houseNumberController,
                  label: 'Number',
                  hint: '#',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _additionalInfoController,
            label: 'Additional Info',
            hint: 'Apartment, suite, unit, etc.',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: _buildTextField(
                  controller: _zipCodeController,
                  label: 'ZIP Code',
                  hint: 'Enter ZIP code',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: _buildTextField(
                  controller: _townController,
                  label: 'Town',
                  hint: 'Enter town',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _countryController,
            label: 'Country',
            hint: 'Enter country',
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
