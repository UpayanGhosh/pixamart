import 'dart:async';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:PixaMart/front_end/widget/curved_navigation_bar.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lottie/lottie.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const LoginPage({required this.initialLink, Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late List<RxDouble> opacityManager;
  late final AuthService auth;
  late String _email;
  late RxString emailProperties;
  late String _password;
  late RxString passwordProperties;
  late RxString _error;
  late List<RxString> color;
  late RxBool obscureText;

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
    auth = AuthService();
    _email = '';
    emailProperties = 'Email'.obs;
    _password = '';
    passwordProperties = 'Email'.obs;
    _error = ''.obs;
    color = [
      'white'.obs,
      'white'.obs
    ]; // first one is for email, second one for password
    obscureText = true.obs;
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    if (_email == '') {
      emailProperties.value = 'Email';
      color[0].value = 'white';
    }
    if (_password == '') {
      passwordProperties.value = 'Password';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (_email == '') {
      emailProperties.value = 'Email';
      color[0].value = 'white';
    }
    if (_password == '') {
      passwordProperties.value = 'Password';
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: auth.auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return AppBottomNavigationBar(initialLink: widget.initialLink, firstPage: HomePage(initialLink: widget.initialLink,),);
          } else {
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
                clipBehavior: Clip.antiAlias,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
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
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .height /
                                              20.85,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Nexa'),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height / 41.7,
                                ),
                                Obx(
                                      () => AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
                                    opacity: opacityManager[1].value,
                                    child: Text(
                                      "Login to your account",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                              .size
                                              .height /
                                              55.6,
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
                                  horizontal:
                                  MediaQuery.of(context).size.width / 9.8),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        13.9,
                                    child: Obx(
                                          () => AnimatedOpacity(
                                        duration:
                                        const Duration(milliseconds: 250),
                                        opacity: opacityManager[2].value,
                                        child: Obx(
                                              () => TextFormField(
                                            enableInteractiveSelection: true,
                                            enableIMEPersonalizedLearning: true,
                                            enableSuggestions: true,
                                            keyboardType:
                                            TextInputType.emailAddress,
                                            onChanged: (val) async {
                                              setState(() => _email = val);
                                              if (_email.contains('@') &&
                                                  _email.contains('.')) {
                                                List<String> userSignInMethods =
                                                [];
                                                userSignInMethods = await auth
                                                    .checkIfUserExists(
                                                    email: _email);
                                                if (userSignInMethods.isEmpty &&
                                                    _email != '') {
                                                  emailProperties.value =
                                                  'Account does\'nt exist';
                                                  color[0].value = 'red';
                                                } else {
                                                  emailProperties.value =
                                                  'Account exists';
                                                  color[0].value = 'green';
                                                }
                                              }
                                              //setState(() {});
                                            },
                                            cursorColor: Colors.white,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: InputDecoration(
                                                enabledBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 3,
                                                      color: color[0].value ==
                                                          'red'
                                                          ? Colors.red
                                                          : color[0].value ==
                                                          'green'
                                                          ? Colors.green
                                                          : Colors.white),
                                                ),
                                                focusedBorder:
                                                OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 3,
                                                        color: color[0]
                                                            .value ==
                                                            'red'
                                                            ? Colors.red
                                                            : color[0].value ==
                                                            'green'
                                                            ? Colors
                                                            .green
                                                            : Colors
                                                            .white)),
                                                labelText:
                                                emailProperties.value,
                                                labelStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Nexa',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                        52.125)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        27.8,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        13.9,
                                    child: Obx(
                                          () => AnimatedOpacity(
                                        duration:
                                        const Duration(milliseconds: 250),
                                        opacity: opacityManager[3].value,
                                        child: TextFormField(
                                          obscureText: obscureText.value,
                                          enableSuggestions: false,
                                          enableIMEPersonalizedLearning: false,
                                          enableInteractiveSelection: true,
                                          keyboardType:
                                          TextInputType.visiblePassword,
                                          autocorrect: false,
                                          onChanged: (val) {
                                            setState(() => _password = val);
                                          },
                                          cursorColor: Colors.white,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          decoration: InputDecoration(
                                              suffixIcon: _password == ''
                                                  ? null
                                                  : IconButton(
                                                  onPressed: () {
                                                    obscureText.value = !obscureText.value;
                                                  },
                                                  icon: obscureText.value
                                                      ? const Icon(
                                                    Ionicons
                                                        .eye_outline,
                                                    color:
                                                    Colors.white,
                                                  )
                                                      : const Icon(
                                                    Ionicons
                                                        .eye_off_outline,
                                                    color:
                                                    Colors.white,
                                                  )),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 3,
                                                    color:
                                                    color[1].value == 'red'
                                                        ? Colors.red
                                                        : color[1].value ==
                                                        'green'
                                                        ? Colors.green
                                                        : Colors.white),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 3,
                                                      color: color[1].value ==
                                                          'red'
                                                          ? Colors.red
                                                          : color[1].value ==
                                                          'green'
                                                          ? Colors.green
                                                          : Colors.white)),
                                              labelText:
                                              passwordProperties.value,
                                              labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Nexa',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                  MediaQuery.of(context)
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
                                    side: const BorderSide(
                                        color: Colors.transparent),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width /
                                            2.8,
                                        vertical:
                                        MediaQuery.of(context).size.height /
                                            41.7),
                                    elevation: 0,
                                    primary: const Color(0xfff07371),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50)),
                                  ),
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    try {
                                      if(_email.isNotEmpty && _password.isNotEmpty) {
                                        _error.value =
                                        await auth.loginWithEmailAndPassword(
                                            email: _email,
                                            password: _password).then((value) async {
                                          await Hive.openBox('${auth.auth.currentUser?.uid}-favourites').then((value) async {
                                            Future.delayed(const Duration(milliseconds: 300));
                                          });
                                          if (value == 'wrong-password') {
                                            color[1].value = 'red';
                                            passwordProperties.value =
                                            'Wrong Password';
                                            HapticFeedback.vibrate();
                                          }
                                          return value;
                                        });
                                      }
                                    } catch (e) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Obx(
                                        () => AnimatedOpacity(
                                      duration:
                                      const Duration(milliseconds: 250),
                                      opacity: opacityManager[5].value,
                                      child: Text(
                                        "Log In",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .height /
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
                                    side: const BorderSide(
                                        color: Colors.transparent),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                        MediaQuery.of(context).size.width /
                                            4.35,
                                        vertical:
                                        MediaQuery.of(context).size.height /
                                            41.7),
                                    elevation: 0,
                                    primary: const Color(0xff63c54f),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50)),
                                  ),
                                  onPressed: () async {
                                    HapticFeedback.lightImpact();
                                    await auth.loginWithGoogle().then((value) async {
                                      await Hive.openBox('${auth.auth.currentUser?.uid}-favourites').then((value) async {
                                        await Future.delayed(const Duration(milliseconds: 300)).then((value) => Navigator.pop(context));
                                      });
                                    }); // use alert dialogue to engage the user while hive initializes
                                  },
                                  child: Text(
                                    "Login With Google",
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
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/signUp', arguments: {
                                      'initialLink': widget.initialLink,
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Obx(
                                        () => AnimatedOpacity(
                                      duration:
                                      const Duration(milliseconds: 250),
                                      opacity: opacityManager[7].value,
                                      child:
                                      const Text("Don't have an account?",
                                          style: TextStyle(
                                            fontFamily: 'Nexa',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                  Obx(
                                        () => AnimatedOpacity(
                                      duration:
                                      const Duration(milliseconds: 250),
                                      opacity: opacityManager[8].value,
                                      child: Text(
                                        "Sign up",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .height /
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
                            child:
                            Lottie.asset('assets/lottie/Loginpage.json'))),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}