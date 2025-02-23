import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';
import 'package:lookapp/providers/notification_preferences_provider.dart';
import 'package:lookapp/widgets/buttons/save_button.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _isEditing = false;
  bool _hasChanges = false;

  void _updateNotification(String key, bool value) {
    setState(() {
      _hasChanges = true;
    });
    ref
        .read(notificationPreferencesProvider.notifier)
        .saveNotificationPreferences({
      ...ref.read(notificationPreferencesProvider).value ?? {},
      key: value,
    });
  }

  Future<void> _toggleEdit() async {
    if (_isEditing && _hasChanges) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (_isEditing) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    setState(() {
      _isEditing = !_isEditing;
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationPreferencesProvider);

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
          'Notifications',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          SaveButton(
            onPressed: _toggleEdit,
            text: _isEditing ? 'Save' : 'Edit',
          ),
        ],
      ),
      body: notificationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (notifications) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SettingsButtonContainer(
                  title: 'Sales & Promotions',
                  children: [
                    SettingsButton(
                      title: 'Favorite Brands Sales',
                      icon: Ionicons.megaphone_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['fav_sales'],
                      onCheckChanged: (value) =>
                          _updateNotification('fav_sales', value),
                    ),
                  ],
                ),
                SettingsButtonContainer(
                  title: 'Wishlist Updates',
                  children: [
                    SettingsButton(
                      title: 'Item Price Drop',
                      icon: Ionicons.flash_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['wishlist_price_drop'],
                      onCheckChanged: (value) =>
                          _updateNotification('wishlist_price_drop', value),
                    ),
                    SettingsButton(
                      title: 'Low Stock Alert',
                      icon: Ionicons.alert_circle_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['wishlist_low_stock'],
                      onCheckChanged: (value) =>
                          _updateNotification('wishlist_low_stock', value),
                    ),
                    SettingsButton(
                      title: 'Back in Stock',
                      icon: Ionicons.bag_handle_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['wishlist_back_in_stock'],
                      onCheckChanged: (value) =>
                          _updateNotification('wishlist_back_in_stock', value),
                    ),
                  ],
                ),
                SettingsButtonContainer(
                  title: 'A.I. Recommendations',
                  children: [
                    SettingsButton(
                      title: 'Personalized Finds',
                      icon: Ionicons.sparkles_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['personalized_finds'],
                      onCheckChanged: (value) =>
                          _updateNotification('personalized_finds', value),
                    ),
                    SettingsButton(
                      title: 'New Arrivals',
                      icon: Ionicons.cube_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['new_arrivals'],
                      onCheckChanged: (value) =>
                          _updateNotification('new_arrivals', value),
                    ),
                  ],
                ),
                SettingsButtonContainer(
                  title: 'Order Updates',
                  children: [
                    SettingsButton(
                      title: 'Order Status',
                      icon: Ionicons.bag_handle_outline,
                      iconSize: 22,
                      onPressed: () {},
                      isCheckable: true,
                      isEditing: _isEditing,
                      isChecked: notifications['orders_status'],
                      onCheckChanged: (value) =>
                          _updateNotification('orders_status', value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
