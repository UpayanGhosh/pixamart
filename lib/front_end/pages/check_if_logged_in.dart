import 'package:PixaMart/front_end/pages/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'image_view_page.dart';

class CheckIfShared extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const CheckIfShared({required this.initialLink, Key? key}) : super(key: key);

  @override
  State<CheckIfShared> createState() => _CheckIfSharedState();
}

class _CheckIfSharedState extends State<CheckIfShared> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          Future<Box<dynamic>> favouritesBox = Hive.openBox('${FirebaseAuth.instance.currentUser?.uid}-downloads');
          return FutureBuilder(
            future: favouritesBox,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return ImageView(imgShowUrl: 'shared', imgDownloadUrl: 'shared', imgTinyUrl: 'shared', initialLink: widget.initialLink,);
              } else {
                return Container();
              }
            }
          );
        } else {
          return WelcomePage(initialLink: widget.initialLink);
        }
      },
    );
  }
}
