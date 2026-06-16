String normalizeRecognizedText(String? text) {
  if (text == null) {
    return '';
  }

  return text.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).join(' ').trim();
}
