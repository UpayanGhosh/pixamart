import 'dart:async';
import 'package:PixaMart/backend/model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late List<RxDouble> opacityManager;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
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
    ];

    manageOpacity();
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
                          fontSize: 15,
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
                          child: TextFormField(
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.white)),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nexa',
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 13.9,
                      child: Obx(
                        () => AnimatedOpacity(
                          duration: const Duration(milliseconds: 350),
                          opacity: opacityManager[3].value,
                          child: TextFormField(
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                            // todo implement obscure text (kingshuk)
                            cursorColor: Colors.white,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 2, color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.white)),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Nexa',
                                    fontWeight: FontWeight.bold)),
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
                      side: BorderSide(color: Colors.transparent),
                      elevation: 0,
                      primary: Color(0xff8ab6fd),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      if (_formKey.currentState!.validate()) {
                        dynamic result =
                            await _auth.registerWithEmailAndPassword(
                                email: email, password: password);
                        if (result == null) {
                          setState(() {
                            error = 'Please supply a valid email';
                          });
                        }
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nexa',
                        fontSize: MediaQuery.of(context).size.height / 49.05,
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
                      side: BorderSide(color: Colors.transparent),
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 4.8,
                          vertical: MediaQuery.of(context).size.height / 35.6),
                      elevation: 0,
                      primary: Color(0xff63c54f),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      //Navigator.pushReplacementNamed(context, '/navigationBar');
                    },
                    child: Text(
                      "Login With Google",
                      style: TextStyle(
                        fontFamily: 'Nexa',
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 49.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
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
