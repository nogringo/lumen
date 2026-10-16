import 'bip39_english.dart';

/// Whether [word] belongs to the recovery phrase word list.
bool isPhraseWord(String word) {
  final normalized = word.trim().toLowerCase();
  final index = _lowerBound(normalized);
  return index < bip39English.length && bip39English[index] == normalized;
}

/// The phrase words starting with [prefix], in order, at most [limit].
/// Nothing for an empty prefix.
List<String> phraseWordsStartingWith(String prefix, {int limit = 4}) {
  final start = prefix.trim().toLowerCase();
  if (start.isEmpty) return const [];
  return [
    for (
      var i = _lowerBound(start);
      i < bip39English.length && bip39English[i].startsWith(start);
      i++
    )
      bip39English[i],
  ].take(limit).toList();
}

/// The index of the first word not before [word]. The list is sorted.
int _lowerBound(String word) {
  var low = 0;
  var high = bip39English.length;
  while (low < high) {
    final middle = (low + high) ~/ 2;
    if (bip39English[middle].compareTo(word) < 0) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return low;
}
