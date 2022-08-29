import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupport extends StatelessWidget {
  const HelpSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('FACING A ISSUE?',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nexa'), textAlign: TextAlign.center,),
              SizedBox(height: MediaQuery.of(context).size.height / 20.86,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.transparent),
                  padding: EdgeInsets.symmetric(
                      horizontal:
                      MediaQuery.of(context).size.width / 4.35,
                      vertical:
                      MediaQuery.of(context).size.height / 41.7),
                  elevation: 0,
                  primary: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () async {
                  launchUrl(Uri.parse('mailto:upayan.ghosh.work@gmail.com,kingshuk.saha.uni@gmail.com?&subject=Contacting regarding PixaMart&body=I\'m reaching out to tell you about '));
                },
                child: Text(
                  "Contact Us",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                      MediaQuery.of(context).size.height / 46.33,
                      color: Colors.white,
                      fontFamily: 'Nexa'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
