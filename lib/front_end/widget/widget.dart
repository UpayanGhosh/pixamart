import 'package:flutter/material.dart';

Widget brand_name(){
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text('Pixa', style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),),
      Text('Mart', style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),),
    ],
  );
}



















/*
Widget wallpapersList({ required List<WallPaper> wallpapers,context}){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:  GridView.count(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            mainAxisSpacing: 6.0 ,
            crossAxisSpacing: 6.0,
            children: wallpapers.map((wallpaper){
              return GridTile(child: Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(wallpaper.src.portrait, fit: BoxFit.cover,)),
              ),
              );
            }).toList(),
          ),
        );
      }*/
