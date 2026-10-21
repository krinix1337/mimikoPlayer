import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';

/// Хранение токенов источников. Приложение не ругается на пустоту: не
/// заполнено — значит пользователь не входился.
class AuthDao {
  AuthDao(this._db);

  final AppDatabase _db;

  Future<AuthToken?> load(String provider) =>
      (_db.select(_db.authTokens)..where((t) => t.provider.equals(provider)))
          .getSingleOrNull();

  Future<void> save({
    required String provider,
    required String accessToken,
    String? refreshToken,
    String tokenType = 'OAuth',
    int? expiresAtEpochMs,
    String? uid,
    String? login,
    String? displayName,
    bool hasPlus = false,
    Map<String, Object?>? extra,
  }) => _db.into(_db.authTokens).insertOnConflictUpdate(
    AuthTokensCompanion.insert(
      provider: provider,
      accessToken: accessToken,
      refreshToken: Value(refreshToken),
      tokenType: Value(tokenType),
      expiresAt: Value(expiresAtEpochMs),
      uid: Value(uid),
      login: Value(login),
      displayName: Value(displayName),
      hasPlus: Value(hasPlus),
      extraJson: Value(extra == null ? null : jsonEncode(extra)),
      updatedAt: Value(DateTime.now()),
    ),
  );

  Future<void> clear(String provider) =>
      (_db.delete(_db.authTokens)..where((t) => t.provider.equals(provider)))
          .go();
}
