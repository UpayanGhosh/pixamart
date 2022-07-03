import 'package:hive/hive.dart';

part 'favourites_model.g.dart';

@HiveType(typeId: 0)
class Favourites {
  @HiveField(0)
  final String imgShowUrl;
  @HiveField(1)
  final String imgDownloadUrl;
  @HiveField(2)
  final String alt;

  Favourites(this.imgShowUrl, this.imgDownloadUrl, this.alt);
}