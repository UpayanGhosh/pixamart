import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  final double padLeft;
  final double padRight;
  final double padTop;
  final double padBottom;
  const AppTitle(
      {Key? key,
      required this.padLeft,
      required this.padTop,
      required this.padRight,
      required this.padBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padLeft, padTop, padRight, padBottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Pixa',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 18.53,
              fontFamily: 'Raunchies',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Mart',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 18.53,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: 'Raunchies',
            ),
          ),
        ],
      ),
    );
  }
}
