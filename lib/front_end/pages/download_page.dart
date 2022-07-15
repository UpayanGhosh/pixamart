import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            'Downloads',
            style: TextStyle(
              fontFamily: 'Nexa',
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.height / 8, 0, 0, 0),
          // padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.height/10, 0, 0, 0),
          child: Lottie.asset(
            'assets/lottie/Downloads.json',
            fit: BoxFit.fill,
            repeat: true,
          ),
        ),
      ),
    );
  }
}
