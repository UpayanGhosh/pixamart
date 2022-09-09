String currentPexelsApiKey = 'PLACE_YOUR_MAIN_API_KEY_HERE';
String alternatePexelsApiKey = 'PLACE_YOUR_ALTERNATE_API_KEY_HERE';
String _temp = '';

void swapKeys() {
  _temp = currentPexelsApiKey;
  currentPexelsApiKey = alternatePexelsApiKey;
  alternatePexelsApiKey = _temp;
}
