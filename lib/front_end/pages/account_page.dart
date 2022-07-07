import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:PixaMart/front_end/widget/profile_list_item.dart';
import 'package:PixaMart/front_end/widget/constants.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,designSize: Size(414, 896),minTextAdapt: true);
    var profileInfo = Expanded(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            Container(
              height: kSpacingUnit.w * 10,
              width: kSpacingUnit.w * 10,
              margin: EdgeInsets.fromLTRB(0, kSpacingUnit.w * 3, kSpacingUnit.w * 3, 0),
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: kSpacingUnit.w * 5,
                    backgroundImage: AssetImage('assets/GTR.jpg'),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: kSpacingUnit.w * 2.5,
                      width: kSpacingUnit.w * 2.5,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        heightFactor: kSpacingUnit.w * 1.5,
                        widthFactor: kSpacingUnit.w * 1.5,
                        child: Icon(
                          LineAwesomeIcons.pen,
                          color: kDarkPrimaryColor,
                          size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: kSpacingUnit.w * 2),
            Container(
              margin: EdgeInsets.only(right: 25),
              child: Text(
                'Upayan Ghosh',
                style: kTitleTextStyle,
              ),
            ),
            SizedBox(height: kSpacingUnit.w * 0.5),
            Container(
              margin: EdgeInsets.only(right: 25),
              child: Text(
                'upayan1231@gmail.com',
                style: kCaptionTextStyle,
              ),
            ),
            SizedBox(height: kSpacingUnit.w * 2),
            Container(
              margin: EdgeInsets.only(right: 25),
              height: kSpacingUnit.w * 4,
              width: kSpacingUnit.w * 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
                color: Colors.blueAccent,
              ),
              child: Center(
                child: Text(
                  'Fucking Diabolical',
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        Icon(
          LineAwesomeIcons.arrow_left,
          size: ScreenUtil().setSp(kSpacingUnit.w * 3),
        ),
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );
          return Scaffold(
            body: Container(
              color: Colors.black,
              child: Column(
                children: <Widget>[
                  SizedBox(height: kSpacingUnit.w * 5),
                  header,
                  Expanded(
                    child: ListView(
                      children: const <Widget>[
                        ProfileListItem(
                          icon: LineAwesomeIcons.donate,
                          text: 'Help Creator',
                        ),
                        ProfileListItem(
                          icon: LineAwesomeIcons.question_circle,
                          text: 'Help & Support',
                        ),
                        ProfileListItem(
                          icon: LineAwesomeIcons.cog,
                          text: 'Settings',
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
            ),
          );
  }
}