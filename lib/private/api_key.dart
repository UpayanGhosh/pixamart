String currentPexelsApiKey = 'hZd6332mn2gQolISEmC7dd4PhA0hN5rMFDgc5wXA0QUFbLadGr4Tsw1p';
String alternatePexelsApiKey = 'PLACE_YOUR_ALTERNATE_API_KEY_HERE';
String _temp = '';

void swapKeys() {
  _temp = currentPexelsApiKey;
  currentPexelsApiKey = alternatePexelsApiKey;
  alternatePexelsApiKey = _temp;
}
