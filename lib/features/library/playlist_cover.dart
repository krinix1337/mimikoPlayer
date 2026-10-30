import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app_providers.dart';
import '../../core/logging/app_logger.dart';

/// Выбор картинки из галереи для обложки плейлиста. Файл копируется в
/// каталог приложения: путь из галереи может исчезнуть. Возвращает адрес
/// `file://` или null, если пользователь ничего не выбрал.
Future<String?> pickPlaylistCoverFile() async {
  try {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return null;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'playlist_covers'));
    if (!await dir.exists()) await dir.create(recursive: true);
    final target = File(
      p.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path)}',
      ),
    );
    await File(picked.path).copy(target.path);
    return Uri.file(target.path).toString();
  } on Object catch (error) {
    AppLogger.instance.warn('обложка плейлиста не выбрана: $error');
    return null;
  }
}

/// Меняет обложку уже созданного плейлиста и обновляет списки.
Future<void> changePlaylistCover(
  BuildContext context,
  WidgetRef ref,
  String playlistId,
) async {
  final cover = await pickPlaylistCoverFile();
  if (cover == null) return;
  final db = ref.read(appServicesProvider).db;
  await db.libraryDao.setPlaylistCover(playlistId, cover);
  ref.invalidate(playlistsProvider);
  ref.invalidate(playlistProvider(playlistId));
}
