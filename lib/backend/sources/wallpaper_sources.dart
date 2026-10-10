import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_keys.dart';
import 'wallpaper.dart';

abstract class WallpaperSource {
  WallpaperSourceId get id;
  bool get isEnabled => true;
  bool get supportsSearch => true;
  Future<List<Wallpaper>> curated(int page);
  Future<List<Wallpaper>> search(String query, int page);
  Future<void> trackDownload(Wallpaper wallpaper) async {}
}

Future<dynamic> _getJson(Uri uri, {Map<String, String>? headers}) async {
  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 20));
  if (response.statusCode != 200) {
    throw http.ClientException('HTTP ${response.statusCode}', uri);
  }
  return jsonDecode(response.body);
}

String? _str(dynamic value) => value is String && value.isNotEmpty ? value : null;

class PexelsSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.pexels;
  @override
  bool get isEnabled => ApiKeys.pexels.isNotEmpty;

  Map<String, String> get _headers => {'Authorization': ApiKeys.pexels};

  List<Wallpaper> _parse(dynamic body) => (body['photos'] as List)
      .map((p) => Wallpaper(
            source: id,
            id: '${p['id']}',
            showUrl: p['src']['portrait'],
            downloadUrl: p['src']['original'],
            tinyUrl: p['src']['tiny'],
            author: _str(p['photographer']),
            pageUrl: _str(p['url']),
          ))
      .toList();

  @override
  Future<List<Wallpaper>> curated(int page) async => _parse(await _getJson(
      Uri.https('api.pexels.com', '/v1/curated', {'page': '$page', 'per_page': '40'}),
      headers: _headers));

  @override
  Future<List<Wallpaper>> search(String query, int page) async => _parse(await _getJson(
      Uri.https('api.pexels.com', '/v1/search', {
        'query': query,
        'page': '$page',
        'per_page': '40',
        'orientation': 'portrait',
      }),
      headers: _headers));
}

class UnsplashSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.unsplash;
  @override
  bool get isEnabled => ApiKeys.unsplash.isNotEmpty;

  Map<String, String> get _headers =>
      {'Authorization': 'Client-ID ${ApiKeys.unsplash}', 'Accept-Version': 'v1'};

  static const _utm = 'utm_source=pixamart&utm_medium=referral';

  Wallpaper _photo(dynamic p) {
    final user = p['user'] ?? {};
    final userLink = _str(user['links']?['html']);
    return Wallpaper(
      source: id,
      id: '${p['id']}',
      showUrl: p['urls']['regular'],
      downloadUrl: p['urls']['full'],
      tinyUrl: p['urls']['thumb'],
      author: _str(user['name']),
      pageUrl: userLink == null ? null : '$userLink?$_utm',
      downloadTrackUrl: _str(p['links']?['download_location']),
    );
  }

  @override
  Future<List<Wallpaper>> curated(int page) async {
    final body = await _getJson(
        Uri.https('api.unsplash.com', '/topics/wallpapers/photos',
            {'page': '$page', 'per_page': '30', 'orientation': 'portrait'}),
        headers: _headers);
    return (body as List).map(_photo).toList();
  }

  @override
  Future<List<Wallpaper>> search(String query, int page) async {
    final body = await _getJson(
        Uri.https('api.unsplash.com', '/search/photos', {
          'query': query,
          'page': '$page',
          'per_page': '30',
          'orientation': 'portrait',
          'content_filter': 'high',
        }),
        headers: _headers);
    return (body['results'] as List).map(_photo).toList();
  }

  /// Required by the Unsplash API guidelines whenever a photo is downloaded.
  @override
  Future<void> trackDownload(Wallpaper wallpaper) async {
    final url = wallpaper.downloadTrackUrl;
    if (url == null) return;
    try {
      await http.get(Uri.parse(url), headers: _headers);
    } catch (_) {}
  }
}

class PixabaySource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.pixabay;
  @override
  bool get isEnabled => ApiKeys.pixabay.isNotEmpty;

  Future<List<Wallpaper>> _fetch(Map<String, String> params) async {
    final body = await _getJson(Uri.https('pixabay.com', '/api/', {
      'key': ApiKeys.pixabay,
      'image_type': 'photo',
      'orientation': 'vertical',
      'safesearch': 'true',
      'per_page': '40',
      ...params,
    }));
    return (body['hits'] as List)
        .map((h) => Wallpaper(
              source: id,
              id: '${h['id']}',
              showUrl: h['webformatURL'],
              downloadUrl: h['largeImageURL'],
              tinyUrl: h['previewURL'],
              author: _str(h['user']),
              pageUrl: _str(h['pageURL']),
            ))
        .toList();
  }

  @override
  Future<List<Wallpaper>> curated(int page) =>
      _fetch({'editors_choice': 'true', 'order': 'popular', 'page': '$page'});

  @override
  Future<List<Wallpaper>> search(String query, int page) =>
      _fetch({'q': query, 'page': '$page'});
}

