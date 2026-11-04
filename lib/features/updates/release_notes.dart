import 'package:flutter/material.dart';

/// Минимальный Markdown для описаний релизов: заголовки, списки, код,
/// жирный/курсив и ссылки. Полный парсер ради changelog'а не нужен.
class ReleaseNotes extends StatelessWidget {
  const ReleaseNotes(this.source, {super.key, this.token = ''});

  final String source;

  /// Токен GitHub: картинки закрытого репозитория грузятся через API.
  final String token;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.5,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
    );
    final blocks = _parse(source);
    // M3: каждый раздел (## / ###) — своя тональная карточка; то, что до
    // первого заголовка (обычно картинка-баннер), идёт без карточки.
    final sections = <Widget>[];
    var children = <Widget>[];
    var inCard = false;
    void flush() {
      if (children.isEmpty) return;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
      if (sections.isNotEmpty) sections.add(const SizedBox(height: 12));
      sections.add(
        inCard
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: content,
              )
            : content,
      );
      children = <Widget>[];
    }

    for (final block in blocks) {
      switch (block.kind) {
        case _BlockKind.heading:
          // «Что нового» уже стоит в шапке страницы — дубль не рисуем.
          if (RegExp(
            r"^(что нового|what's new)$",
            caseSensitive: false,
          ).hasMatch(block.text.trim())) {
            continue;
          }
          if (block.level >= 2) {
            flush();
            inCard = true;
          } else if (children.isNotEmpty) {
            children.add(const SizedBox(height: 16));
          }
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
                  // Тональная точка-маркер вместо символа «•».
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
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
        case _BlockKind.image:
          final source = releaseImageSource(block.text, token);
          children.add(
            Padding(
              padding: EdgeInsets.only(top: children.isEmpty ? 0 : 12),
              // Баннер открывается на весь экран: там его можно
              // приблизить пальцами и рассмотреть мелкий текст.
              child: _ZoomableImage(
                tag: 'release-image-${children.length}-${source.url}',
                url: source.url,
                headers: source.headers,
              ),
            ),
          );
      }
    }
    flush();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

class _ZoomableImage extends StatelessWidget {
  const _ZoomableImage({
    required this.tag,
    required this.url,
    required this.headers,
  });

  final String tag;
  final String url;
  final Map<String, String> headers;

  Widget _image(BoxFit fit) => Image.network(
    url,
    headers: headers,
    fit: fit,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: _ImageViewer(tag: tag, child: _image(BoxFit.contain)),
        ),
      ),
    ),
    child: Hero(
      tag: tag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _image(BoxFit.fitWidth),
      ),
    ),
  );
}

/// Полноэкранный просмотр картинки: щипок приближает до 5×, двойное
/// касание — 2.5× и обратно, тап или «назад» закрывают.
class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.tag, required this.child});

  final String tag;
  final Widget child;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  final _controller = TransformationController();
  TapDownDetails? _doubleTap;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final point = _doubleTap?.localPosition;
    if (_controller.value.getMaxScaleOnAxis() > 1.01 || point == null) {
      _controller.value = Matrix4.identity();
      return;
    }
    const scale = 2.5;
    _controller.value = Matrix4.identity()
      ..translateByDouble(
        -point.dx * (scale - 1),
        -point.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            onDoubleTapDown: (details) => _doubleTap = details,
            onDoubleTap: _toggleZoom,
            child: InteractiveViewer(
              transformationController: _controller,
              maxScale: 5,
              child: Center(
                child: Hero(tag: widget.tag, child: widget.child),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 12,
          child: IconButton.filledTonal(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    ),
  );
}

enum _BlockKind { heading, paragraph, bullet, ordered, code, rule, image }

/// Ссылку вида github.com/o/r/blob/ref/path переводит в API: обычная
/// ссылка закрытого репозитория без входа в браузере не отдаёт файл.
({String url, Map<String, String> headers}) releaseImageSource(
  String url,
  String token,
) {
  final blob = RegExp(
    r'^https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/([^?#]+)',
  ).firstMatch(url);
  if (blob == null || token.isEmpty) return (url: url, headers: const {});
  return (
    url:
        'https://api.github.com/repos/${blob.group(1)}/${blob.group(2)}'
        '/contents/${blob.group(4)}?ref=${blob.group(3)}',
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/vnd.github.raw',
    },
  );
}

final _imagePattern = RegExp(
  r'''^(?:<img\s[^>]*src=["']([^"']+)["'][^>]*>|!\[[^\]]*\]\(([^)\s]+)[^)]*\))$''',
);

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
    final image = _imagePattern.firstMatch(trimmed);
    if (image != null) {
      flushParagraph();
      blocks.add(_Block(_BlockKind.image, image.group(1) ?? image.group(2)!));
      continue;
    }
    if (trimmed.startsWith('<') && trimmed.endsWith('>')) {
      // Прочий HTML (обёртки <p>, <details>) в приложении не показываем.
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
