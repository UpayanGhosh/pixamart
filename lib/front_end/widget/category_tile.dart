import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String imgUrl, title;
  const CategoryTile({Key? key, required this.title, required this.imgUrl}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/category', arguments: {'categoryName': title.toLowerCase()});
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 98),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imgUrl,
                  height: MediaQuery.of(context).size.height / 16.68,
                  width: MediaQuery.of(context).size.width / 3.92,
                  fit: BoxFit.fitWidth,
                )),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              height: MediaQuery.of(context).size.height / 16.68,
              width: MediaQuery.of(context).size.width / 3.92,
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.height / 52.125,
                    fontFamily: 'Nexa',),
              ),
            ),
          ],
        ),
      ),
    );
  }
}