import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';
import 'dart:math';
import 'package:flutter/services.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late List<RxDouble> opacityManager;
  late List<Color> colorManager;
  late final Color bearBackgroundColor;
  late RiveAnimationController idleAnimationController;
  late RiveAnimationController successAnimationController;

  void manageOpacity() async {
    int i = 0;
    await Future.delayed(const Duration(milliseconds: 800));
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (i < opacityManager.length) {
        opacityManager[i].value = 1.0;
        i++;
      }
    });
  }

  int manageColor() {
    return Random().nextInt(2);
  }

  @override
  void initState() {
    successAnimationController = OneShotAnimation('success', autoplay: false);
    idleAnimationController = OneShotAnimation('idle', autoplay: true);

    super.initState();
    opacityManager = [
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
      0.0.obs,
    ];
    colorManager = [
      const Color(0xfff07371),
      const Color(0xff8ab6fd),
    ];
    bearBackgroundColor = colorManager[manageColor()];
    manageColor();
    manageOpacity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 13.06, vertical: MediaQuery.of(context).size.height / 16.68),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: opacityManager[0].value,
                      child: Text(
                        "W E L C O M E",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 20.85,
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
                      duration: const Duration(milliseconds: 800),
                      opacity: opacityManager[1].value,
                      child: Text(
                        "Automatic identity verification which \n enables us to verify your identity", // todo find better greeting text(upayan)
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height / 55.6,
                            fontFamily: 'Nexa'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
              ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: opacityManager[2].value,
                  child: Container(
                    decoration: BoxDecoration(
                        color: bearBackgroundColor,
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    height: MediaQuery.of(context).size.height / 2.15,
                    width: MediaQuery.of(context).size.height / 2,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height / 16.68),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: RiveAnimation.asset(
                        'assets/rive/Welcome.riv',
                        controllers: [
                          idleAnimationController,
                          successAnimationController,
                        ],
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: opacityManager[3].value,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      padding:
                          EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2.8, vertical: MediaQuery.of(context).size.height / 41.7),
                      elevation: 0,
                      primary: const Color(0xfff07371),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      if(!successAnimationController.isActive) {
                        successAnimationController.isActive = true;
                      }
                      await Future.delayed(Duration(milliseconds: 2000));
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.height / 46.33,
                          color: Colors.white,
                          fontFamily: 'Nexa'),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 41.7,
              ),
              Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: opacityManager[4].value,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.transparent),
                      padding:
                          EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2.92, vertical: MediaQuery.of(context).size.height / 41.7),
                      elevation: 0,
                      primary: const Color(0xff8ab6fd),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      if(!successAnimationController.isActive) {
                        successAnimationController.isActive = true;
                      }
                      await Future.delayed(Duration(milliseconds: 2000));
                      Navigator.pushNamed(context, '/signUp');
                    },
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.height / 46.33,
                          color: Colors.white,
                          fontFamily: 'Nexa'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
