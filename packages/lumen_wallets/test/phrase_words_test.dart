import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:test/test.dart';

void main() {
  test('knows the words of the list, whatever the case', () {
    expect(isPhraseWord('abandon'), isTrue);
    expect(isPhraseWord(' Zoo '), isTrue);
    expect(isPhraseWord('abandons'), isFalse);
    expect(isPhraseWord(''), isFalse);
  });

  test('suggests the words starting with what is typed', () {
    expect(phraseWordsStartingWith('ab'), [
      'abandon',
      'ability',
      'able',
      'about',
    ]);
    expect(phraseWordsStartingWith('zo'), ['zone', 'zoo']);
    expect(phraseWordsStartingWith('Appl', limit: 2), ['apple']);
    expect(phraseWordsStartingWith('xyz'), isEmpty);
    expect(phraseWordsStartingWith(' '), isEmpty);
  });
}
