import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoneyandex/features/karaoke/lyric_line_layout.dart';

void main() {
  const style = TextStyle(fontSize: 16, height: 1.35);

  test('длинная строка делится на визуальные строки', () {
    const text =
        'Это очень длинная строка текста, которая точно не поместится '
        'в узкую ширину и переносится на несколько строк';
    final layout = LyricLineLayout.measure(
      text: text,
      style: style,
      width: 200,
    );

    expect(layout.parts.length, greaterThan(1));
    expect(layout.widths.length, layout.parts.length);
    expect(layout.widths.every((width) => width <= 200.1), isTrue);
    expect(layout.parts.join(' '), contains('несколько строк'));
    expect(layout.lineHeight, greaterThan(0));
  });

  test('короткая строка остаётся одной', () {
    final layout = LyricLineLayout.measure(
      text: 'Короткая строка',
      style: style,
      width: 400,
    );

    expect(layout.parts, ['Короткая строка']);
  });

  test('явный перенос сохраняет пустую строку', () {
    final layout = LyricLineLayout.measure(
      text: 'Первая\n\nТретья',
      style: style,
      width: 400,
    );

    expect(layout.parts, ['Первая', '', 'Третья']);
  });
}
