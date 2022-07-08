import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../widget/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 40,
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 40,
            ),
            SettingsTile(
              color: Colors.blue,
              icon: Ionicons.image_outline,
              title: 'Change number of Images',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
