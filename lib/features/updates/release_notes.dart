import 'package:flutter/material.dart';

/// Минимальный Markdown для описаний релизов: заголовки, списки, код,
/// жирный/курсив и ссылки. Полный парсер ради changelog'а не нужен.
class ReleaseNotes extends StatelessWidget {
  const ReleaseNotes(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
    );
    final blocks = _parse(source);
    final children = <Widget>[];
    for (final block in blocks) {
      switch (block.kind) {
        case _BlockKind.heading:
          if (children.isNotEmpty) children.add(const SizedBox(height: 18));
          final style =
              switch (block.level) {
                1 => theme.textTheme.headlineSmall,
                2 => theme.textTheme.titleLarge,
                3 => theme.textTheme.titleMedium,
                _ => theme.textTheme.titleSmall,
              }?.copyWith(
                fontWeight: FontWeight.w700,
                color: block.level >= 3 ? theme.colorScheme.primary : null,
              );
          children.add(Text.rich(_inline(block.text, theme), style: style));
        case _BlockKind.paragraph:
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text.rich(_inline(block.text, theme), style: bodyStyle),
            ),
          );
        case _BlockKind.bullet:
          children.add(
            Padding(
              padding: EdgeInsets.only(top: 6, left: block.level * 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: bodyStyle?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      _inline(block.text, theme),
                      style: bodyStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        case _BlockKind.ordered:
          children.add(
            Padding(
              padding: EdgeInsets.only(top: 6, left: block.level * 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${block.number ?? 1}.',
                      style: bodyStyle?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      _inline(block.text, theme),
                      style: bodyStyle,
                    ),
                  ),
                ],
              ),
            ),
          );
        case _BlockKind.code:
          children.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  block.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: const ['monospace'],
                    height: 1.4,
                  ),
                ),
              ),
            ),
          );
        case _BlockKind.rule:
          children.add(const Divider(height: 28));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

enum _BlockKind { heading, paragraph, bullet, ordered, code, rule }

class _Block {
  const _Block(this.kind, this.text, {this.level = 0, this.number});

  final _BlockKind kind;
  final String text;
  final int level;
  final int? number;
}

List<_Block> _parse(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <_Block>[];
  final paragraph = <String>[];
  final code = <String>[];
  var inCode = false;

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(_Block(_BlockKind.paragraph, paragraph.join(' ')));
    paragraph.clear();
  }

  for (final raw in lines) {
    final line = raw.trimRight();
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('```')) {
      if (inCode) {
        blocks.add(_Block(_BlockKind.code, code.join('\n')));
        code.clear();
        inCode = false;
      } else {
        flushParagraph();
        inCode = true;
      }
      continue;
    }
    if (inCode) {
      code.add(raw);
      continue;
    }
    if (trimmed.isEmpty) {
      flushParagraph();
      continue;
    }
    if (trimmed == '---' || trimmed == '***') {
      flushParagraph();
      blocks.add(const _Block(_BlockKind.rule, ''));
      continue;
    }
    final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(trimmed);
    if (heading != null) {
      flushParagraph();
      blocks.add(
        _Block(
          _BlockKind.heading,
          heading.group(2)!.trim(),
          level: heading.group(1)!.length,
        ),
      );
      continue;
    }
    final bullet = RegExp(r'^(\s*)[-*+]\s+(.*)$').firstMatch(line);
    if (bullet != null) {
      flushParagraph();
      blocks.add(
        _Block(
          _BlockKind.bullet,
          bullet.group(2)!.trim(),
          level: (bullet.group(1)!.length ~/ 2).clamp(0, 3),
        ),
      );
      continue;
    }
    final ordered = RegExp(r'^(\s*)(\d+)\.\s+(.*)$').firstMatch(line);
    if (ordered != null) {
      flushParagraph();
      blocks.add(
        _Block(
          _BlockKind.ordered,
          ordered.group(3)!.trim(),
          level: (ordered.group(1)!.length ~/ 2).clamp(0, 3),
          number: int.tryParse(ordered.group(2)!),
        ),
      );
      continue;
    }
    if (trimmed.startsWith('> ')) {
      flushParagraph();
      blocks.add(_Block(_BlockKind.paragraph, trimmed.substring(2).trim()));
      continue;
    }
    paragraph.add(trimmed);
  }
  if (inCode && code.isNotEmpty) {
    blocks.add(_Block(_BlockKind.code, code.join('\n')));
  }
  flushParagraph();
  return blocks;
}

InlineSpan _inline(String text, ThemeData theme) {
  final spans = <TextSpan>[];
  final pattern = RegExp(
    r'(\*\*[^*]+\*\*|`[^`]+`|\*[^*]+\*|_[^_]+_|\[[^\]]+\]\([^)]+\))',
  );
  var index = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > index) {
      spans.add(TextSpan(text: text.substring(index, match.start)));
    }
    final token = match.group(0)!;
    if (token.startsWith('**') && token.endsWith('**') && token.length > 4) {
      spans.add(
        TextSpan(
          text: token.substring(2, token.length - 2),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    } else if (token.startsWith('`') && token.endsWith('`')) {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: TextStyle(
            fontFamily: 'monospace',
            fontFamilyFallback: const ['monospace'],
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    } else if (token.startsWith('*') || token.startsWith('_')) {
      spans.add(
        TextSpan(
          text: token.substring(1, token.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    } else {
      final link = RegExp(r'^\[([^\]]+)\]\(([^)]+)\)$').firstMatch(token);
      if (link != null) {
        spans.add(
          TextSpan(
            text: link.group(1),
            style: TextStyle(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: token));
      }
    }
    index = match.end;
  }
  if (index < text.length) {
    spans.add(TextSpan(text: text.substring(index)));
  }
  return TextSpan(children: spans);
}
