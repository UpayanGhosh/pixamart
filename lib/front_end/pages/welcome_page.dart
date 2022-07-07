import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                      color: Colors.white,
                      fontFamily: 'medio'),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Automatic identity verification which \n enables us to verify your identity",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Wallington-Pro'),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2.15,
              width: MediaQuery.of(context).size.height / 2,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: RiveAnimation.asset(
                'assets/rive/Welcome.riv',
                fit: BoxFit.fitHeight,
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.transparent),
                    padding:
                        EdgeInsets.symmetric(horizontal: 140, vertical: 20),
                    elevation: 0,
                    primary: Color(0xfff07371),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'medio'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.transparent),
                    padding:
                        EdgeInsets.symmetric(horizontal: 134, vertical: 20),
                    elevation: 0,
                    primary: Color(0xff8ab6fd),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/signUp');
                  },
                  child: Text(
                    "SignUp",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                        fontFamily: 'medio'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
