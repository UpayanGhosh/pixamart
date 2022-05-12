 import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Pixa', style: TextStyle(
            fontSize: 50,
            fontFamily: 'Raunchies',
            fontWeight: FontWeight.bold,
          ),),
          Text('Mart', style: TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: 'Raunchies',
          ),),
        ],
      ),
    );
  }
}
