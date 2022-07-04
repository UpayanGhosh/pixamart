import 'package:PixaMart/front_end/pages/homepage.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../animation/FadeAnimation.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeAnimation(1, Text("Sign up", style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    color: Colors.white,
                      fontFamily: 'medio'
                  ),)),
                  SizedBox(height: 20,),
                  FadeAnimation(1.2, Text("Create an account, It's free", style: TextStyle(
                      fontSize: 15,
                    color: Colors.white,
                  ),)),
                ],
              ),
              Column(
                children: <Widget>[
                  FadeAnimation(1.2, makeInput(label: "Email")),
                  FadeAnimation(1.3, makeInput(label: "Password", obscureText: true)),
                  FadeAnimation(1.4, makeInput(label: "Confirm Password", obscureText: true)),
                ],
              ),
              FadeAnimation(1.5, Container(
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
                    MaterialPageRoute(builder: (context) => Navigation_bar());

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
              )),
              FadeAnimation(1.6, Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Already have an account?",style: TextStyle(color: Colors.white,),),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(" Login", style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18,
                      color: Colors.white,
                    ),),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({label, obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          color: Colors.white,
        ),),
        SizedBox(height: 5,),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white,)
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white,)
            ),
          ),
        ),
        SizedBox(height: 30,),
      ],
    );
  }
}