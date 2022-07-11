import 'dart:async';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late List<RxDouble> opacityManager;
  final AuthService _auth = AuthService();
  String email = '';
  String password = '';
  String error = '';

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 250));
    Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    opacityManager = [
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
    ];

    manageOpacity();
  }

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back_ios,
              size: MediaQuery.of(context).size.height / 41.7,
              color: Colors.white),
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
                        Obx(
                          () => AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: opacityManager[0].value,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height /
                                      20.85,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Nexa'),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 41.7,
                        ),
                        Obx(
                          () => AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: opacityManager[1].value,
                            child: Text(
                              "Login to your account",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height / 55.6,
                                  color: Colors.white,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 9.8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 13.9,
                            child: Obx(
                              () => AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: opacityManager[2].value,
                                child: TextFormField(
                                  onChanged: (val) {
                                    setState(() => email = val);
                                  },
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3, color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.white)),
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Nexa',
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              52.125)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 27.8,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 13.9,
                            child: Obx(
                              () => AnimatedOpacity(
                                duration: const Duration(milliseconds: 250),
                                opacity: opacityManager[3].value,
                                child: TextFormField(
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() => password = val);
                                  },
                                  // todo add code to obscure text
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 3, color: Colors.white),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.white)),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Nexa',
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              52.125)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: opacityManager[4].value,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.transparent),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 2.8,
                                vertical:
                                    MediaQuery.of(context).size.height / 41.7),
                            elevation: 0,
                            primary: Color(0xfff07371),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            dynamic result =
                                await _auth.loginWithEmailAndPassword(
                                    email: email, password: password);
                            print('hi $result');
                            // Navigator.pushReplacementNamed(
                            //       context, '/navigationBar');
                          },
                          child: Obx(
                            () => AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: opacityManager[5].value,
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            46.33,
                                    color: Colors.white,
                                    fontFamily: 'Nexa'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: opacityManager[6].value,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.transparent),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 4.35,
                                vertical:
                                    MediaQuery.of(context).size.height / 41.7),
                            elevation: 0,
                            primary: Color(0xff63c54f),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Navigator.pushNamed(context, '/navigationBar');
                            print(email);
                            print(password);
                          },
                          child: Text(
                            "Login With Google",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 46.33,
                                color: Colors.white,
                                fontFamily: 'Nexa'),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/signUp');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Obx(
                            () => AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: opacityManager[7].value,
                              child: Text("Don't have an account?",
                                  style: TextStyle(
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )),
                            ),
                          ),
                          Obx(
                            () => AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: opacityManager[8].value,
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            46.33,
                                    color: Colors.white,
                                    fontFamily: 'Nexa'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Obx(() => AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: opacityManager[9].value,
                    child: Lottie.asset('assets/lottie/LoginPage.json'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
