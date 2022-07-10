import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            
            margin: EdgeInsets.fromLTRB(
                30, MediaQuery.of(context).size.height / 15, 0, 0),
            child: Lottie.asset('assets/lottie/Working.json',
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.fill),
          ),
          SizedBox(height: MediaQuery.of(context).size.height / 15),
          Container(
            child: Column(
              children: [
                Text('    STILL WORKING ON IT',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nexa')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
