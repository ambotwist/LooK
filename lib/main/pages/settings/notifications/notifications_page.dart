import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isEditing = false;
  final Map<String, bool> _notifications = {
    'personalized_finds': false,
    'new_arrivals': false,
    'orders_status': false,
    'wishlist_price_drop': false,
    'wishlist_low_stock': false,
    'wishlist_back_in_stock': false,
    'fav_sales': false,
  };

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateNotification(String key, bool value) {
    setState(() {
      _notifications[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          TextButton(
            onPressed: _toggleEdit,
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
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
                    isChecked: _notifications['fav_sales'],
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
                    icon: Ionicons.pricetags_outline,
                    iconSize: 22,
                    onPressed: () {},
                    isCheckable: true,
                    isEditing: _isEditing,
                    isChecked: _notifications['wishlist_price_drop'],
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
                    isChecked: _notifications['wishlist_low_stock'],
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
                    isChecked: _notifications['wishlist_back_in_stock'],
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
                    icon: Ionicons.cube_outline,
                    iconSize: 22,
                    onPressed: () {},
                    isCheckable: true,
                    isEditing: _isEditing,
                    isChecked: _notifications['personalized_finds'],
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
                    isChecked: _notifications['new_arrivals'],
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
                    isChecked: _notifications['orders_status'],
                    onCheckChanged: (value) =>
                        _updateNotification('orders_status', value),
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