/// SFW only (purity=100) — never request sketchy/NSFW content.
class WallhavenSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.wallhaven;

  Future<List<Wallpaper>> _fetch(Map<String, String> params) async {
    final body = await _getJson(Uri.https('wallhaven.cc', '/api/v1/search', {
      'purity': '100',
      'categories': '110',
      'ratios': 'portrait',
      ...params,
    }));
    return (body['data'] as List)
        .where((w) => w['purity'] == 'sfw')
        .map((w) => Wallpaper(
              source: id,
              id: '${w['id']}',
              showUrl: w['thumbs']['original'],
              downloadUrl: w['path'],
              tinyUrl: w['thumbs']['small'],
              pageUrl: _str(w['url']),
            ))
        .toList();
  }

  @override
  Future<List<Wallpaper>> curated(int page) =>
      _fetch({'sorting': 'toplist', 'topRange': '1M', 'page': '$page'});

  @override
  Future<List<Wallpaper>> search(String query, int page) =>
      _fetch({'q': query, 'sorting': 'relevance', 'page': '$page'});
}

class OpenverseSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.openverse;

  Future<List<Wallpaper>> _fetch(String query, int page) async {
    final body = await _getJson(Uri.https('api.openverse.org', '/v1/images/', {
      'q': query,
      'page': '$page',
      'page_size': '20',
      'aspect_ratio': 'tall',
      'size': 'large',
      'mature': 'false',
    }));
    return (body['results'] as List)
        .map((r) => Wallpaper(
              source: id,
              id: '${r['id']}',
              showUrl: r['url'],
              downloadUrl: r['url'],
              tinyUrl: r['thumbnail'] ?? r['url'],
              author: _str(r['creator']),
              pageUrl: _str(r['foreign_landing_url']),
            ))
        .toList();
  }

  @override
  Future<List<Wallpaper>> curated(int page) => _fetch('wallpaper', page);

  @override
  Future<List<Wallpaper>> search(String query, int page) => _fetch(query, page);
}

/// NASA Image and Video Library — public, no API key needed.
class NasaSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.nasa;

  Future<List<Wallpaper>> _fetch(String query, int page) async {
    final body = await _getJson(Uri.https('images-api.nasa.gov', '/search', {
      'q': query,
      'media_type': 'image',
      'page': '$page',
      'page_size': '40',
    }));
    final items = body['collection']['items'] as List;
    final result = <Wallpaper>[];
    for (final item in items) {
      final links = ((item['links'] ?? []) as List)
          .map((l) => l['href'] as String)
          .where((href) => href.endsWith('.jpg'))
          .toList();
      if (links.isEmpty) continue;
      String pick(List<String> suffixes) => links.firstWhere(
          (l) => suffixes.any(l.contains),
          orElse: () => links.first);
      final data = (item['data'] as List).first;
      result.add(Wallpaper(
        source: id,
        id: '${data['nasa_id']}',
        showUrl: pick(['~medium', '~large', '~small']),
        downloadUrl: pick(['~orig', '~large', '~medium']),
        tinyUrl: pick(['~thumb', '~small']),
        author: _str(data['photographer']) ?? _str(data['center']),
        pageUrl: 'https://images.nasa.gov/details/${data['nasa_id']}',
      ));
    }
    return result;
  }

  @override
  Future<List<Wallpaper>> curated(int page) => _fetch('nebula galaxy', page);

  @override
  Future<List<Wallpaper>> search(String query, int page) => _fetch(query, page);
}

/// Bing homepage image of the day (unofficial endpoint, last ~15 days only).
class BingSource extends WallpaperSource {
  @override
  WallpaperSourceId get id => WallpaperSourceId.bing;
  @override
  bool get supportsSearch => false;

  @override
  Future<List<Wallpaper>> curated(int page) async {
    if (page > 2) return [];
    final body = await _getJson(Uri.https('www.bing.com', '/HPImageArchive.aspx', {
      'format': 'js',
      'idx': page == 1 ? '0' : '8',
      'n': '8',
      'mkt': 'en-US',
    }));
    return (body['images'] as List).map((img) {
      final base = 'https://www.bing.com${img['urlbase']}';
      return Wallpaper(
        source: id,
        id: '${img['startdate']}',
        showUrl: '${base}_1080x1920.jpg',
        downloadUrl: '${base}_UHD.jpg',
        tinyUrl: '${base}_480x800.jpg',
        author: _str(img['copyright']),
        pageUrl: _str(img['copyrightlink']),
      );
    }).toList();
  }

  @override
  Future<List<Wallpaper>> search(String query, int page) async => [];
}
