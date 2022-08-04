import 'dart:async';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';

class SignupPage extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const SignupPage({required this.initialLink, Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late List<RxDouble> opacityManager;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
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
    ];

    manageOpacity();
    _email = '';
    emailProperties = 'Email'.obs;
    _password = '';
    passwordProperties = 'Email'.obs;
    _error = ''.obs;
    color = [
      'white'.obs,
      'white'.obs
    ]; // first one is for email, second one for password
    obscureText = false.obs;
  }

  @override
  void didUpdateWidget(covariant SignupPage oldWidget) {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black87,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black87,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: MediaQuery.of(context).size.height / 41.7,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 9.8),
          height: MediaQuery.of(context).size.height / 1.06,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: opacityManager[0].value,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height / 20.85,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Nexa'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 40.85,
                  ),
                  Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: opacityManager[1].value,
                      child: Text(
                        "Create an account, It's free",
                        style: TextStyle(
                          fontFamily: 'Nexa',
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 55.628,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 13.9,
                      child: Obx(
                        () => AnimatedOpacity(
                          duration: const Duration(milliseconds: 350),
                          opacity: opacityManager[2].value,
                          child: Obx(
                            () => TextFormField(
                              enableInteractiveSelection: true,
                              enableIMEPersonalizedLearning: true,
                              enableSuggestions: true,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) async {
                                setState(() {
                                  _email = val;
                                });
                                setState(() => _email = val);
                                if (_email.contains('@') &&
                                    _email.contains('.')) {
                                  List<String> userSignInMethods = [];
                                  userSignInMethods = await _auth
                                      .checkIfUserExists(email: _email);
                                  if (userSignInMethods.isEmpty &&
                                      _email != '') {
                                    emailProperties.value = 'New Account';
                                    color[0].value = 'green';
                                  } else {
                                    emailProperties.value =
                                        'Account already exists';
                                    color[0].value = 'red';
                                  }
                                }
                              },
                              cursorColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: color[0].value == 'red'
                                            ? Colors.red
                                            : color[0].value == 'green'
                                                ? Colors.green
                                                : Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3,
                                          color: color[0].value == 'red'
                                              ? Colors.red
                                              : color[0].value == 'green'
                                                  ? Colors.green
                                                  : Colors.white)),
                                  labelText: emailProperties.value,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 27.814,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 13.9,
                      child: Obx(
                        () => AnimatedOpacity(
                          duration: const Duration(milliseconds: 350),
                          opacity: opacityManager[3].value,
                          child: Obx(
                            () => TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              onChanged: (val) {
                                setState(() {
                                  _password = val;
                                });
                                if (_password.length <= 6) {
                                  passwordProperties.value = 'Weak Password';
                                  color[1].value = 'red';
                                } else if (_password.length > 6 &&
                                    _password.length <= 8) {
                                  passwordProperties.value = 'Medium Password';
                                  color[1].value = 'yellow';
                                } else {
                                  passwordProperties.value = 'Strong Password';
                                  color[1].value = 'green';
                                }
                              },
                              cursorColor: Colors.white,
                              obscureText: obscureText.value,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  suffixIcon: _password == ''
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            obscureText.value =
                                                !obscureText.value;
                                          },
                                          icon: obscureText.value
                                              ? const Icon(
                                                  Ionicons.eye_outline,
                                                  color: Colors.white,
                                                )
                                              : const Icon(
                                                  Ionicons.eye_off_outline,
                                                  color: Colors.white,
                                                )),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2,
                                        color: color[1].value == 'red'
                                            ? Colors.red
                                            : color[1].value == 'green'
                                                ? Colors.green
                                                : color[1].value == 'yellow'
                                                    ? Colors.yellowAccent
                                                    : Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3,
                                          color: color[1].value == 'red'
                                              ? Colors.red
                                              : color[1].value == 'green'
                                              ? Colors.green
                                              : color[1].value == 'yellow'
                                              ? Colors.yellowAccent
                                              : Colors.white)),
                                  labelText: passwordProperties.value,
                                  labelStyle: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nexa',
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: opacityManager[4].value,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3.07,
                          vertical: MediaQuery.of(context).size.height / 41.7),
                      side: const BorderSide(color: Colors.transparent),
                      elevation: 0,
                      primary: const Color(0xff8ab6fd),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      try {
                        if (_email.isNotEmpty && _password.isNotEmpty) {
                          _error.value =
                          await _auth.registerWithEmailAndPassword(
                              email: _email, password: _password).then((value) async {
                            await Hive.openBox('${_auth.auth.currentUser?.uid}favourites').then((value) async {
                              await Future.delayed(const Duration(milliseconds: 300));
                            });
                            return value;
                          });
                        }
                      } catch (e) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nexa',
                        fontSize: MediaQuery.of(context).size.height / 50.879,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: opacityManager[5].value,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 4.8,
                          vertical: MediaQuery.of(context).size.height / 35.6),
                      elevation: 0,
                      primary: const Color(0xff63c54f),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await _auth.loginWithGoogle().then((value) async {
                        await Hive.openBox('${_auth.auth.currentUser?.uid}favourites').then((value) async {
                          await Future.delayed(const Duration(milliseconds: 300)).then((value) => Navigator.pop(context));
                        });
                        });
                    },
                    child: Text(
                      "Login With Google",
                      style: TextStyle(
                        fontFamily: 'Nexa',
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 50.571,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login', arguments: {
                    'initialLink': widget.initialLink,
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: opacityManager[6].value,
                        child: Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nexa',
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height / 59.57,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: opacityManager[7].value,
                        child: Text(
                          " Login",
                          style: TextStyle(
                            fontFamily: 'Nexa',
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height / 46.33,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
