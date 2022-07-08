import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Lottie.asset('assets/lottie/Help.json'),
      ),
    );
  }
}
