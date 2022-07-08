import 'package:PixaMart/front_end/pages/settings_page.dart';
import 'package:flutter/material.dart';

class ProfileListItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const ProfileListItem({Key? key, required this.text, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
          onPressed: () {
            MaterialPageRoute(builder: (context) => SettingsPage());
            //Todo Add pages
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              padding: EdgeInsets.all(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(this.icon),
              SizedBox(
                width: 16,
              ),
              Text(this.text),
            ],
          )),
    );
  }
}
