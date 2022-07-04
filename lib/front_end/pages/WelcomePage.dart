import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../animation/FadeAnimation.dart';
import 'LoginPage.dart';
import 'SignupPage.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:  Colors.black,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                FadeAnimation(1, Text("Welcome", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  color: Colors.white,
                ),)),
                SizedBox(height: 20,),
                FadeAnimation(1.2, Text("Automatic identity verification which enables you to verify your identity",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15
                  ),)),
              ],
            ),
            FadeAnimation(1.4, Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.height / 2,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
              child: RiveAnimation.asset('assets/rive/Welcome.riv',fit: BoxFit.fitHeight,),
            )),
            Column(
              children: <Widget>[
                FadeAnimation(1.5, MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Text("Login", style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    color: Colors.white,
                  ),),
                )),
                SizedBox(height: 20,),
                FadeAnimation(1.6, Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(50),
                      border: Border(
                        bottom: BorderSide(color: Colors.white,),
                        top: BorderSide(color: Colors.white,),
                        left: BorderSide(color: Colors.white,),
                        right: BorderSide(color: Colors.white,),
                      )
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
                    },
                    color: Colors.blueAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: Text("Sign up", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      color: Colors.white,
                    ),),
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}