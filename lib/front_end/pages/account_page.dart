import 'package:PixaMart/front_end/pages/Help&Support.dart';
import 'package:PixaMart/front_end/pages/settings_page.dart';
import 'package:flutter/material.dart';
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
                        fontFamily: 'Nexa',
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
                        fontFamily: 'Nexa',
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
                          fontFamily: 'Nexa',
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
              physics: BouncingScrollPhysics(),
              children: [
                ProfileListItem(
                  icon: LineAwesomeIcons.donate,
                  text: 'Help Creator',
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpSupport()));
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
                          Icon(
                            LineAwesomeIcons.question_circle,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Help & Support',
                            style: TextStyle(
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()));
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
                          Icon(
                            LineAwesomeIcons.cog,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text('Settings'),
                        ],
                      )),
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.user_plus,
                  text: 'Invite a Friend',
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.alternate_sign_out,
                  text: 'Logout',
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
