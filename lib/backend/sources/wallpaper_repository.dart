import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'wallpaper.dart';
import 'wallpaper_sources.dart';

class WallpaperRepository {
  static const _settingsBox = 'settings';
  static const _sourceKey = 'wallpaperSource';

  static final List<WallpaperSource> _all = [
    PexelsSource(),
    UnsplashSource(),
    PixabaySource(),
    WallhavenSource(),
    OpenverseSource(),
    NasaSource(),
    BingSource(),
  ];

  static List<WallpaperSource> get enabledSources =>
      _all.where((s) => s.isEnabled).toList();

  static final Rx<WallpaperSourceId> selected =
      enabledSources.first.id.obs;

  static final Map<String, Wallpaper> _byUrl = {};

  static Future<void> init() async {
    final box = await Hive.openBox(_settingsBox);
    final saved = box.get(_sourceKey);
    final match = enabledSources.where((s) => s.id.name == saved);
    if (match.isNotEmpty) selected.value = match.first.id;
  }

  static Future<void> select(WallpaperSourceId id) async {
    selected.value = id;
    await Hive.box(_settingsBox).put(_sourceKey, id.name);
  }

  static WallpaperSource get _current =>
      enabledSources.firstWhere((s) => s.id == selected.value);

  static List<Wallpaper> _remember(List<Wallpaper> list) {
    for (final w in list) {
      _byUrl[w.showUrl] = w;
      _byUrl[w.downloadUrl] = w;
    }
    return list;
  }

  static Future<List<Wallpaper>> curated(int page) async =>
      _remember(await _current.curated(page));

  /// Falls back to the first searchable source when the selected one can't search.
  static Future<List<Wallpaper>> search(String query, int page) async {
    final source = _current.supportsSearch
        ? _current
        : enabledSources.firstWhere((s) => s.supportsSearch);
    return _remember(await source.search(query, page));
  }

  static Wallpaper? lookup(String url) => _byUrl[url];

  static Future<void> trackDownload(String url) async {
    final wallpaper = _byUrl[url];
    if (wallpaper == null) return;
    await _all.firstWhere((s) => s.id == wallpaper.source).trackDownload(wallpaper);
  }
}
