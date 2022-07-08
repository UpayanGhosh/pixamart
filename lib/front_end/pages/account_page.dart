// Todo Add Random avatar when user signs up

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:PixaMart/front_end/widget/profile_list_item.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

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
                  Container(
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
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                            Text(
                              'U',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 25,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                          alignment: Alignment.center,
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
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 16),
                    child: Text(
                      'Upayan Ghosh',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 35,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 200),
                  Container(
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 16),
                    child: Text(
                      'upayan1231@gmail.com',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 80,
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  Container(
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
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ProfileListItem(
                  icon: LineAwesomeIcons.download,
                  text: 'Downloads',
                  page: '', // Todo add downloads page (Kingshuk/Upayan)
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.question_circle,
                  text: 'Help & Support',
                  page: '/helpSupport',
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.cog,
                  text: 'Settings',
                  page: '/settings',
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.user_plus,
                  text: 'Invite a Friend',
                  page: '', //Todo Add a system to invite new users
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: 'Logout',
                  page: ''
                  //hasNavigation: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
