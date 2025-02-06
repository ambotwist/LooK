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
    'sales': false,
    'newArrivals': false,
    'orders': false,
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
                title: 'Push Notifications',
                children: [
                  SettingsButton(
                    title: 'Sales & Promotions',
                    icon: Ionicons.megaphone_outline,
                    iconSize: 22,
                    onPressed: () {},
                    isCheckable: true,
                    isEditing: _isEditing,
                    isChecked: _notifications['sales'],
                    onCheckChanged: (value) =>
                        _updateNotification('sales', value),
                  ),
                  SettingsButton(
                    title: 'New Arrivals',
                    icon: Ionicons.cube_outline,
                    iconSize: 22,
                    onPressed: () {},
                    isCheckable: true,
                    isEditing: _isEditing,
                    isChecked: _notifications['newArrivals'],
                    onCheckChanged: (value) =>
                        _updateNotification('newArrivals', value),
                  ),
                  SettingsButton(
                    title: 'Order Updates',
                    icon: Ionicons.bag_handle_outline,
                    iconSize: 22,
                    onPressed: () {},
                    isCheckable: true,
                    isEditing: _isEditing,
                    isChecked: _notifications['orders'],
                    onCheckChanged: (value) =>
                        _updateNotification('orders', value),
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
