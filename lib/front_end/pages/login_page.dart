import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    print(MediaQuery.of(context).size.width);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black87,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: MediaQuery.of(context).size.height / 41.7, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Login",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 20.85,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Nexa'),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 41.7,
                        ),
                        Text(
                          "Login to your account",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 55.6,
                              color: Colors.white,
                              fontFamily: 'Nexa',
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 9.8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 13.9,
                            child: TextFormField(
                              cursorColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 3, color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.white)),
                                  labelText: 'Email',
                                  labelStyle: TextStyle(color: Colors.white, fontFamily: 'Nexa', fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height / 52.125)),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 27.8,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 13.9,
                            child: TextFormField( // todo add code to obscure text
                              cursorColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 3, color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.white)),
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.white, fontFamily: 'Nexa', fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height / 52.125)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.transparent),
                        padding:
                            EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2.8, vertical: MediaQuery.of(context).size.height / 41.7),
                        elevation: 0,
                        primary: Color(0xfff07371),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/navigationBar');
                      },
                      child: Text(
                        "Log In",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 46.33,
                            color: Colors.white,
                            fontFamily: 'Nexa'),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: Colors.transparent),
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 4.35, vertical: MediaQuery.of(context).size.height / 41.7),
                        elevation: 0,
                        primary: Color(0xff63c54f),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/navigationBar');
                      },
                      child: Text(
                        "Login With Google",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 46.33,
                            color: Colors.white,
                            fontFamily: 'Nexa'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signUp');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Don't have an account?",
                              style: TextStyle(
                                fontFamily: 'Nexa',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          Container(
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.height / 46.33,
                                  color: Colors.white,
                                  fontFamily: 'Nexa'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Lottie.asset('assets/lottie/LoginPage.json'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
