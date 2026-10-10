import 'package:PixaMart/backend/sources/wallpaper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pexels URLs keep their legacy numeric cloud key', () {
    expect(
        cloudKeyFor('https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg'),
        '2014422');
  });

  test('Other sources get a Firebase-safe key', () {
    final key = cloudKeyFor('https://w.wallhaven.cc/full/gw/wallhaven-gw1ppq.jpg');
    expect(key, startsWith('u_'));
    expect(key, isNot(matches(RegExp(r'[.#$\[\]/=]'))));
  });

  test('Cloud records round-trip non-Pexels URLs', () {
    const url = 'https://images.unsplash.com/photo-123?ixid=abc';
    expect(urlsFromCloudRecord(cloudRecordFor(url)), [url, url, url]);
  });

  test('Legacy Pexels records rebuild Pexels URLs', () {
    final urls = urlsFromCloudRecord({'img': '42'});
    expect(urls[1], 'https://images.pexels.com/photos/42/pexels-photo-42.jpeg');
  });
}
