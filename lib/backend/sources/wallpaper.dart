import 'dart:convert';

enum WallpaperSourceId { pexels, unsplash, pixabay, wallhaven, openverse, nasa, bing }

class Wallpaper {
  final WallpaperSourceId source;
  final String id;
  final String showUrl;
  final String downloadUrl;
  final String tinyUrl;
  final String? author;
  final String? pageUrl;
  final String? downloadTrackUrl;

  const Wallpaper({
    required this.source,
    required this.id,
    required this.showUrl,
    required this.downloadUrl,
    required this.tinyUrl,
    this.author,
    this.pageUrl,
    this.downloadTrackUrl,
  });

  String get attribution {
    final label = sourceLabels[source]!;
    if (author == null || author!.trim().isEmpty) return 'via $label';
    return 'Photo by ${author!.trim()} on $label';
  }
}

const Map<WallpaperSourceId, String> sourceLabels = {
  WallpaperSourceId.pexels: 'Pexels',
  WallpaperSourceId.unsplash: 'Unsplash',
  WallpaperSourceId.pixabay: 'Pixabay',
  WallpaperSourceId.wallhaven: 'Wallhaven',
  WallpaperSourceId.openverse: 'Openverse',
  WallpaperSourceId.nasa: 'NASA',
  WallpaperSourceId.bing: 'Bing Daily',
};

final RegExp _pexelsPhotoUrl = RegExp(r'^https://images\.pexels\.com/photos/(\d+)/');

/// Firebase-safe key for a wallpaper URL. Pexels keeps its numeric id so
/// favourites/downloads synced by older app versions still match.
String cloudKeyFor(String url) {
  final pexels = _pexelsPhotoUrl.firstMatch(url);
  if (pexels != null) return pexels.group(1)!;
  return 'u_${base64Url.encode(utf8.encode(url)).replaceAll('=', '')}';
}

Map<String, String> cloudRecordFor(String downloadUrl) =>
    {'img': cloudKeyFor(downloadUrl), 'url': downloadUrl};

/// Rebuilds (show, download, tiny) URLs from a synced cloud record.
List<String> urlsFromCloudRecord(Map record) {
  final url = record['url'];
  if (url is String && url.isNotEmpty) return [url, url, url];
  final id = record['img'];
  return [
    'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg?auto=compress&cs=tinysrgb&fit=crop&h=1200&w=800',
    'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg',
    'https://images.pexels.com/photos/$id/pexels-photo-$id.jpeg?auto=compress&cs=tinysrgb&dpr=1&fit=crop&h=200&w=280',
  ];
}
