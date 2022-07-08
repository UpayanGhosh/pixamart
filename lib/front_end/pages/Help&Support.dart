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
            padding: EdgeInsets.all(0),
            child: Lottie.asset('assets/lottie/Help.json',
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.height / 2.5,
                fit: BoxFit.fill),
          ),
          Container(
            child: Column(
              children: [
                Text('Contact Developers for Support',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nexa')),
                SizedBox(
                  height: 20,
                  width: 20,
                ),
                Center(
                  child: Text(
                    'kingshuk.saha.all@gmail.com\n\nupayan.ghosh.work@gmail.com',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nexa'),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 80,
                  width: 0,
                ),
                Container(
                    child: Lottie.asset('assets/lottie/ThankYou.json',
                        fit: BoxFit.contain)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
