import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lookapp/main/pages/settings/settings_button.dart';
import 'package:lookapp/main/pages/settings/settings_button_container.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 18),
        ),
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
                  ),
                  SettingsButton(
                    title: 'New Arrivals',
                    icon: Ionicons.cube_outline,
                    iconSize: 22,
                    onPressed: () {},
                  ),
                  SettingsButton(
                    title: 'Order Updates',
                    icon: Ionicons.bag_handle_outline,
                    iconSize: 22,
                    onPressed: () {},
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
