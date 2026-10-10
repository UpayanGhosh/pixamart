import 'package:PixaMart/backend/sources/wallpaper_repository.dart';
import 'package:share_plus/share_plus.dart';

Future<void> onShare(String imgTinyUrl, String imgDownloadUrl) async {
  final wallpaper = WallpaperRepository.lookup(imgDownloadUrl) ??
      WallpaperRepository.lookup(imgTinyUrl);
  final link = wallpaper?.pageUrl ?? imgDownloadUrl;
  final credit = wallpaper == null ? '' : ' (${wallpaper.attribution})';
  await SharePlus.instance.share(ShareParams(
      text: 'Here\'s a wallpaper from your friend at PixaMart$credit: $link'));
}
