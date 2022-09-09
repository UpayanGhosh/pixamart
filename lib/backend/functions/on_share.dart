import 'dart:math';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

void onShare(String imgTinyUrl, String imgDownloadUrl) async {
  List beautifulSynonyms = [
    'beautiful',
    'aesthetic',
    'cute',
    'lovely',
    'stunning'
  ];
  final dynamicLinkParams = DynamicLinkParameters(
    link:
    Uri.parse('https://pixa.page.link/pic/${imgDownloadUrl.split('/')[4]}'),
    uriPrefix: "https://pixa.page.link/",
    androidParameters: const AndroidParameters(
        packageName: "com.wallpaper.pixamart"),
    iosParameters:
    const IOSParameters(bundleId: "com.example.pixamart"),
    socialMetaTagParameters: SocialMetaTagParameters(
        imageUrl: Uri.parse(imgTinyUrl),
        title: 'Hey Ya! ╚(″⚈ᴗ⚈)╗, here\'s a ${beautifulSynonyms[Random().nextInt(5)]} wallpaper (❁´◡`❁) from your friend at PixaMart',
        description: 'This picture will keep reminding you of the person who sent you this. Keep it at a place where you\'ll always look'
    ),
  );
  final dynamicLink = await FirebaseDynamicLinks.instance
      .buildShortLink(dynamicLinkParams);
  await Share.share('${dynamicLink.shortUrl}');
}