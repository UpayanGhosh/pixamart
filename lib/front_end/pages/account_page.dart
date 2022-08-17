// Todo Add Random avatar when user signs up

import 'dart:async';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:PixaMart/front_end/pages/download_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:PixaMart/front_end/widget/profile_list_item.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthService _auth = AuthService();
  late List<RxDouble> opacityManager;

  @override
  void initState() {
    super.initState();
    opacityManager = [
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
    ];
    manageOpacity();
  }

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 210));
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: MediaQuery.of(context).size.width / 12),
              Column(
                children: [
                  Obx(
                        () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: opacityManager[0].value,
                      child: Container(
                        height: MediaQuery.of(context).size.height / 9,
                        width: MediaQuery.of(context).size.width / 4,
                        margin: EdgeInsets.fromLTRB(
                            0,
                            MediaQuery.of(context).size.height / 14,
                            MediaQuery.of(context).size.width / 14,
                            0),
                        child: Stack(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                  ),
                                ),
                                Text(
                                  '${_auth.auth.currentUser?.email!.substring(0, 1).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize:
                                    MediaQuery.of(context).size.height / 25,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                height: MediaQuery.of(context).size.height / 25,
                                width: MediaQuery.of(context).size.width / 15,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LineAwesomeIcons.pen,
                                  color: const Color(0xFF212121),
                                  size: MediaQuery.of(context).size.height / 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Obx(
                        () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: opacityManager[1].value,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 16),
                        child: Text(
                          '${_auth.auth.currentUser?.displayName ?? _auth.auth.currentUser?.email}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 40,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 200),
                  Obx(
                        () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: opacityManager[1].value,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 16),
                        child: Text(
                          '${_auth.auth.currentUser?.email}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 80,
                            fontWeight: FontWeight.w100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Obx(
                        () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: opacityManager[2].value,
                      child: Container(
                        margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 16),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Get Pro for Free',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 50,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Obx(
                      () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: opacityManager[4].value,
                    child: Padding(
                      padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 24.5),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DownloadPage()));
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.all(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LineAwesomeIcons.download),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 24.5,
                              ),
                              const Text(
                                'Downloads',
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                Obx(
                      () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: opacityManager[4].value,
                    child: const ProfileListItem(
                      icon: LineAwesomeIcons.question_circle,
                      text: 'Help & Support',
                      page: '/helpSupport',
                    ),
                  ),
                ),
                /*const ProfileListItem(
                  icon: LineAwesomeIcons.cog,
                  text: 'Settings',
                  page: '/settings',
                ),
                const ProfileListItem(
                  icon: LineAwesomeIcons.user_plus,
                  text: 'Invite a Friend',
                  page: '',
                ),*/
                Obx(
                      () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: opacityManager[4].value,
                    child: Padding(
                      padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width / 24.5),
                      child: ElevatedButton(
                          onPressed: () {
                            _auth.logout();
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.all(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LineAwesomeIcons.alternate_sign_out),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 24.5,
                              ),
                              const Text(
                                'Logout',
                                style: TextStyle(
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}