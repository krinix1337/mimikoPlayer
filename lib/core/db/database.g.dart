// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArtistsTable extends Artists with TableInfo<$ArtistsTable, Artist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormMeta = const VerificationMeta(
    'nameNorm',
  );
  @override
  late final GeneratedColumn<String> nameNorm = GeneratedColumn<String>(
    'name_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteArtistIdMeta = const VerificationMeta(
    'remoteArtistId',
  );
  @override
  late final GeneratedColumn<String> remoteArtistId = GeneratedColumn<String>(
    'remote_artist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameNorm,
    coverUrl,
    source,
    remoteArtistId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Artist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_norm')) {
      context.handle(
        _nameNormMeta,
        nameNorm.isAcceptableOrUnknown(data['name_norm']!, _nameNormMeta),
      );
    } else if (isInserting) {
      context.missing(_nameNormMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('remote_artist_id')) {
      context.handle(
        _remoteArtistIdMeta,
        remoteArtistId.isAcceptableOrUnknown(
          data['remote_artist_id']!,
          _remoteArtistIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteArtistIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Artist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Artist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_norm'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      remoteArtistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_artist_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(attachedDatabase, alias);
  }
}

class Artist extends DataClass implements Insertable<Artist> {
  final int id;
  final String name;

  /// Нормализованное имя — ключ матчинга между источниками.
  final String nameNorm;
  final String? coverUrl;
  final String source;
  final String remoteArtistId;
  final DateTime updatedAt;
  const Artist({
    required this.id,
    required this.name,
    required this.nameNorm,
    this.coverUrl,
    required this.source,
    required this.remoteArtistId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_norm'] = Variable<String>(nameNorm);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    map['source'] = Variable<String>(source);
    map['remote_artist_id'] = Variable<String>(remoteArtistId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      id: Value(id),
      name: Value(name),
      nameNorm: Value(nameNorm),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      source: Value(source),
      remoteArtistId: Value(remoteArtistId),
      updatedAt: Value(updatedAt),
    );
  }

  factory Artist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Artist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNorm: serializer.fromJson<String>(json['nameNorm']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      source: serializer.fromJson<String>(json['source']),
      remoteArtistId: serializer.fromJson<String>(json['remoteArtistId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameNorm': serializer.toJson<String>(nameNorm),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'source': serializer.toJson<String>(source),
      'remoteArtistId': serializer.toJson<String>(remoteArtistId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Artist copyWith({
    int? id,
    String? name,
    String? nameNorm,
    Value<String?> coverUrl = const Value.absent(),
    String? source,
    String? remoteArtistId,
    DateTime? updatedAt,
  }) => Artist(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNorm: nameNorm ?? this.nameNorm,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    source: source ?? this.source,
    remoteArtistId: remoteArtistId ?? this.remoteArtistId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Artist copyWithCompanion(ArtistsCompanion data) {
    return Artist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNorm: data.nameNorm.present ? data.nameNorm.value : this.nameNorm,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      source: data.source.present ? data.source.value : this.source,
      remoteArtistId: data.remoteArtistId.present
          ? data.remoteArtistId.value
          : this.remoteArtistId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Artist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('source: $source, ')
          ..write('remoteArtistId: $remoteArtistId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameNorm,
    coverUrl,
    source,
    remoteArtistId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Artist &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNorm == this.nameNorm &&
          other.coverUrl == this.coverUrl &&
          other.source == this.source &&
          other.remoteArtistId == this.remoteArtistId &&
          other.updatedAt == this.updatedAt);
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameNorm;
  final Value<String?> coverUrl;
  final Value<String> source;
  final Value<String> remoteArtistId;
  final Value<DateTime> updatedAt;
  const ArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNorm = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.source = const Value.absent(),
    this.remoteArtistId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ArtistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameNorm,
    this.coverUrl = const Value.absent(),
    required String source,
    required String remoteArtistId,
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       nameNorm = Value(nameNorm),
       source = Value(source),
       remoteArtistId = Value(remoteArtistId);
  static Insertable<Artist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameNorm,
    Expression<String>? coverUrl,
    Expression<String>? source,
    Expression<String>? remoteArtistId,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNorm != null) 'name_norm': nameNorm,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (source != null) 'source': source,
      if (remoteArtistId != null) 'remote_artist_id': remoteArtistId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ArtistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameNorm,
    Value<String?>? coverUrl,
    Value<String>? source,
    Value<String>? remoteArtistId,
    Value<DateTime>? updatedAt,
  }) {
    return ArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNorm: nameNorm ?? this.nameNorm,
      coverUrl: coverUrl ?? this.coverUrl,
      source: source ?? this.source,
      remoteArtistId: remoteArtistId ?? this.remoteArtistId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNorm.present) {
      map['name_norm'] = Variable<String>(nameNorm.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (remoteArtistId.present) {
      map['remote_artist_id'] = Variable<String>(remoteArtistId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNorm: $nameNorm, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('source: $source, ')
          ..write('remoteArtistId: $remoteArtistId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteAlbumIdMeta = const VerificationMeta(
    'remoteAlbumId',
  );
  @override
  late final GeneratedColumn<String> remoteAlbumId = GeneratedColumn<String>(
    'remote_album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistIdsCsvMeta = const VerificationMeta(
    'artistIdsCsv',
  );
  @override
  late final GeneratedColumn<String> artistIdsCsv = GeneratedColumn<String>(
    'artist_ids_csv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    coverUrl,
    year,
    releaseDate,
    source,
    remoteAlbumId,
    artistIdsCsv,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums';
  @override
  VerificationContext validateIntegrity(
    Insertable<Album> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('remote_album_id')) {
      context.handle(
        _remoteAlbumIdMeta,
        remoteAlbumId.isAcceptableOrUnknown(
          data['remote_album_id']!,
          _remoteAlbumIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteAlbumIdMeta);
    }
    if (data.containsKey('artist_ids_csv')) {
      context.handle(
        _artistIdsCsvMeta,
        artistIdsCsv.isAcceptableOrUnknown(
          data['artist_ids_csv']!,
          _artistIdsCsvMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Album map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Album(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}release_date'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      remoteAlbumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_album_id'],
      )!,
      artistIdsCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist_ids_csv'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(attachedDatabase, alias);
  }
}

class Album extends DataClass implements Insertable<Album> {
  final int id;
  final String title;
  final String? coverUrl;
  final int? year;
  final DateTime? releaseDate;
  final String source;
  final String remoteAlbumId;

  /// Порядок артистов альбома как в исходном каталоге.
  final String artistIdsCsv;
  final DateTime updatedAt;
  const Album({
    required this.id,
    required this.title,
    this.coverUrl,
    this.year,
    this.releaseDate,
    required this.source,
    required this.remoteAlbumId,
    required this.artistIdsCsv,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    map['source'] = Variable<String>(source);
    map['remote_album_id'] = Variable<String>(remoteAlbumId);
    map['artist_ids_csv'] = Variable<String>(artistIdsCsv);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: Value(id),
      title: Value(title),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      source: Value(source),
      remoteAlbumId: Value(remoteAlbumId),
      artistIdsCsv: Value(artistIdsCsv),
      updatedAt: Value(updatedAt),
    );
  }

  factory Album.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Album(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      year: serializer.fromJson<int?>(json['year']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      source: serializer.fromJson<String>(json['source']),
      remoteAlbumId: serializer.fromJson<String>(json['remoteAlbumId']),
      artistIdsCsv: serializer.fromJson<String>(json['artistIdsCsv']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'year': serializer.toJson<int?>(year),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'source': serializer.toJson<String>(source),
      'remoteAlbumId': serializer.toJson<String>(remoteAlbumId),
      'artistIdsCsv': serializer.toJson<String>(artistIdsCsv),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Album copyWith({
    int? id,
    String? title,
    Value<String?> coverUrl = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<DateTime?> releaseDate = const Value.absent(),
    String? source,
    String? remoteAlbumId,
    String? artistIdsCsv,
    DateTime? updatedAt,
  }) => Album(
    id: id ?? this.id,
    title: title ?? this.title,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    year: year.present ? year.value : this.year,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    source: source ?? this.source,
    remoteAlbumId: remoteAlbumId ?? this.remoteAlbumId,
    artistIdsCsv: artistIdsCsv ?? this.artistIdsCsv,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Album copyWithCompanion(AlbumsCompanion data) {
    return Album(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      year: data.year.present ? data.year.value : this.year,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      source: data.source.present ? data.source.value : this.source,
      remoteAlbumId: data.remoteAlbumId.present
          ? data.remoteAlbumId.value
          : this.remoteAlbumId,
      artistIdsCsv: data.artistIdsCsv.present
          ? data.artistIdsCsv.value
          : this.artistIdsCsv,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('year: $year, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('source: $source, ')
          ..write('remoteAlbumId: $remoteAlbumId, ')
          ..write('artistIdsCsv: $artistIdsCsv, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    coverUrl,
    year,
    releaseDate,
    source,
    remoteAlbumId,
    artistIdsCsv,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Album &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverUrl == this.coverUrl &&
          other.year == this.year &&
          other.releaseDate == this.releaseDate &&
          other.source == this.source &&
          other.remoteAlbumId == this.remoteAlbumId &&
          other.artistIdsCsv == this.artistIdsCsv &&
          other.updatedAt == this.updatedAt);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> coverUrl;
  final Value<int?> year;
  final Value<DateTime?> releaseDate;
  final Value<String> source;
  final Value<String> remoteAlbumId;
  final Value<String> artistIdsCsv;
  final Value<DateTime> updatedAt;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.source = const Value.absent(),
    this.remoteAlbumId = const Value.absent(),
    this.artistIdsCsv = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.coverUrl = const Value.absent(),
    this.year = const Value.absent(),
    this.releaseDate = const Value.absent(),
    required String source,
    required String remoteAlbumId,
    this.artistIdsCsv = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       source = Value(source),
       remoteAlbumId = Value(remoteAlbumId);
  static Insertable<Album> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? coverUrl,
    Expression<int>? year,
    Expression<DateTime>? releaseDate,
    Expression<String>? source,
    Expression<String>? remoteAlbumId,
    Expression<String>? artistIdsCsv,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (year != null) 'year': year,
      if (releaseDate != null) 'release_date': releaseDate,
      if (source != null) 'source': source,
      if (remoteAlbumId != null) 'remote_album_id': remoteAlbumId,
      if (artistIdsCsv != null) 'artist_ids_csv': artistIdsCsv,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AlbumsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? coverUrl,
    Value<int?>? year,
    Value<DateTime?>? releaseDate,
    Value<String>? source,
    Value<String>? remoteAlbumId,
    Value<String>? artistIdsCsv,
    Value<DateTime>? updatedAt,
  }) {
    return AlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      releaseDate: releaseDate ?? this.releaseDate,
      source: source ?? this.source,
      remoteAlbumId: remoteAlbumId ?? this.remoteAlbumId,
      artistIdsCsv: artistIdsCsv ?? this.artistIdsCsv,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (remoteAlbumId.present) {
      map['remote_album_id'] = Variable<String>(remoteAlbumId.value);
    }
    if (artistIdsCsv.present) {
      map['artist_ids_csv'] = Variable<String>(artistIdsCsv.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('year: $year, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('source: $source, ')
          ..write('remoteAlbumId: $remoteAlbumId, ')
          ..write('artistIdsCsv: $artistIdsCsv, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleNormMeta = const VerificationMeta(
    'titleNorm',
  );
  @override
  late final GeneratedColumn<String> titleNorm = GeneratedColumn<String>(
    'title_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecMeta = const VerificationMeta(
    'durationSec',
  );
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
    'duration_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mainArtistIdMeta = const VerificationMeta(
    'mainArtistId',
  );
  @override
  late final GeneratedColumn<int> mainArtistId = GeneratedColumn<int>(
    'main_artist_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artists (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
    'album_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isrcMeta = const VerificationMeta('isrc');
  @override
  late final GeneratedColumn<String> isrc = GeneratedColumn<String>(
    'isrc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _explicitFlagMeta = const VerificationMeta(
    'explicitFlag',
  );
  @override
  late final GeneratedColumn<bool> explicitFlag = GeneratedColumn<bool>(
    'explicit_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lyricsAvailableMeta = const VerificationMeta(
    'lyricsAvailable',
  );
  @override
  late final GeneratedColumn<bool> lyricsAvailable = GeneratedColumn<bool>(
    'lyrics_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lyrics_available" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _popularityMeta = const VerificationMeta(
    'popularity',
  );
  @override
  late final GeneratedColumn<int> popularity = GeneratedColumn<int>(
    'popularity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentRatingMeta = const VerificationMeta(
    'contentRating',
  );
  @override
  late final GeneratedColumn<String> contentRating = GeneratedColumn<String>(
    'content_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _metadataSourceMeta = const VerificationMeta(
    'metadataSource',
  );
  @override
  late final GeneratedColumn<String> metadataSource = GeneratedColumn<String>(
    'metadata_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    titleNorm,
    durationSec,
    mainArtistId,
    albumId,
    coverUrl,
    isrc,
    explicitFlag,
    lyricsAvailable,
    fingerprint,
    popularity,
    contentRating,
    createdAt,
    updatedAt,
    lastSeenAt,
    metadataSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_norm')) {
      context.handle(
        _titleNormMeta,
        titleNorm.isAcceptableOrUnknown(data['title_norm']!, _titleNormMeta),
      );
    } else if (isInserting) {
      context.missing(_titleNormMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
        _durationSecMeta,
        durationSec.isAcceptableOrUnknown(
          data['duration_sec']!,
          _durationSecMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecMeta);
    }
    if (data.containsKey('main_artist_id')) {
      context.handle(
        _mainArtistIdMeta,
        mainArtistId.isAcceptableOrUnknown(
          data['main_artist_id']!,
          _mainArtistIdMeta,
        ),
      );
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('isrc')) {
      context.handle(
        _isrcMeta,
        isrc.isAcceptableOrUnknown(data['isrc']!, _isrcMeta),
      );
    }
    if (data.containsKey('explicit_flag')) {
      context.handle(
        _explicitFlagMeta,
        explicitFlag.isAcceptableOrUnknown(
          data['explicit_flag']!,
          _explicitFlagMeta,
        ),
      );
    }
    if (data.containsKey('lyrics_available')) {
      context.handle(
        _lyricsAvailableMeta,
        lyricsAvailable.isAcceptableOrUnknown(
          data['lyrics_available']!,
          _lyricsAvailableMeta,
        ),
      );
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('popularity')) {
      context.handle(
        _popularityMeta,
        popularity.isAcceptableOrUnknown(data['popularity']!, _popularityMeta),
      );
    }
    if (data.containsKey('content_rating')) {
      context.handle(
        _contentRatingMeta,
        contentRating.isAcceptableOrUnknown(
          data['content_rating']!,
          _contentRatingMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('metadata_source')) {
      context.handle(
        _metadataSourceMeta,
        metadataSource.isAcceptableOrUnknown(
          data['metadata_source']!,
          _metadataSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metadataSourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_norm'],
      )!,
      durationSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_sec'],
      )!,
      mainArtistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}main_artist_id'],
      ),
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_id'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      isrc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isrc'],
      ),
      explicitFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit_flag'],
      )!,
      lyricsAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lyrics_available'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      popularity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}popularity'],
      ),
      contentRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_rating'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      metadataSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_source'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class Track extends DataClass implements Insertable<Track> {
  /// Наш идентификатор: `t_<sha1[..24]>`. Удалённый id сюда не пишем — одна
  /// песня живёт в нескольких каталогах и в файлах пользователя.
  final String id;
  final String title;
  final String titleNorm;
  final int durationSec;
  final int? mainArtistId;
  final int? albumId;
  final String? coverUrl;

  /// Мост между каталогами. Пустая строка = источника без ISRC, а не «нет ISRC».
  final String? isrc;
  final bool explicitFlag;
  final bool lyricsAvailable;
  final String fingerprint;
  final int? popularity;

  /// Пометка для будущего фильтра AI-артистов и цензуры.
  final String? contentRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Для очистки «давно не слушанного» на этапе офлайна.
  final DateTime lastSeenAt;
  final String metadataSource;
  const Track({
    required this.id,
    required this.title,
    required this.titleNorm,
    required this.durationSec,
    this.mainArtistId,
    this.albumId,
    this.coverUrl,
    this.isrc,
    required this.explicitFlag,
    required this.lyricsAvailable,
    required this.fingerprint,
    this.popularity,
    this.contentRating,
    required this.createdAt,
    required this.updatedAt,
    required this.lastSeenAt,
    required this.metadataSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['title_norm'] = Variable<String>(titleNorm);
    map['duration_sec'] = Variable<int>(durationSec);
    if (!nullToAbsent || mainArtistId != null) {
      map['main_artist_id'] = Variable<int>(mainArtistId);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<int>(albumId);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || isrc != null) {
      map['isrc'] = Variable<String>(isrc);
    }
    map['explicit_flag'] = Variable<bool>(explicitFlag);
    map['lyrics_available'] = Variable<bool>(lyricsAvailable);
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || popularity != null) {
      map['popularity'] = Variable<int>(popularity);
    }
    if (!nullToAbsent || contentRating != null) {
      map['content_rating'] = Variable<String>(contentRating);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    map['metadata_source'] = Variable<String>(metadataSource);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      title: Value(title),
      titleNorm: Value(titleNorm),
      durationSec: Value(durationSec),
      mainArtistId: mainArtistId == null && nullToAbsent
          ? const Value.absent()
          : Value(mainArtistId),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      isrc: isrc == null && nullToAbsent ? const Value.absent() : Value(isrc),
      explicitFlag: Value(explicitFlag),
      lyricsAvailable: Value(lyricsAvailable),
      fingerprint: Value(fingerprint),
      popularity: popularity == null && nullToAbsent
          ? const Value.absent()
          : Value(popularity),
      contentRating: contentRating == null && nullToAbsent
          ? const Value.absent()
          : Value(contentRating),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSeenAt: Value(lastSeenAt),
      metadataSource: Value(metadataSource),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      titleNorm: serializer.fromJson<String>(json['titleNorm']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      mainArtistId: serializer.fromJson<int?>(json['mainArtistId']),
      albumId: serializer.fromJson<int?>(json['albumId']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      isrc: serializer.fromJson<String?>(json['isrc']),
      explicitFlag: serializer.fromJson<bool>(json['explicitFlag']),
      lyricsAvailable: serializer.fromJson<bool>(json['lyricsAvailable']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      popularity: serializer.fromJson<int?>(json['popularity']),
      contentRating: serializer.fromJson<String?>(json['contentRating']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      metadataSource: serializer.fromJson<String>(json['metadataSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'titleNorm': serializer.toJson<String>(titleNorm),
      'durationSec': serializer.toJson<int>(durationSec),
      'mainArtistId': serializer.toJson<int?>(mainArtistId),
      'albumId': serializer.toJson<int?>(albumId),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'isrc': serializer.toJson<String?>(isrc),
      'explicitFlag': serializer.toJson<bool>(explicitFlag),
      'lyricsAvailable': serializer.toJson<bool>(lyricsAvailable),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'popularity': serializer.toJson<int?>(popularity),
      'contentRating': serializer.toJson<String?>(contentRating),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'metadataSource': serializer.toJson<String>(metadataSource),
    };
  }

  Track copyWith({
    String? id,
    String? title,
    String? titleNorm,
    int? durationSec,
    Value<int?> mainArtistId = const Value.absent(),
    Value<int?> albumId = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> isrc = const Value.absent(),
    bool? explicitFlag,
    bool? lyricsAvailable,
    String? fingerprint,
    Value<int?> popularity = const Value.absent(),
    Value<String?> contentRating = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeenAt,
    String? metadataSource,
  }) => Track(
    id: id ?? this.id,
    title: title ?? this.title,
    titleNorm: titleNorm ?? this.titleNorm,
    durationSec: durationSec ?? this.durationSec,
    mainArtistId: mainArtistId.present ? mainArtistId.value : this.mainArtistId,
    albumId: albumId.present ? albumId.value : this.albumId,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    isrc: isrc.present ? isrc.value : this.isrc,
    explicitFlag: explicitFlag ?? this.explicitFlag,
    lyricsAvailable: lyricsAvailable ?? this.lyricsAvailable,
    fingerprint: fingerprint ?? this.fingerprint,
    popularity: popularity.present ? popularity.value : this.popularity,
    contentRating: contentRating.present
        ? contentRating.value
        : this.contentRating,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    metadataSource: metadataSource ?? this.metadataSource,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      titleNorm: data.titleNorm.present ? data.titleNorm.value : this.titleNorm,
      durationSec: data.durationSec.present
          ? data.durationSec.value
          : this.durationSec,
      mainArtistId: data.mainArtistId.present
          ? data.mainArtistId.value
          : this.mainArtistId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      isrc: data.isrc.present ? data.isrc.value : this.isrc,
      explicitFlag: data.explicitFlag.present
          ? data.explicitFlag.value
          : this.explicitFlag,
      lyricsAvailable: data.lyricsAvailable.present
          ? data.lyricsAvailable.value
          : this.lyricsAvailable,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      popularity: data.popularity.present
          ? data.popularity.value
          : this.popularity,
      contentRating: data.contentRating.present
          ? data.contentRating.value
          : this.contentRating,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      metadataSource: data.metadataSource.present
          ? data.metadataSource.value
          : this.metadataSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('durationSec: $durationSec, ')
          ..write('mainArtistId: $mainArtistId, ')
          ..write('albumId: $albumId, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('isrc: $isrc, ')
          ..write('explicitFlag: $explicitFlag, ')
          ..write('lyricsAvailable: $lyricsAvailable, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('popularity: $popularity, ')
          ..write('contentRating: $contentRating, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('metadataSource: $metadataSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    titleNorm,
    durationSec,
    mainArtistId,
    albumId,
    coverUrl,
    isrc,
    explicitFlag,
    lyricsAvailable,
    fingerprint,
    popularity,
    contentRating,
    createdAt,
    updatedAt,
    lastSeenAt,
    metadataSource,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.title == this.title &&
          other.titleNorm == this.titleNorm &&
          other.durationSec == this.durationSec &&
          other.mainArtistId == this.mainArtistId &&
          other.albumId == this.albumId &&
          other.coverUrl == this.coverUrl &&
          other.isrc == this.isrc &&
          other.explicitFlag == this.explicitFlag &&
          other.lyricsAvailable == this.lyricsAvailable &&
          other.fingerprint == this.fingerprint &&
          other.popularity == this.popularity &&
          other.contentRating == this.contentRating &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.metadataSource == this.metadataSource);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> titleNorm;
  final Value<int> durationSec;
  final Value<int?> mainArtistId;
  final Value<int?> albumId;
  final Value<String?> coverUrl;
  final Value<String?> isrc;
  final Value<bool> explicitFlag;
  final Value<bool> lyricsAvailable;
  final Value<String> fingerprint;
  final Value<int?> popularity;
  final Value<String?> contentRating;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> lastSeenAt;
  final Value<String> metadataSource;
  final Value<int> rowid;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.titleNorm = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.mainArtistId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.isrc = const Value.absent(),
    this.explicitFlag = const Value.absent(),
    this.lyricsAvailable = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.popularity = const Value.absent(),
    this.contentRating = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.metadataSource = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TracksCompanion.insert({
    required String id,
    required String title,
    required String titleNorm,
    required int durationSec,
    this.mainArtistId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.isrc = const Value.absent(),
    this.explicitFlag = const Value.absent(),
    this.lyricsAvailable = const Value.absent(),
    required String fingerprint,
    this.popularity = const Value.absent(),
    this.contentRating = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    required String metadataSource,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       titleNorm = Value(titleNorm),
       durationSec = Value(durationSec),
       fingerprint = Value(fingerprint),
       metadataSource = Value(metadataSource);
  static Insertable<Track> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? titleNorm,
    Expression<int>? durationSec,
    Expression<int>? mainArtistId,
    Expression<int>? albumId,
    Expression<String>? coverUrl,
    Expression<String>? isrc,
    Expression<bool>? explicitFlag,
    Expression<bool>? lyricsAvailable,
    Expression<String>? fingerprint,
    Expression<int>? popularity,
    Expression<String>? contentRating,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<String>? metadataSource,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (titleNorm != null) 'title_norm': titleNorm,
      if (durationSec != null) 'duration_sec': durationSec,
      if (mainArtistId != null) 'main_artist_id': mainArtistId,
      if (albumId != null) 'album_id': albumId,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (isrc != null) 'isrc': isrc,
      if (explicitFlag != null) 'explicit_flag': explicitFlag,
      if (lyricsAvailable != null) 'lyrics_available': lyricsAvailable,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (popularity != null) 'popularity': popularity,
      if (contentRating != null) 'content_rating': contentRating,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (metadataSource != null) 'metadata_source': metadataSource,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TracksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? titleNorm,
    Value<int>? durationSec,
    Value<int?>? mainArtistId,
    Value<int?>? albumId,
    Value<String?>? coverUrl,
    Value<String?>? isrc,
    Value<bool>? explicitFlag,
    Value<bool>? lyricsAvailable,
    Value<String>? fingerprint,
    Value<int?>? popularity,
    Value<String?>? contentRating,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? lastSeenAt,
    Value<String>? metadataSource,
    Value<int>? rowid,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      titleNorm: titleNorm ?? this.titleNorm,
      durationSec: durationSec ?? this.durationSec,
      mainArtistId: mainArtistId ?? this.mainArtistId,
      albumId: albumId ?? this.albumId,
      coverUrl: coverUrl ?? this.coverUrl,
      isrc: isrc ?? this.isrc,
      explicitFlag: explicitFlag ?? this.explicitFlag,
      lyricsAvailable: lyricsAvailable ?? this.lyricsAvailable,
      fingerprint: fingerprint ?? this.fingerprint,
      popularity: popularity ?? this.popularity,
      contentRating: contentRating ?? this.contentRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      metadataSource: metadataSource ?? this.metadataSource,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleNorm.present) {
      map['title_norm'] = Variable<String>(titleNorm.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (mainArtistId.present) {
      map['main_artist_id'] = Variable<int>(mainArtistId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (isrc.present) {
      map['isrc'] = Variable<String>(isrc.value);
    }
    if (explicitFlag.present) {
      map['explicit_flag'] = Variable<bool>(explicitFlag.value);
    }
    if (lyricsAvailable.present) {
      map['lyrics_available'] = Variable<bool>(lyricsAvailable.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<int>(popularity.value);
    }
    if (contentRating.present) {
      map['content_rating'] = Variable<String>(contentRating.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (metadataSource.present) {
      map['metadata_source'] = Variable<String>(metadataSource.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('titleNorm: $titleNorm, ')
          ..write('durationSec: $durationSec, ')
          ..write('mainArtistId: $mainArtistId, ')
          ..write('albumId: $albumId, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('isrc: $isrc, ')
          ..write('explicitFlag: $explicitFlag, ')
          ..write('lyricsAvailable: $lyricsAvailable, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('popularity: $popularity, ')
          ..write('contentRating: $contentRating, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('metadataSource: $metadataSource, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackArtistsTable extends TrackArtists
    with TableInfo<$TrackArtistsTable, TrackArtist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackArtistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _artistIdMeta = const VerificationMeta(
    'artistId',
  );
  @override
  late final GeneratedColumn<int> artistId = GeneratedColumn<int>(
    'artist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('artist'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, artistId, role, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_artists';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackArtist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(
        _artistIdMeta,
        artistId.isAcceptableOrUnknown(data['artist_id']!, _artistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId, artistId, role};
  @override
  TrackArtist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackArtist(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      artistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artist_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $TrackArtistsTable createAlias(String alias) {
    return $TrackArtistsTable(attachedDatabase, alias);
  }
}

class TrackArtist extends DataClass implements Insertable<TrackArtist> {
  final String trackId;
  final int artistId;

  /// artist | albumArtist | composer — как в каталоге.
  final String role;
  final int position;
  const TrackArtist({
    required this.trackId,
    required this.artistId,
    required this.role,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['artist_id'] = Variable<int>(artistId);
    map['role'] = Variable<String>(role);
    map['position'] = Variable<int>(position);
    return map;
  }

  TrackArtistsCompanion toCompanion(bool nullToAbsent) {
    return TrackArtistsCompanion(
      trackId: Value(trackId),
      artistId: Value(artistId),
      role: Value(role),
      position: Value(position),
    );
  }

  factory TrackArtist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackArtist(
      trackId: serializer.fromJson<String>(json['trackId']),
      artistId: serializer.fromJson<int>(json['artistId']),
      role: serializer.fromJson<String>(json['role']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'artistId': serializer.toJson<int>(artistId),
      'role': serializer.toJson<String>(role),
      'position': serializer.toJson<int>(position),
    };
  }

  TrackArtist copyWith({
    String? trackId,
    int? artistId,
    String? role,
    int? position,
  }) => TrackArtist(
    trackId: trackId ?? this.trackId,
    artistId: artistId ?? this.artistId,
    role: role ?? this.role,
    position: position ?? this.position,
  );
  TrackArtist copyWithCompanion(TrackArtistsCompanion data) {
    return TrackArtist(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      artistId: data.artistId.present ? data.artistId.value : this.artistId,
      role: data.role.present ? data.role.value : this.role,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtist(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('role: $role, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, artistId, role, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackArtist &&
          other.trackId == this.trackId &&
          other.artistId == this.artistId &&
          other.role == this.role &&
          other.position == this.position);
}

class TrackArtistsCompanion extends UpdateCompanion<TrackArtist> {
  final Value<String> trackId;
  final Value<int> artistId;
  final Value<String> role;
  final Value<int> position;
  final Value<int> rowid;
  const TrackArtistsCompanion({
    this.trackId = const Value.absent(),
    this.artistId = const Value.absent(),
    this.role = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackArtistsCompanion.insert({
    required String trackId,
    required int artistId,
    this.role = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       artistId = Value(artistId);
  static Insertable<TrackArtist> custom({
    Expression<String>? trackId,
    Expression<int>? artistId,
    Expression<String>? role,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (artistId != null) 'artist_id': artistId,
      if (role != null) 'role': role,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackArtistsCompanion copyWith({
    Value<String>? trackId,
    Value<int>? artistId,
    Value<String>? role,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return TrackArtistsCompanion(
      trackId: trackId ?? this.trackId,
      artistId: artistId ?? this.artistId,
      role: role ?? this.role,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<int>(artistId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackArtistsCompanion(')
          ..write('trackId: $trackId, ')
          ..write('artistId: $artistId, ')
          ..write('role: $role, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteIdMappingsTable extends RemoteIdMappings
    with TableInfo<$RemoteIdMappingsTable, RemoteIdMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteIdMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _albumRemoteIdMeta = const VerificationMeta(
    'albumRemoteId',
  );
  @override
  late final GeneratedColumn<String> albumRemoteId = GeneratedColumn<String>(
    'album_remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _mappingConfidenceMeta = const VerificationMeta(
    'mappingConfidence',
  );
  @override
  late final GeneratedColumn<String> mappingConfidence =
      GeneratedColumn<String>(
        'mapping_confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('exact'),
      );
  static const VerificationMeta _remoteJsonMeta = const VerificationMeta(
    'remoteJson',
  );
  @override
  late final GeneratedColumn<String> remoteJson = GeneratedColumn<String>(
    'remote_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    source,
    remoteId,
    albumRemoteId,
    localTrackId,
    mappingConfidence,
    remoteJson,
    firstSeenAt,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remote_id_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemoteIdMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('album_remote_id')) {
      context.handle(
        _albumRemoteIdMeta,
        albumRemoteId.isAcceptableOrUnknown(
          data['album_remote_id']!,
          _albumRemoteIdMeta,
        ),
      );
    }
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('mapping_confidence')) {
      context.handle(
        _mappingConfidenceMeta,
        mappingConfidence.isAcceptableOrUnknown(
          data['mapping_confidence']!,
          _mappingConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('remote_json')) {
      context.handle(
        _remoteJsonMeta,
        remoteJson.isAcceptableOrUnknown(data['remote_json']!, _remoteJsonMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {source, remoteId};
  @override
  RemoteIdMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemoteIdMapping(
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      albumRemoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_remote_id'],
      ),
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      mappingConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mapping_confidence'],
      )!,
      remoteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_json'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $RemoteIdMappingsTable createAlias(String alias) {
    return $RemoteIdMappingsTable(attachedDatabase, alias);
  }
}

class RemoteIdMapping extends DataClass implements Insertable<RemoteIdMapping> {
  final String source;

  /// Идентификатор ровно в терминах источника: у Яндекса голое число трека.
  final String remoteId;
  final String? albumRemoteId;
  final String localTrackId;

  /// exact | isrc | fuzzy | manual — по нечёткому совпадению строки не сливаются.
  final String mappingConfidence;

  /// Сырой JSON: новый метаданный поле можно добавить без сетевого рефетча.
  final String? remoteJson;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  const RemoteIdMapping({
    required this.source,
    required this.remoteId,
    this.albumRemoteId,
    required this.localTrackId,
    required this.mappingConfidence,
    this.remoteJson,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source'] = Variable<String>(source);
    map['remote_id'] = Variable<String>(remoteId);
    if (!nullToAbsent || albumRemoteId != null) {
      map['album_remote_id'] = Variable<String>(albumRemoteId);
    }
    map['local_track_id'] = Variable<String>(localTrackId);
    map['mapping_confidence'] = Variable<String>(mappingConfidence);
    if (!nullToAbsent || remoteJson != null) {
      map['remote_json'] = Variable<String>(remoteJson);
    }
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  RemoteIdMappingsCompanion toCompanion(bool nullToAbsent) {
    return RemoteIdMappingsCompanion(
      source: Value(source),
      remoteId: Value(remoteId),
      albumRemoteId: albumRemoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumRemoteId),
      localTrackId: Value(localTrackId),
      mappingConfidence: Value(mappingConfidence),
      remoteJson: remoteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteJson),
      firstSeenAt: Value(firstSeenAt),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory RemoteIdMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemoteIdMapping(
      source: serializer.fromJson<String>(json['source']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      albumRemoteId: serializer.fromJson<String?>(json['albumRemoteId']),
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      mappingConfidence: serializer.fromJson<String>(json['mappingConfidence']),
      remoteJson: serializer.fromJson<String?>(json['remoteJson']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source': serializer.toJson<String>(source),
      'remoteId': serializer.toJson<String>(remoteId),
      'albumRemoteId': serializer.toJson<String?>(albumRemoteId),
      'localTrackId': serializer.toJson<String>(localTrackId),
      'mappingConfidence': serializer.toJson<String>(mappingConfidence),
      'remoteJson': serializer.toJson<String?>(remoteJson),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  RemoteIdMapping copyWith({
    String? source,
    String? remoteId,
    Value<String?> albumRemoteId = const Value.absent(),
    String? localTrackId,
    String? mappingConfidence,
    Value<String?> remoteJson = const Value.absent(),
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) => RemoteIdMapping(
    source: source ?? this.source,
    remoteId: remoteId ?? this.remoteId,
    albumRemoteId: albumRemoteId.present
        ? albumRemoteId.value
        : this.albumRemoteId,
    localTrackId: localTrackId ?? this.localTrackId,
    mappingConfidence: mappingConfidence ?? this.mappingConfidence,
    remoteJson: remoteJson.present ? remoteJson.value : this.remoteJson,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  RemoteIdMapping copyWithCompanion(RemoteIdMappingsCompanion data) {
    return RemoteIdMapping(
      source: data.source.present ? data.source.value : this.source,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      albumRemoteId: data.albumRemoteId.present
          ? data.albumRemoteId.value
          : this.albumRemoteId,
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      mappingConfidence: data.mappingConfidence.present
          ? data.mappingConfidence.value
          : this.mappingConfidence,
      remoteJson: data.remoteJson.present
          ? data.remoteJson.value
          : this.remoteJson,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemoteIdMapping(')
          ..write('source: $source, ')
          ..write('remoteId: $remoteId, ')
          ..write('albumRemoteId: $albumRemoteId, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('mappingConfidence: $mappingConfidence, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    source,
    remoteId,
    albumRemoteId,
    localTrackId,
    mappingConfidence,
    remoteJson,
    firstSeenAt,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemoteIdMapping &&
          other.source == this.source &&
          other.remoteId == this.remoteId &&
          other.albumRemoteId == this.albumRemoteId &&
          other.localTrackId == this.localTrackId &&
          other.mappingConfidence == this.mappingConfidence &&
          other.remoteJson == this.remoteJson &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class RemoteIdMappingsCompanion extends UpdateCompanion<RemoteIdMapping> {
  final Value<String> source;
  final Value<String> remoteId;
  final Value<String?> albumRemoteId;
  final Value<String> localTrackId;
  final Value<String> mappingConfidence;
  final Value<String?> remoteJson;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> lastSeenAt;
  final Value<int> rowid;
  const RemoteIdMappingsCompanion({
    this.source = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.albumRemoteId = const Value.absent(),
    this.localTrackId = const Value.absent(),
    this.mappingConfidence = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteIdMappingsCompanion.insert({
    required String source,
    required String remoteId,
    this.albumRemoteId = const Value.absent(),
    required String localTrackId,
    this.mappingConfidence = const Value.absent(),
    this.remoteJson = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       remoteId = Value(remoteId),
       localTrackId = Value(localTrackId);
  static Insertable<RemoteIdMapping> custom({
    Expression<String>? source,
    Expression<String>? remoteId,
    Expression<String>? albumRemoteId,
    Expression<String>? localTrackId,
    Expression<String>? mappingConfidence,
    Expression<String>? remoteJson,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (source != null) 'source': source,
      if (remoteId != null) 'remote_id': remoteId,
      if (albumRemoteId != null) 'album_remote_id': albumRemoteId,
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (mappingConfidence != null) 'mapping_confidence': mappingConfidence,
      if (remoteJson != null) 'remote_json': remoteJson,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteIdMappingsCompanion copyWith({
    Value<String>? source,
    Value<String>? remoteId,
    Value<String?>? albumRemoteId,
    Value<String>? localTrackId,
    Value<String>? mappingConfidence,
    Value<String?>? remoteJson,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return RemoteIdMappingsCompanion(
      source: source ?? this.source,
      remoteId: remoteId ?? this.remoteId,
      albumRemoteId: albumRemoteId ?? this.albumRemoteId,
      localTrackId: localTrackId ?? this.localTrackId,
      mappingConfidence: mappingConfidence ?? this.mappingConfidence,
      remoteJson: remoteJson ?? this.remoteJson,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (albumRemoteId.present) {
      map['album_remote_id'] = Variable<String>(albumRemoteId.value);
    }
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (mappingConfidence.present) {
      map['mapping_confidence'] = Variable<String>(mappingConfidence.value);
    }
    if (remoteJson.present) {
      map['remote_json'] = Variable<String>(remoteJson.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemoteIdMappingsCompanion(')
          ..write('source: $source, ')
          ..write('remoteId: $remoteId, ')
          ..write('albumRemoteId: $albumRemoteId, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('mappingConfidence: $mappingConfidence, ')
          ..write('remoteJson: $remoteJson, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _remotePlaylistIdMeta = const VerificationMeta(
    'remotePlaylistId',
  );
  @override
  late final GeneratedColumn<String> remotePlaylistId = GeneratedColumn<String>(
    'remote_playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _totalTracksMeta = const VerificationMeta(
    'totalTracks',
  );
  @override
  late final GeneratedColumn<int> totalTracks = GeneratedColumn<int>(
    'total_tracks',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canEditMeta = const VerificationMeta(
    'canEdit',
  );
  @override
  late final GeneratedColumn<bool> canEdit = GeneratedColumn<bool>(
    'can_edit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_edit" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortModeMeta = const VerificationMeta(
    'sortMode',
  );
  @override
  late final GeneratedColumn<String> sortMode = GeneratedColumn<String>(
    'sort_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    source,
    remotePlaylistId,
    title,
    description,
    coverUrl,
    ownerUid,
    kind,
    totalTracks,
    canEdit,
    sortMode,
    lastSyncedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('remote_playlist_id')) {
      context.handle(
        _remotePlaylistIdMeta,
        remotePlaylistId.isAcceptableOrUnknown(
          data['remote_playlist_id']!,
          _remotePlaylistIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('total_tracks')) {
      context.handle(
        _totalTracksMeta,
        totalTracks.isAcceptableOrUnknown(
          data['total_tracks']!,
          _totalTracksMeta,
        ),
      );
    }
    if (data.containsKey('can_edit')) {
      context.handle(
        _canEditMeta,
        canEdit.isAcceptableOrUnknown(data['can_edit']!, _canEditMeta),
      );
    }
    if (data.containsKey('sort_mode')) {
      context.handle(
        _sortModeMeta,
        sortMode.isAcceptableOrUnknown(data['sort_mode']!, _sortModeMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      remotePlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_playlist_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      totalTracks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tracks'],
      ),
      canEdit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_edit'],
      )!,
      sortMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_mode'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class Playlist extends DataClass implements Insertable<Playlist> {
  /// Свой id `pl_...` для локальных, `source:remoteId` для импортированных.
  final String id;

  /// local для плейлистов, созданных в приложении.
  final String source;
  final String? remotePlaylistId;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? ownerUid;

  /// user | imported | radio | liked
  final String kind;
  final int? totalTracks;
  final bool canEdit;

  /// manual | addedDesc — порядок, который реально видит пользователь.
  final String sortMode;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Playlist({
    required this.id,
    required this.source,
    this.remotePlaylistId,
    required this.title,
    this.description,
    this.coverUrl,
    this.ownerUid,
    required this.kind,
    this.totalTracks,
    required this.canEdit,
    required this.sortMode,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || remotePlaylistId != null) {
      map['remote_playlist_id'] = Variable<String>(remotePlaylistId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || ownerUid != null) {
      map['owner_uid'] = Variable<String>(ownerUid);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || totalTracks != null) {
      map['total_tracks'] = Variable<int>(totalTracks);
    }
    map['can_edit'] = Variable<bool>(canEdit);
    map['sort_mode'] = Variable<String>(sortMode);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      source: Value(source),
      remotePlaylistId: remotePlaylistId == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePlaylistId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      ownerUid: ownerUid == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUid),
      kind: Value(kind),
      totalTracks: totalTracks == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTracks),
      canEdit: Value(canEdit),
      sortMode: Value(sortMode),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      remotePlaylistId: serializer.fromJson<String?>(json['remotePlaylistId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      ownerUid: serializer.fromJson<String?>(json['ownerUid']),
      kind: serializer.fromJson<String>(json['kind']),
      totalTracks: serializer.fromJson<int?>(json['totalTracks']),
      canEdit: serializer.fromJson<bool>(json['canEdit']),
      sortMode: serializer.fromJson<String>(json['sortMode']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'remotePlaylistId': serializer.toJson<String?>(remotePlaylistId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'ownerUid': serializer.toJson<String?>(ownerUid),
      'kind': serializer.toJson<String>(kind),
      'totalTracks': serializer.toJson<int?>(totalTracks),
      'canEdit': serializer.toJson<bool>(canEdit),
      'sortMode': serializer.toJson<String>(sortMode),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Playlist copyWith({
    String? id,
    String? source,
    Value<String?> remotePlaylistId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> ownerUid = const Value.absent(),
    String? kind,
    Value<int?> totalTracks = const Value.absent(),
    bool? canEdit,
    String? sortMode,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Playlist(
    id: id ?? this.id,
    source: source ?? this.source,
    remotePlaylistId: remotePlaylistId.present
        ? remotePlaylistId.value
        : this.remotePlaylistId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    ownerUid: ownerUid.present ? ownerUid.value : this.ownerUid,
    kind: kind ?? this.kind,
    totalTracks: totalTracks.present ? totalTracks.value : this.totalTracks,
    canEdit: canEdit ?? this.canEdit,
    sortMode: sortMode ?? this.sortMode,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      remotePlaylistId: data.remotePlaylistId.present
          ? data.remotePlaylistId.value
          : this.remotePlaylistId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      kind: data.kind.present ? data.kind.value : this.kind,
      totalTracks: data.totalTracks.present
          ? data.totalTracks.value
          : this.totalTracks,
      canEdit: data.canEdit.present ? data.canEdit.value : this.canEdit,
      sortMode: data.sortMode.present ? data.sortMode.value : this.sortMode,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('remotePlaylistId: $remotePlaylistId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('kind: $kind, ')
          ..write('totalTracks: $totalTracks, ')
          ..write('canEdit: $canEdit, ')
          ..write('sortMode: $sortMode, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    remotePlaylistId,
    title,
    description,
    coverUrl,
    ownerUid,
    kind,
    totalTracks,
    canEdit,
    sortMode,
    lastSyncedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.source == this.source &&
          other.remotePlaylistId == this.remotePlaylistId &&
          other.title == this.title &&
          other.description == this.description &&
          other.coverUrl == this.coverUrl &&
          other.ownerUid == this.ownerUid &&
          other.kind == this.kind &&
          other.totalTracks == this.totalTracks &&
          other.canEdit == this.canEdit &&
          other.sortMode == this.sortMode &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<String> id;
  final Value<String> source;
  final Value<String?> remotePlaylistId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> coverUrl;
  final Value<String?> ownerUid;
  final Value<String> kind;
  final Value<int?> totalTracks;
  final Value<bool> canEdit;
  final Value<String> sortMode;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.remotePlaylistId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.kind = const Value.absent(),
    this.totalTracks = const Value.absent(),
    this.canEdit = const Value.absent(),
    this.sortMode = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    this.source = const Value.absent(),
    this.remotePlaylistId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.kind = const Value.absent(),
    this.totalTracks = const Value.absent(),
    this.canEdit = const Value.absent(),
    this.sortMode = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<Playlist> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? remotePlaylistId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? coverUrl,
    Expression<String>? ownerUid,
    Expression<String>? kind,
    Expression<int>? totalTracks,
    Expression<bool>? canEdit,
    Expression<String>? sortMode,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (remotePlaylistId != null) 'remote_playlist_id': remotePlaylistId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (kind != null) 'kind': kind,
      if (totalTracks != null) 'total_tracks': totalTracks,
      if (canEdit != null) 'can_edit': canEdit,
      if (sortMode != null) 'sort_mode': sortMode,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<String?>? remotePlaylistId,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? coverUrl,
    Value<String?>? ownerUid,
    Value<String>? kind,
    Value<int?>? totalTracks,
    Value<bool>? canEdit,
    Value<String>? sortMode,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      remotePlaylistId: remotePlaylistId ?? this.remotePlaylistId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      ownerUid: ownerUid ?? this.ownerUid,
      kind: kind ?? this.kind,
      totalTracks: totalTracks ?? this.totalTracks,
      canEdit: canEdit ?? this.canEdit,
      sortMode: sortMode ?? this.sortMode,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (remotePlaylistId.present) {
      map['remote_playlist_id'] = Variable<String>(remotePlaylistId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (totalTracks.present) {
      map['total_tracks'] = Variable<int>(totalTracks.value);
    }
    if (canEdit.present) {
      map['can_edit'] = Variable<bool>(canEdit.value);
    }
    if (sortMode.present) {
      map['sort_mode'] = Variable<String>(sortMode.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('remotePlaylistId: $remotePlaylistId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('kind: $kind, ')
          ..write('totalTracks: $totalTracks, ')
          ..write('canEdit: $canEdit, ')
          ..write('sortMode: $sortMode, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTracksTable extends PlaylistTracks
    with TableInfo<$PlaylistTracksTable, PlaylistTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    localTrackId,
    position,
    sourceId,
    remoteId,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, position};
  @override
  PlaylistTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistTrack(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $PlaylistTracksTable createAlias(String alias) {
    return $PlaylistTracksTable(attachedDatabase, alias);
  }
}

class PlaylistTrack extends DataClass implements Insertable<PlaylistTrack> {
  final String playlistId;
  final String localTrackId;
  final int position;

  /// Откуда именно добавили: тот же локальный трек мог прийти из двух каталогов.
  final String sourceId;
  final String remoteId;
  final DateTime addedAt;
  const PlaylistTrack({
    required this.playlistId,
    required this.localTrackId,
    required this.position,
    required this.sourceId,
    required this.remoteId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['local_track_id'] = Variable<String>(localTrackId);
    map['position'] = Variable<int>(position);
    map['source_id'] = Variable<String>(sourceId);
    map['remote_id'] = Variable<String>(remoteId);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  PlaylistTracksCompanion toCompanion(bool nullToAbsent) {
    return PlaylistTracksCompanion(
      playlistId: Value(playlistId),
      localTrackId: Value(localTrackId),
      position: Value(position),
      sourceId: Value(sourceId),
      remoteId: Value(remoteId),
      addedAt: Value(addedAt),
    );
  }

  factory PlaylistTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistTrack(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      position: serializer.fromJson<int>(json['position']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'localTrackId': serializer.toJson<String>(localTrackId),
      'position': serializer.toJson<int>(position),
      'sourceId': serializer.toJson<String>(sourceId),
      'remoteId': serializer.toJson<String>(remoteId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  PlaylistTrack copyWith({
    String? playlistId,
    String? localTrackId,
    int? position,
    String? sourceId,
    String? remoteId,
    DateTime? addedAt,
  }) => PlaylistTrack(
    playlistId: playlistId ?? this.playlistId,
    localTrackId: localTrackId ?? this.localTrackId,
    position: position ?? this.position,
    sourceId: sourceId ?? this.sourceId,
    remoteId: remoteId ?? this.remoteId,
    addedAt: addedAt ?? this.addedAt,
  );
  PlaylistTrack copyWithCompanion(PlaylistTracksCompanion data) {
    return PlaylistTrack(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      position: data.position.present ? data.position.value : this.position,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTrack(')
          ..write('playlistId: $playlistId, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('position: $position, ')
          ..write('sourceId: $sourceId, ')
          ..write('remoteId: $remoteId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    playlistId,
    localTrackId,
    position,
    sourceId,
    remoteId,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistTrack &&
          other.playlistId == this.playlistId &&
          other.localTrackId == this.localTrackId &&
          other.position == this.position &&
          other.sourceId == this.sourceId &&
          other.remoteId == this.remoteId &&
          other.addedAt == this.addedAt);
}

class PlaylistTracksCompanion extends UpdateCompanion<PlaylistTrack> {
  final Value<String> playlistId;
  final Value<String> localTrackId;
  final Value<int> position;
  final Value<String> sourceId;
  final Value<String> remoteId;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const PlaylistTracksCompanion({
    this.playlistId = const Value.absent(),
    this.localTrackId = const Value.absent(),
    this.position = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistTracksCompanion.insert({
    required String playlistId,
    required String localTrackId,
    this.position = const Value.absent(),
    required String sourceId,
    required String remoteId,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       localTrackId = Value(localTrackId),
       sourceId = Value(sourceId),
       remoteId = Value(remoteId);
  static Insertable<PlaylistTrack> custom({
    Expression<String>? playlistId,
    Expression<String>? localTrackId,
    Expression<int>? position,
    Expression<String>? sourceId,
    Expression<String>? remoteId,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (position != null) 'position': position,
      if (sourceId != null) 'source_id': sourceId,
      if (remoteId != null) 'remote_id': remoteId,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistTracksCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? localTrackId,
    Value<int>? position,
    Value<String>? sourceId,
    Value<String>? remoteId,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return PlaylistTracksCompanion(
      playlistId: playlistId ?? this.playlistId,
      localTrackId: localTrackId ?? this.localTrackId,
      position: position ?? this.position,
      sourceId: sourceId ?? this.sourceId,
      remoteId: remoteId ?? this.remoteId,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistTracksCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('position: $position, ')
          ..write('sourceId: $sourceId, ')
          ..write('remoteId: $remoteId, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LikesTable extends Likes with TableInfo<$LikesTable, Like> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _likedAtMeta = const VerificationMeta(
    'likedAt',
  );
  @override
  late final GeneratedColumn<DateTime> likedAt = GeneratedColumn<DateTime>(
    'liked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedToRemoteMeta = const VerificationMeta(
    'syncedToRemote',
  );
  @override
  late final GeneratedColumn<bool> syncedToRemote = GeneratedColumn<bool>(
    'synced_to_remote',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced_to_remote" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remoteSourceMeta = const VerificationMeta(
    'remoteSource',
  );
  @override
  late final GeneratedColumn<String> remoteSource = GeneratedColumn<String>(
    'remote_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingOpMeta = const VerificationMeta(
    'pendingOp',
  );
  @override
  late final GeneratedColumn<int> pendingOp = GeneratedColumn<int>(
    'pending_op',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localTrackId,
    state,
    likedAt,
    syncedToRemote,
    remoteSource,
    pendingOp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'likes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Like> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('liked_at')) {
      context.handle(
        _likedAtMeta,
        likedAt.isAcceptableOrUnknown(data['liked_at']!, _likedAtMeta),
      );
    }
    if (data.containsKey('synced_to_remote')) {
      context.handle(
        _syncedToRemoteMeta,
        syncedToRemote.isAcceptableOrUnknown(
          data['synced_to_remote']!,
          _syncedToRemoteMeta,
        ),
      );
    }
    if (data.containsKey('remote_source')) {
      context.handle(
        _remoteSourceMeta,
        remoteSource.isAcceptableOrUnknown(
          data['remote_source']!,
          _remoteSourceMeta,
        ),
      );
    }
    if (data.containsKey('pending_op')) {
      context.handle(
        _pendingOpMeta,
        pendingOp.isAcceptableOrUnknown(data['pending_op']!, _pendingOpMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTrackId};
  @override
  Like map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Like(
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state'],
      )!,
      likedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}liked_at'],
      )!,
      syncedToRemote: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced_to_remote'],
      )!,
      remoteSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_source'],
      ),
      pendingOp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_op'],
      ),
    );
  }

  @override
  $LikesTable createAlias(String alias) {
    return $LikesTable(attachedDatabase, alias);
  }
}

class Like extends DataClass implements Insertable<Like> {
  final String localTrackId;

  /// -1 дизлайк, 0 снято, 1 лайк.
  final int state;
  final DateTime likedAt;

  /// Лайк живёт локально до тех пор, пока не синхронизирован в каталог.
  final bool syncedToRemote;
  final String? remoteSource;

  /// 1 = поставить, -1 = снять; null = ничего не ждём.
  final int? pendingOp;
  const Like({
    required this.localTrackId,
    required this.state,
    required this.likedAt,
    required this.syncedToRemote,
    this.remoteSource,
    this.pendingOp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_track_id'] = Variable<String>(localTrackId);
    map['state'] = Variable<int>(state);
    map['liked_at'] = Variable<DateTime>(likedAt);
    map['synced_to_remote'] = Variable<bool>(syncedToRemote);
    if (!nullToAbsent || remoteSource != null) {
      map['remote_source'] = Variable<String>(remoteSource);
    }
    if (!nullToAbsent || pendingOp != null) {
      map['pending_op'] = Variable<int>(pendingOp);
    }
    return map;
  }

  LikesCompanion toCompanion(bool nullToAbsent) {
    return LikesCompanion(
      localTrackId: Value(localTrackId),
      state: Value(state),
      likedAt: Value(likedAt),
      syncedToRemote: Value(syncedToRemote),
      remoteSource: remoteSource == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSource),
      pendingOp: pendingOp == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingOp),
    );
  }

  factory Like.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Like(
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      state: serializer.fromJson<int>(json['state']),
      likedAt: serializer.fromJson<DateTime>(json['likedAt']),
      syncedToRemote: serializer.fromJson<bool>(json['syncedToRemote']),
      remoteSource: serializer.fromJson<String?>(json['remoteSource']),
      pendingOp: serializer.fromJson<int?>(json['pendingOp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTrackId': serializer.toJson<String>(localTrackId),
      'state': serializer.toJson<int>(state),
      'likedAt': serializer.toJson<DateTime>(likedAt),
      'syncedToRemote': serializer.toJson<bool>(syncedToRemote),
      'remoteSource': serializer.toJson<String?>(remoteSource),
      'pendingOp': serializer.toJson<int?>(pendingOp),
    };
  }

  Like copyWith({
    String? localTrackId,
    int? state,
    DateTime? likedAt,
    bool? syncedToRemote,
    Value<String?> remoteSource = const Value.absent(),
    Value<int?> pendingOp = const Value.absent(),
  }) => Like(
    localTrackId: localTrackId ?? this.localTrackId,
    state: state ?? this.state,
    likedAt: likedAt ?? this.likedAt,
    syncedToRemote: syncedToRemote ?? this.syncedToRemote,
    remoteSource: remoteSource.present ? remoteSource.value : this.remoteSource,
    pendingOp: pendingOp.present ? pendingOp.value : this.pendingOp,
  );
  Like copyWithCompanion(LikesCompanion data) {
    return Like(
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      state: data.state.present ? data.state.value : this.state,
      likedAt: data.likedAt.present ? data.likedAt.value : this.likedAt,
      syncedToRemote: data.syncedToRemote.present
          ? data.syncedToRemote.value
          : this.syncedToRemote,
      remoteSource: data.remoteSource.present
          ? data.remoteSource.value
          : this.remoteSource,
      pendingOp: data.pendingOp.present ? data.pendingOp.value : this.pendingOp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Like(')
          ..write('localTrackId: $localTrackId, ')
          ..write('state: $state, ')
          ..write('likedAt: $likedAt, ')
          ..write('syncedToRemote: $syncedToRemote, ')
          ..write('remoteSource: $remoteSource, ')
          ..write('pendingOp: $pendingOp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localTrackId,
    state,
    likedAt,
    syncedToRemote,
    remoteSource,
    pendingOp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Like &&
          other.localTrackId == this.localTrackId &&
          other.state == this.state &&
          other.likedAt == this.likedAt &&
          other.syncedToRemote == this.syncedToRemote &&
          other.remoteSource == this.remoteSource &&
          other.pendingOp == this.pendingOp);
}

class LikesCompanion extends UpdateCompanion<Like> {
  final Value<String> localTrackId;
  final Value<int> state;
  final Value<DateTime> likedAt;
  final Value<bool> syncedToRemote;
  final Value<String?> remoteSource;
  final Value<int?> pendingOp;
  final Value<int> rowid;
  const LikesCompanion({
    this.localTrackId = const Value.absent(),
    this.state = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.syncedToRemote = const Value.absent(),
    this.remoteSource = const Value.absent(),
    this.pendingOp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LikesCompanion.insert({
    required String localTrackId,
    this.state = const Value.absent(),
    this.likedAt = const Value.absent(),
    this.syncedToRemote = const Value.absent(),
    this.remoteSource = const Value.absent(),
    this.pendingOp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localTrackId = Value(localTrackId);
  static Insertable<Like> custom({
    Expression<String>? localTrackId,
    Expression<int>? state,
    Expression<DateTime>? likedAt,
    Expression<bool>? syncedToRemote,
    Expression<String>? remoteSource,
    Expression<int>? pendingOp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (state != null) 'state': state,
      if (likedAt != null) 'liked_at': likedAt,
      if (syncedToRemote != null) 'synced_to_remote': syncedToRemote,
      if (remoteSource != null) 'remote_source': remoteSource,
      if (pendingOp != null) 'pending_op': pendingOp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LikesCompanion copyWith({
    Value<String>? localTrackId,
    Value<int>? state,
    Value<DateTime>? likedAt,
    Value<bool>? syncedToRemote,
    Value<String?>? remoteSource,
    Value<int?>? pendingOp,
    Value<int>? rowid,
  }) {
    return LikesCompanion(
      localTrackId: localTrackId ?? this.localTrackId,
      state: state ?? this.state,
      likedAt: likedAt ?? this.likedAt,
      syncedToRemote: syncedToRemote ?? this.syncedToRemote,
      remoteSource: remoteSource ?? this.remoteSource,
      pendingOp: pendingOp ?? this.pendingOp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (likedAt.present) {
      map['liked_at'] = Variable<DateTime>(likedAt.value);
    }
    if (syncedToRemote.present) {
      map['synced_to_remote'] = Variable<bool>(syncedToRemote.value);
    }
    if (remoteSource.present) {
      map['remote_source'] = Variable<String>(remoteSource.value);
    }
    if (pendingOp.present) {
      map['pending_op'] = Variable<int>(pendingOp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LikesCompanion(')
          ..write('localTrackId: $localTrackId, ')
          ..write('state: $state, ')
          ..write('likedAt: $likedAt, ')
          ..write('syncedToRemote: $syncedToRemote, ')
          ..write('remoteSource: $remoteSource, ')
          ..write('pendingOp: $pendingOp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryTable extends History with TableInfo<$HistoryTable, HistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _playedMsMeta = const VerificationMeta(
    'playedMs',
  );
  @override
  late final GeneratedColumn<int> playedMs = GeneratedColumn<int>(
    'played_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _skipReasonMeta = const VerificationMeta(
    'skipReason',
  );
  @override
  late final GeneratedColumn<String> skipReason = GeneratedColumn<String>(
    'skip_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceMeta = const VerificationMeta('device');
  @override
  late final GeneratedColumn<String> device = GeneratedColumn<String>(
    'device',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventJsonMeta = const VerificationMeta(
    'eventJson',
  );
  @override
  late final GeneratedColumn<String> eventJson = GeneratedColumn<String>(
    'event_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localTrackId,
    playedAt,
    playedMs,
    completed,
    source,
    quality,
    skipReason,
    device,
    eventJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('played_ms')) {
      context.handle(
        _playedMsMeta,
        playedMs.isAcceptableOrUnknown(data['played_ms']!, _playedMsMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('skip_reason')) {
      context.handle(
        _skipReasonMeta,
        skipReason.isAcceptableOrUnknown(data['skip_reason']!, _skipReasonMeta),
      );
    }
    if (data.containsKey('device')) {
      context.handle(
        _deviceMeta,
        device.isAcceptableOrUnknown(data['device']!, _deviceMeta),
      );
    }
    if (data.containsKey('event_json')) {
      context.handle(
        _eventJsonMeta,
        eventJson.isAcceptableOrUnknown(data['event_json']!, _eventJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      playedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}played_ms'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      )!,
      skipReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_reason'],
      ),
      device: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device'],
      ),
      eventJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_json'],
      ),
    );
  }

  @override
  $HistoryTable createAlias(String alias) {
    return $HistoryTable(attachedDatabase, alias);
  }
}

class HistoryData extends DataClass implements Insertable<HistoryData> {
  final int id;
  final String localTrackId;
  final DateTime playedAt;

  /// Сколько реально прослушано — нужно для rotor feedback и вытеснения офлайна.
  final int playedMs;
  final bool completed;
  final String source;
  final String quality;

  /// Причина пропуска, если трек закончился не сам.
  final String? skipReason;
  final String? device;

  /// Сырое событие источника, чтобы досылать feedback без повторных запросов.
  final String? eventJson;
  const HistoryData({
    required this.id,
    required this.localTrackId,
    required this.playedAt,
    required this.playedMs,
    required this.completed,
    required this.source,
    required this.quality,
    this.skipReason,
    this.device,
    this.eventJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_track_id'] = Variable<String>(localTrackId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['played_ms'] = Variable<int>(playedMs);
    map['completed'] = Variable<bool>(completed);
    map['source'] = Variable<String>(source);
    map['quality'] = Variable<String>(quality);
    if (!nullToAbsent || skipReason != null) {
      map['skip_reason'] = Variable<String>(skipReason);
    }
    if (!nullToAbsent || device != null) {
      map['device'] = Variable<String>(device);
    }
    if (!nullToAbsent || eventJson != null) {
      map['event_json'] = Variable<String>(eventJson);
    }
    return map;
  }

  HistoryCompanion toCompanion(bool nullToAbsent) {
    return HistoryCompanion(
      id: Value(id),
      localTrackId: Value(localTrackId),
      playedAt: Value(playedAt),
      playedMs: Value(playedMs),
      completed: Value(completed),
      source: Value(source),
      quality: Value(quality),
      skipReason: skipReason == null && nullToAbsent
          ? const Value.absent()
          : Value(skipReason),
      device: device == null && nullToAbsent
          ? const Value.absent()
          : Value(device),
      eventJson: eventJson == null && nullToAbsent
          ? const Value.absent()
          : Value(eventJson),
    );
  }

  factory HistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryData(
      id: serializer.fromJson<int>(json['id']),
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      playedMs: serializer.fromJson<int>(json['playedMs']),
      completed: serializer.fromJson<bool>(json['completed']),
      source: serializer.fromJson<String>(json['source']),
      quality: serializer.fromJson<String>(json['quality']),
      skipReason: serializer.fromJson<String?>(json['skipReason']),
      device: serializer.fromJson<String?>(json['device']),
      eventJson: serializer.fromJson<String?>(json['eventJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localTrackId': serializer.toJson<String>(localTrackId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'playedMs': serializer.toJson<int>(playedMs),
      'completed': serializer.toJson<bool>(completed),
      'source': serializer.toJson<String>(source),
      'quality': serializer.toJson<String>(quality),
      'skipReason': serializer.toJson<String?>(skipReason),
      'device': serializer.toJson<String?>(device),
      'eventJson': serializer.toJson<String?>(eventJson),
    };
  }

  HistoryData copyWith({
    int? id,
    String? localTrackId,
    DateTime? playedAt,
    int? playedMs,
    bool? completed,
    String? source,
    String? quality,
    Value<String?> skipReason = const Value.absent(),
    Value<String?> device = const Value.absent(),
    Value<String?> eventJson = const Value.absent(),
  }) => HistoryData(
    id: id ?? this.id,
    localTrackId: localTrackId ?? this.localTrackId,
    playedAt: playedAt ?? this.playedAt,
    playedMs: playedMs ?? this.playedMs,
    completed: completed ?? this.completed,
    source: source ?? this.source,
    quality: quality ?? this.quality,
    skipReason: skipReason.present ? skipReason.value : this.skipReason,
    device: device.present ? device.value : this.device,
    eventJson: eventJson.present ? eventJson.value : this.eventJson,
  );
  HistoryData copyWithCompanion(HistoryCompanion data) {
    return HistoryData(
      id: data.id.present ? data.id.value : this.id,
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      playedMs: data.playedMs.present ? data.playedMs.value : this.playedMs,
      completed: data.completed.present ? data.completed.value : this.completed,
      source: data.source.present ? data.source.value : this.source,
      quality: data.quality.present ? data.quality.value : this.quality,
      skipReason: data.skipReason.present
          ? data.skipReason.value
          : this.skipReason,
      device: data.device.present ? data.device.value : this.device,
      eventJson: data.eventJson.present ? data.eventJson.value : this.eventJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryData(')
          ..write('id: $id, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('playedAt: $playedAt, ')
          ..write('playedMs: $playedMs, ')
          ..write('completed: $completed, ')
          ..write('source: $source, ')
          ..write('quality: $quality, ')
          ..write('skipReason: $skipReason, ')
          ..write('device: $device, ')
          ..write('eventJson: $eventJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localTrackId,
    playedAt,
    playedMs,
    completed,
    source,
    quality,
    skipReason,
    device,
    eventJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryData &&
          other.id == this.id &&
          other.localTrackId == this.localTrackId &&
          other.playedAt == this.playedAt &&
          other.playedMs == this.playedMs &&
          other.completed == this.completed &&
          other.source == this.source &&
          other.quality == this.quality &&
          other.skipReason == this.skipReason &&
          other.device == this.device &&
          other.eventJson == this.eventJson);
}

class HistoryCompanion extends UpdateCompanion<HistoryData> {
  final Value<int> id;
  final Value<String> localTrackId;
  final Value<DateTime> playedAt;
  final Value<int> playedMs;
  final Value<bool> completed;
  final Value<String> source;
  final Value<String> quality;
  final Value<String?> skipReason;
  final Value<String?> device;
  final Value<String?> eventJson;
  const HistoryCompanion({
    this.id = const Value.absent(),
    this.localTrackId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.playedMs = const Value.absent(),
    this.completed = const Value.absent(),
    this.source = const Value.absent(),
    this.quality = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.device = const Value.absent(),
    this.eventJson = const Value.absent(),
  });
  HistoryCompanion.insert({
    this.id = const Value.absent(),
    required String localTrackId,
    this.playedAt = const Value.absent(),
    this.playedMs = const Value.absent(),
    this.completed = const Value.absent(),
    required String source,
    this.quality = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.device = const Value.absent(),
    this.eventJson = const Value.absent(),
  }) : localTrackId = Value(localTrackId),
       source = Value(source);
  static Insertable<HistoryData> custom({
    Expression<int>? id,
    Expression<String>? localTrackId,
    Expression<DateTime>? playedAt,
    Expression<int>? playedMs,
    Expression<bool>? completed,
    Expression<String>? source,
    Expression<String>? quality,
    Expression<String>? skipReason,
    Expression<String>? device,
    Expression<String>? eventJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (playedAt != null) 'played_at': playedAt,
      if (playedMs != null) 'played_ms': playedMs,
      if (completed != null) 'completed': completed,
      if (source != null) 'source': source,
      if (quality != null) 'quality': quality,
      if (skipReason != null) 'skip_reason': skipReason,
      if (device != null) 'device': device,
      if (eventJson != null) 'event_json': eventJson,
    });
  }

  HistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? localTrackId,
    Value<DateTime>? playedAt,
    Value<int>? playedMs,
    Value<bool>? completed,
    Value<String>? source,
    Value<String>? quality,
    Value<String?>? skipReason,
    Value<String?>? device,
    Value<String?>? eventJson,
  }) {
    return HistoryCompanion(
      id: id ?? this.id,
      localTrackId: localTrackId ?? this.localTrackId,
      playedAt: playedAt ?? this.playedAt,
      playedMs: playedMs ?? this.playedMs,
      completed: completed ?? this.completed,
      source: source ?? this.source,
      quality: quality ?? this.quality,
      skipReason: skipReason ?? this.skipReason,
      device: device ?? this.device,
      eventJson: eventJson ?? this.eventJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (playedMs.present) {
      map['played_ms'] = Variable<int>(playedMs.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (skipReason.present) {
      map['skip_reason'] = Variable<String>(skipReason.value);
    }
    if (device.present) {
      map['device'] = Variable<String>(device.value);
    }
    if (eventJson.present) {
      map['event_json'] = Variable<String>(eventJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryCompanion(')
          ..write('id: $id, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('playedAt: $playedAt, ')
          ..write('playedMs: $playedMs, ')
          ..write('completed: $completed, ')
          ..write('source: $source, ')
          ..write('quality: $quality, ')
          ..write('skipReason: $skipReason, ')
          ..write('device: $device, ')
          ..write('eventJson: $eventJson')
          ..write(')'))
        .toString();
  }
}

class $QueueSnapshotsTable extends QueueSnapshots
    with TableInfo<$QueueSnapshotsTable, QueueSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queueIndexMeta = const VerificationMeta(
    'queueIndex',
  );
  @override
  late final GeneratedColumn<int> queueIndex = GeneratedColumn<int>(
    'queue_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatModeMeta = const VerificationMeta(
    'repeatMode',
  );
  @override
  late final GeneratedColumn<String> repeatMode = GeneratedColumn<String>(
    'repeat_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  static const VerificationMeta _shuffleEnabledMeta = const VerificationMeta(
    'shuffleEnabled',
  );
  @override
  late final GeneratedColumn<bool> shuffleEnabled = GeneratedColumn<bool>(
    'shuffle_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceHintJsonMeta = const VerificationMeta(
    'sourceHintJson',
  );
  @override
  late final GeneratedColumn<String> sourceHintJson = GeneratedColumn<String>(
    'source_hint_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    itemsJson,
    queueIndex,
    positionMs,
    repeatMode,
    shuffleEnabled,
    sourceHintJson,
    savedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('queue_index')) {
      context.handle(
        _queueIndexMeta,
        queueIndex.isAcceptableOrUnknown(data['queue_index']!, _queueIndexMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('repeat_mode')) {
      context.handle(
        _repeatModeMeta,
        repeatMode.isAcceptableOrUnknown(data['repeat_mode']!, _repeatModeMeta),
      );
    }
    if (data.containsKey('shuffle_enabled')) {
      context.handle(
        _shuffleEnabledMeta,
        shuffleEnabled.isAcceptableOrUnknown(
          data['shuffle_enabled']!,
          _shuffleEnabledMeta,
        ),
      );
    }
    if (data.containsKey('source_hint_json')) {
      context.handle(
        _sourceHintJsonMeta,
        sourceHintJson.isAcceptableOrUnknown(
          data['source_hint_json']!,
          _sourceHintJsonMeta,
        ),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      queueIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      repeatMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_mode'],
      )!,
      shuffleEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_enabled'],
      )!,
      sourceHintJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hint_json'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $QueueSnapshotsTable createAlias(String alias) {
    return $QueueSnapshotsTable(attachedDatabase, alias);
  }
}

class QueueSnapshot extends DataClass implements Insertable<QueueSnapshot> {
  final int id;

  /// player | radio
  final String kind;

  /// Список localTrackId в порядке очереди.
  final String itemsJson;
  final int queueIndex;
  final int positionMs;

  /// off | all | one — значения совпадают с AudioService.repeatMode.
  final String repeatMode;
  final bool shuffleEnabled;

  /// Откуда очередь пришла (плейлист, волна, поиск) — нужно для дозаполнения
  /// «Моей волны» после смерти процесса.
  final String? sourceHintJson;
  final DateTime savedAt;
  const QueueSnapshot({
    required this.id,
    required this.kind,
    required this.itemsJson,
    required this.queueIndex,
    required this.positionMs,
    required this.repeatMode,
    required this.shuffleEnabled,
    this.sourceHintJson,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['items_json'] = Variable<String>(itemsJson);
    map['queue_index'] = Variable<int>(queueIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['repeat_mode'] = Variable<String>(repeatMode);
    map['shuffle_enabled'] = Variable<bool>(shuffleEnabled);
    if (!nullToAbsent || sourceHintJson != null) {
      map['source_hint_json'] = Variable<String>(sourceHintJson);
    }
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  QueueSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return QueueSnapshotsCompanion(
      id: Value(id),
      kind: Value(kind),
      itemsJson: Value(itemsJson),
      queueIndex: Value(queueIndex),
      positionMs: Value(positionMs),
      repeatMode: Value(repeatMode),
      shuffleEnabled: Value(shuffleEnabled),
      sourceHintJson: sourceHintJson == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHintJson),
      savedAt: Value(savedAt),
    );
  }

  factory QueueSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueSnapshot(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      queueIndex: serializer.fromJson<int>(json['queueIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      repeatMode: serializer.fromJson<String>(json['repeatMode']),
      shuffleEnabled: serializer.fromJson<bool>(json['shuffleEnabled']),
      sourceHintJson: serializer.fromJson<String?>(json['sourceHintJson']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'queueIndex': serializer.toJson<int>(queueIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'repeatMode': serializer.toJson<String>(repeatMode),
      'shuffleEnabled': serializer.toJson<bool>(shuffleEnabled),
      'sourceHintJson': serializer.toJson<String?>(sourceHintJson),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  QueueSnapshot copyWith({
    int? id,
    String? kind,
    String? itemsJson,
    int? queueIndex,
    int? positionMs,
    String? repeatMode,
    bool? shuffleEnabled,
    Value<String?> sourceHintJson = const Value.absent(),
    DateTime? savedAt,
  }) => QueueSnapshot(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    itemsJson: itemsJson ?? this.itemsJson,
    queueIndex: queueIndex ?? this.queueIndex,
    positionMs: positionMs ?? this.positionMs,
    repeatMode: repeatMode ?? this.repeatMode,
    shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
    sourceHintJson: sourceHintJson.present
        ? sourceHintJson.value
        : this.sourceHintJson,
    savedAt: savedAt ?? this.savedAt,
  );
  QueueSnapshot copyWithCompanion(QueueSnapshotsCompanion data) {
    return QueueSnapshot(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      queueIndex: data.queueIndex.present
          ? data.queueIndex.value
          : this.queueIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      repeatMode: data.repeatMode.present
          ? data.repeatMode.value
          : this.repeatMode,
      shuffleEnabled: data.shuffleEnabled.present
          ? data.shuffleEnabled.value
          : this.shuffleEnabled,
      sourceHintJson: data.sourceHintJson.present
          ? data.sourceHintJson.value
          : this.sourceHintJson,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueSnapshot(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('queueIndex: $queueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('sourceHintJson: $sourceHintJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    itemsJson,
    queueIndex,
    positionMs,
    repeatMode,
    shuffleEnabled,
    sourceHintJson,
    savedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueSnapshot &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.itemsJson == this.itemsJson &&
          other.queueIndex == this.queueIndex &&
          other.positionMs == this.positionMs &&
          other.repeatMode == this.repeatMode &&
          other.shuffleEnabled == this.shuffleEnabled &&
          other.sourceHintJson == this.sourceHintJson &&
          other.savedAt == this.savedAt);
}

class QueueSnapshotsCompanion extends UpdateCompanion<QueueSnapshot> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> itemsJson;
  final Value<int> queueIndex;
  final Value<int> positionMs;
  final Value<String> repeatMode;
  final Value<bool> shuffleEnabled;
  final Value<String?> sourceHintJson;
  final Value<DateTime> savedAt;
  const QueueSnapshotsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.queueIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.sourceHintJson = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  QueueSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String itemsJson,
    this.queueIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.repeatMode = const Value.absent(),
    this.shuffleEnabled = const Value.absent(),
    this.sourceHintJson = const Value.absent(),
    this.savedAt = const Value.absent(),
  }) : kind = Value(kind),
       itemsJson = Value(itemsJson);
  static Insertable<QueueSnapshot> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? itemsJson,
    Expression<int>? queueIndex,
    Expression<int>? positionMs,
    Expression<String>? repeatMode,
    Expression<bool>? shuffleEnabled,
    Expression<String>? sourceHintJson,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (itemsJson != null) 'items_json': itemsJson,
      if (queueIndex != null) 'queue_index': queueIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (repeatMode != null) 'repeat_mode': repeatMode,
      if (shuffleEnabled != null) 'shuffle_enabled': shuffleEnabled,
      if (sourceHintJson != null) 'source_hint_json': sourceHintJson,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  QueueSnapshotsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? itemsJson,
    Value<int>? queueIndex,
    Value<int>? positionMs,
    Value<String>? repeatMode,
    Value<bool>? shuffleEnabled,
    Value<String?>? sourceHintJson,
    Value<DateTime>? savedAt,
  }) {
    return QueueSnapshotsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      itemsJson: itemsJson ?? this.itemsJson,
      queueIndex: queueIndex ?? this.queueIndex,
      positionMs: positionMs ?? this.positionMs,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      sourceHintJson: sourceHintJson ?? this.sourceHintJson,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (queueIndex.present) {
      map['queue_index'] = Variable<int>(queueIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (repeatMode.present) {
      map['repeat_mode'] = Variable<String>(repeatMode.value);
    }
    if (shuffleEnabled.present) {
      map['shuffle_enabled'] = Variable<bool>(shuffleEnabled.value);
    }
    if (sourceHintJson.present) {
      map['source_hint_json'] = Variable<String>(sourceHintJson.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('queueIndex: $queueIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('repeatMode: $repeatMode, ')
          ..write('shuffleEnabled: $shuffleEnabled, ')
          ..write('sourceHintJson: $sourceHintJson, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $StreamResolutionsTable extends StreamResolutions
    with TableInfo<$StreamResolutionsTable, StreamResolution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreamResolutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headersJsonMeta = const VerificationMeta(
    'headersJson',
  );
  @override
  late final GeneratedColumn<String> headersJson = GeneratedColumn<String>(
    'headers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _codecMeta = const VerificationMeta('codec');
  @override
  late final GeneratedColumn<String> codec = GeneratedColumn<String>(
    'codec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitrateKbpsMeta = const VerificationMeta(
    'bitrateKbps',
  );
  @override
  late final GeneratedColumn<int> bitrateKbps = GeneratedColumn<int>(
    'bitrate_kbps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetKindMeta = const VerificationMeta(
    'targetKind',
  );
  @override
  late final GeneratedColumn<String> targetKind = GeneratedColumn<String>(
    'target_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('url'),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localTrackId,
    source,
    quality,
    url,
    headersJson,
    codec,
    bitrateKbps,
    targetKind,
    filePath,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stream_resolutions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreamResolution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    } else if (isInserting) {
      context.missing(_qualityMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('headers_json')) {
      context.handle(
        _headersJsonMeta,
        headersJson.isAcceptableOrUnknown(
          data['headers_json']!,
          _headersJsonMeta,
        ),
      );
    }
    if (data.containsKey('codec')) {
      context.handle(
        _codecMeta,
        codec.isAcceptableOrUnknown(data['codec']!, _codecMeta),
      );
    }
    if (data.containsKey('bitrate_kbps')) {
      context.handle(
        _bitrateKbpsMeta,
        bitrateKbps.isAcceptableOrUnknown(
          data['bitrate_kbps']!,
          _bitrateKbpsMeta,
        ),
      );
    }
    if (data.containsKey('target_kind')) {
      context.handle(
        _targetKindMeta,
        targetKind.isAcceptableOrUnknown(data['target_kind']!, _targetKindMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTrackId, source, quality};
  @override
  StreamResolution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreamResolution(
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      headersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headers_json'],
      )!,
      codec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codec'],
      ),
      bitrateKbps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitrate_kbps'],
      ),
      targetKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_kind'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $StreamResolutionsTable createAlias(String alias) {
    return $StreamResolutionsTable(attachedDatabase, alias);
  }
}

class StreamResolution extends DataClass
    implements Insertable<StreamResolution> {
  final String localTrackId;
  final String source;
  final String quality;

  /// Заголовки храним отдельно: их нельзя вшивать в URL.
  final String url;
  final String headersJson;
  final String? codec;
  final int? bitrateKbps;

  /// url | file
  final String targetKind;
  final String? filePath;
  final DateTime createdAt;
  final DateTime expiresAt;
  const StreamResolution({
    required this.localTrackId,
    required this.source,
    required this.quality,
    required this.url,
    required this.headersJson,
    this.codec,
    this.bitrateKbps,
    required this.targetKind,
    this.filePath,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_track_id'] = Variable<String>(localTrackId);
    map['source'] = Variable<String>(source);
    map['quality'] = Variable<String>(quality);
    map['url'] = Variable<String>(url);
    map['headers_json'] = Variable<String>(headersJson);
    if (!nullToAbsent || codec != null) {
      map['codec'] = Variable<String>(codec);
    }
    if (!nullToAbsent || bitrateKbps != null) {
      map['bitrate_kbps'] = Variable<int>(bitrateKbps);
    }
    map['target_kind'] = Variable<String>(targetKind);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  StreamResolutionsCompanion toCompanion(bool nullToAbsent) {
    return StreamResolutionsCompanion(
      localTrackId: Value(localTrackId),
      source: Value(source),
      quality: Value(quality),
      url: Value(url),
      headersJson: Value(headersJson),
      codec: codec == null && nullToAbsent
          ? const Value.absent()
          : Value(codec),
      bitrateKbps: bitrateKbps == null && nullToAbsent
          ? const Value.absent()
          : Value(bitrateKbps),
      targetKind: Value(targetKind),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory StreamResolution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreamResolution(
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      source: serializer.fromJson<String>(json['source']),
      quality: serializer.fromJson<String>(json['quality']),
      url: serializer.fromJson<String>(json['url']),
      headersJson: serializer.fromJson<String>(json['headersJson']),
      codec: serializer.fromJson<String?>(json['codec']),
      bitrateKbps: serializer.fromJson<int?>(json['bitrateKbps']),
      targetKind: serializer.fromJson<String>(json['targetKind']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTrackId': serializer.toJson<String>(localTrackId),
      'source': serializer.toJson<String>(source),
      'quality': serializer.toJson<String>(quality),
      'url': serializer.toJson<String>(url),
      'headersJson': serializer.toJson<String>(headersJson),
      'codec': serializer.toJson<String?>(codec),
      'bitrateKbps': serializer.toJson<int?>(bitrateKbps),
      'targetKind': serializer.toJson<String>(targetKind),
      'filePath': serializer.toJson<String?>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  StreamResolution copyWith({
    String? localTrackId,
    String? source,
    String? quality,
    String? url,
    String? headersJson,
    Value<String?> codec = const Value.absent(),
    Value<int?> bitrateKbps = const Value.absent(),
    String? targetKind,
    Value<String?> filePath = const Value.absent(),
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => StreamResolution(
    localTrackId: localTrackId ?? this.localTrackId,
    source: source ?? this.source,
    quality: quality ?? this.quality,
    url: url ?? this.url,
    headersJson: headersJson ?? this.headersJson,
    codec: codec.present ? codec.value : this.codec,
    bitrateKbps: bitrateKbps.present ? bitrateKbps.value : this.bitrateKbps,
    targetKind: targetKind ?? this.targetKind,
    filePath: filePath.present ? filePath.value : this.filePath,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  StreamResolution copyWithCompanion(StreamResolutionsCompanion data) {
    return StreamResolution(
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      source: data.source.present ? data.source.value : this.source,
      quality: data.quality.present ? data.quality.value : this.quality,
      url: data.url.present ? data.url.value : this.url,
      headersJson: data.headersJson.present
          ? data.headersJson.value
          : this.headersJson,
      codec: data.codec.present ? data.codec.value : this.codec,
      bitrateKbps: data.bitrateKbps.present
          ? data.bitrateKbps.value
          : this.bitrateKbps,
      targetKind: data.targetKind.present
          ? data.targetKind.value
          : this.targetKind,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreamResolution(')
          ..write('localTrackId: $localTrackId, ')
          ..write('source: $source, ')
          ..write('quality: $quality, ')
          ..write('url: $url, ')
          ..write('headersJson: $headersJson, ')
          ..write('codec: $codec, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('targetKind: $targetKind, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localTrackId,
    source,
    quality,
    url,
    headersJson,
    codec,
    bitrateKbps,
    targetKind,
    filePath,
    createdAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreamResolution &&
          other.localTrackId == this.localTrackId &&
          other.source == this.source &&
          other.quality == this.quality &&
          other.url == this.url &&
          other.headersJson == this.headersJson &&
          other.codec == this.codec &&
          other.bitrateKbps == this.bitrateKbps &&
          other.targetKind == this.targetKind &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class StreamResolutionsCompanion extends UpdateCompanion<StreamResolution> {
  final Value<String> localTrackId;
  final Value<String> source;
  final Value<String> quality;
  final Value<String> url;
  final Value<String> headersJson;
  final Value<String?> codec;
  final Value<int?> bitrateKbps;
  final Value<String> targetKind;
  final Value<String?> filePath;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const StreamResolutionsCompanion({
    this.localTrackId = const Value.absent(),
    this.source = const Value.absent(),
    this.quality = const Value.absent(),
    this.url = const Value.absent(),
    this.headersJson = const Value.absent(),
    this.codec = const Value.absent(),
    this.bitrateKbps = const Value.absent(),
    this.targetKind = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreamResolutionsCompanion.insert({
    required String localTrackId,
    required String source,
    required String quality,
    required String url,
    this.headersJson = const Value.absent(),
    this.codec = const Value.absent(),
    this.bitrateKbps = const Value.absent(),
    this.targetKind = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : localTrackId = Value(localTrackId),
       source = Value(source),
       quality = Value(quality),
       url = Value(url),
       expiresAt = Value(expiresAt);
  static Insertable<StreamResolution> custom({
    Expression<String>? localTrackId,
    Expression<String>? source,
    Expression<String>? quality,
    Expression<String>? url,
    Expression<String>? headersJson,
    Expression<String>? codec,
    Expression<int>? bitrateKbps,
    Expression<String>? targetKind,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (source != null) 'source': source,
      if (quality != null) 'quality': quality,
      if (url != null) 'url': url,
      if (headersJson != null) 'headers_json': headersJson,
      if (codec != null) 'codec': codec,
      if (bitrateKbps != null) 'bitrate_kbps': bitrateKbps,
      if (targetKind != null) 'target_kind': targetKind,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreamResolutionsCompanion copyWith({
    Value<String>? localTrackId,
    Value<String>? source,
    Value<String>? quality,
    Value<String>? url,
    Value<String>? headersJson,
    Value<String?>? codec,
    Value<int?>? bitrateKbps,
    Value<String>? targetKind,
    Value<String?>? filePath,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return StreamResolutionsCompanion(
      localTrackId: localTrackId ?? this.localTrackId,
      source: source ?? this.source,
      quality: quality ?? this.quality,
      url: url ?? this.url,
      headersJson: headersJson ?? this.headersJson,
      codec: codec ?? this.codec,
      bitrateKbps: bitrateKbps ?? this.bitrateKbps,
      targetKind: targetKind ?? this.targetKind,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (headersJson.present) {
      map['headers_json'] = Variable<String>(headersJson.value);
    }
    if (codec.present) {
      map['codec'] = Variable<String>(codec.value);
    }
    if (bitrateKbps.present) {
      map['bitrate_kbps'] = Variable<int>(bitrateKbps.value);
    }
    if (targetKind.present) {
      map['target_kind'] = Variable<String>(targetKind.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreamResolutionsCompanion(')
          ..write('localTrackId: $localTrackId, ')
          ..write('source: $source, ')
          ..write('quality: $quality, ')
          ..write('url: $url, ')
          ..write('headersJson: $headersJson, ')
          ..write('codec: $codec, ')
          ..write('bitrateKbps: $bitrateKbps, ')
          ..write('targetKind: $targetKind, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackFailuresTable extends TrackFailures
    with TableInfo<$TrackFailuresTable, TrackFailure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackFailuresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _httpStatusMeta = const VerificationMeta(
    'httpStatus',
  );
  @override
  late final GeneratedColumn<int> httpStatus = GeneratedColumn<int>(
    'http_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstFailedAtMeta = const VerificationMeta(
    'firstFailedAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstFailedAt =
      GeneratedColumn<DateTime>(
        'first_failed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _lastFailedAtMeta = const VerificationMeta(
    'lastFailedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFailedAt = GeneratedColumn<DateTime>(
    'last_failed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localTrackId,
    source,
    reason,
    httpStatus,
    note,
    firstFailedAt,
    lastFailedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_failures';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackFailure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('http_status')) {
      context.handle(
        _httpStatusMeta,
        httpStatus.isAcceptableOrUnknown(data['http_status']!, _httpStatusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('first_failed_at')) {
      context.handle(
        _firstFailedAtMeta,
        firstFailedAt.isAcceptableOrUnknown(
          data['first_failed_at']!,
          _firstFailedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_failed_at')) {
      context.handle(
        _lastFailedAtMeta,
        lastFailedAt.isAcceptableOrUnknown(
          data['last_failed_at']!,
          _lastFailedAtMeta,
        ),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTrackId, source};
  @override
  TrackFailure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackFailure(
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      httpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}http_status'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      firstFailedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_failed_at'],
      )!,
      lastFailedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_failed_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $TrackFailuresTable createAlias(String alias) {
    return $TrackFailuresTable(attachedDatabase, alias);
  }
}

class TrackFailure extends DataClass implements Insertable<TrackFailure> {
  final String localTrackId;
  final String source;

  /// Причина по SourceFailReason.name — без неё цепочка молча долбит каталог.
  final String reason;
  final int? httpStatus;
  final String? note;
  final DateTime firstFailedAt;
  final DateTime lastFailedAt;
  final DateTime expiresAt;
  const TrackFailure({
    required this.localTrackId,
    required this.source,
    required this.reason,
    this.httpStatus,
    this.note,
    required this.firstFailedAt,
    required this.lastFailedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_track_id'] = Variable<String>(localTrackId);
    map['source'] = Variable<String>(source);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || httpStatus != null) {
      map['http_status'] = Variable<int>(httpStatus);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['first_failed_at'] = Variable<DateTime>(firstFailedAt);
    map['last_failed_at'] = Variable<DateTime>(lastFailedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  TrackFailuresCompanion toCompanion(bool nullToAbsent) {
    return TrackFailuresCompanion(
      localTrackId: Value(localTrackId),
      source: Value(source),
      reason: Value(reason),
      httpStatus: httpStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(httpStatus),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      firstFailedAt: Value(firstFailedAt),
      lastFailedAt: Value(lastFailedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory TrackFailure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackFailure(
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      source: serializer.fromJson<String>(json['source']),
      reason: serializer.fromJson<String>(json['reason']),
      httpStatus: serializer.fromJson<int?>(json['httpStatus']),
      note: serializer.fromJson<String?>(json['note']),
      firstFailedAt: serializer.fromJson<DateTime>(json['firstFailedAt']),
      lastFailedAt: serializer.fromJson<DateTime>(json['lastFailedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTrackId': serializer.toJson<String>(localTrackId),
      'source': serializer.toJson<String>(source),
      'reason': serializer.toJson<String>(reason),
      'httpStatus': serializer.toJson<int?>(httpStatus),
      'note': serializer.toJson<String?>(note),
      'firstFailedAt': serializer.toJson<DateTime>(firstFailedAt),
      'lastFailedAt': serializer.toJson<DateTime>(lastFailedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  TrackFailure copyWith({
    String? localTrackId,
    String? source,
    String? reason,
    Value<int?> httpStatus = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? firstFailedAt,
    DateTime? lastFailedAt,
    DateTime? expiresAt,
  }) => TrackFailure(
    localTrackId: localTrackId ?? this.localTrackId,
    source: source ?? this.source,
    reason: reason ?? this.reason,
    httpStatus: httpStatus.present ? httpStatus.value : this.httpStatus,
    note: note.present ? note.value : this.note,
    firstFailedAt: firstFailedAt ?? this.firstFailedAt,
    lastFailedAt: lastFailedAt ?? this.lastFailedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  TrackFailure copyWithCompanion(TrackFailuresCompanion data) {
    return TrackFailure(
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      source: data.source.present ? data.source.value : this.source,
      reason: data.reason.present ? data.reason.value : this.reason,
      httpStatus: data.httpStatus.present
          ? data.httpStatus.value
          : this.httpStatus,
      note: data.note.present ? data.note.value : this.note,
      firstFailedAt: data.firstFailedAt.present
          ? data.firstFailedAt.value
          : this.firstFailedAt,
      lastFailedAt: data.lastFailedAt.present
          ? data.lastFailedAt.value
          : this.lastFailedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackFailure(')
          ..write('localTrackId: $localTrackId, ')
          ..write('source: $source, ')
          ..write('reason: $reason, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('note: $note, ')
          ..write('firstFailedAt: $firstFailedAt, ')
          ..write('lastFailedAt: $lastFailedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localTrackId,
    source,
    reason,
    httpStatus,
    note,
    firstFailedAt,
    lastFailedAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackFailure &&
          other.localTrackId == this.localTrackId &&
          other.source == this.source &&
          other.reason == this.reason &&
          other.httpStatus == this.httpStatus &&
          other.note == this.note &&
          other.firstFailedAt == this.firstFailedAt &&
          other.lastFailedAt == this.lastFailedAt &&
          other.expiresAt == this.expiresAt);
}

class TrackFailuresCompanion extends UpdateCompanion<TrackFailure> {
  final Value<String> localTrackId;
  final Value<String> source;
  final Value<String> reason;
  final Value<int?> httpStatus;
  final Value<String?> note;
  final Value<DateTime> firstFailedAt;
  final Value<DateTime> lastFailedAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const TrackFailuresCompanion({
    this.localTrackId = const Value.absent(),
    this.source = const Value.absent(),
    this.reason = const Value.absent(),
    this.httpStatus = const Value.absent(),
    this.note = const Value.absent(),
    this.firstFailedAt = const Value.absent(),
    this.lastFailedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackFailuresCompanion.insert({
    required String localTrackId,
    required String source,
    required String reason,
    this.httpStatus = const Value.absent(),
    this.note = const Value.absent(),
    this.firstFailedAt = const Value.absent(),
    this.lastFailedAt = const Value.absent(),
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : localTrackId = Value(localTrackId),
       source = Value(source),
       reason = Value(reason),
       expiresAt = Value(expiresAt);
  static Insertable<TrackFailure> custom({
    Expression<String>? localTrackId,
    Expression<String>? source,
    Expression<String>? reason,
    Expression<int>? httpStatus,
    Expression<String>? note,
    Expression<DateTime>? firstFailedAt,
    Expression<DateTime>? lastFailedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (source != null) 'source': source,
      if (reason != null) 'reason': reason,
      if (httpStatus != null) 'http_status': httpStatus,
      if (note != null) 'note': note,
      if (firstFailedAt != null) 'first_failed_at': firstFailedAt,
      if (lastFailedAt != null) 'last_failed_at': lastFailedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackFailuresCompanion copyWith({
    Value<String>? localTrackId,
    Value<String>? source,
    Value<String>? reason,
    Value<int?>? httpStatus,
    Value<String?>? note,
    Value<DateTime>? firstFailedAt,
    Value<DateTime>? lastFailedAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return TrackFailuresCompanion(
      localTrackId: localTrackId ?? this.localTrackId,
      source: source ?? this.source,
      reason: reason ?? this.reason,
      httpStatus: httpStatus ?? this.httpStatus,
      note: note ?? this.note,
      firstFailedAt: firstFailedAt ?? this.firstFailedAt,
      lastFailedAt: lastFailedAt ?? this.lastFailedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (httpStatus.present) {
      map['http_status'] = Variable<int>(httpStatus.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (firstFailedAt.present) {
      map['first_failed_at'] = Variable<DateTime>(firstFailedAt.value);
    }
    if (lastFailedAt.present) {
      map['last_failed_at'] = Variable<DateTime>(lastFailedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackFailuresCompanion(')
          ..write('localTrackId: $localTrackId, ')
          ..write('source: $source, ')
          ..write('reason: $reason, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('note: $note, ')
          ..write('firstFailedAt: $firstFailedAt, ')
          ..write('lastFailedAt: $lastFailedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedFilesTable extends DownloadedFiles
    with TableInfo<$DownloadedFilesTable, DownloadedFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('auto'),
  );
  static const VerificationMeta _codecMeta = const VerificationMeta('codec');
  @override
  late final GeneratedColumn<String> codec = GeneratedColumn<String>(
    'codec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uncensoredMeta = const VerificationMeta(
    'uncensored',
  );
  @override
  late final GeneratedColumn<bool> uncensored = GeneratedColumn<bool>(
    'uncensored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uncensored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorTextMeta = const VerificationMeta(
    'errorText',
  );
  @override
  late final GeneratedColumn<String> errorText = GeneratedColumn<String>(
    'error_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sha1Meta = const VerificationMeta('sha1');
  @override
  late final GeneratedColumn<String> sha1 = GeneratedColumn<String>(
    'sha1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localTrackId,
    filePath,
    sizeBytes,
    quality,
    codec,
    origin,
    coverPath,
    uncensored,
    state,
    source,
    errorText,
    sha1,
    downloadedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('codec')) {
      context.handle(
        _codecMeta,
        codec.isAcceptableOrUnknown(data['codec']!, _codecMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('uncensored')) {
      context.handle(
        _uncensoredMeta,
        uncensored.isAcceptableOrUnknown(data['uncensored']!, _uncensoredMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('error_text')) {
      context.handle(
        _errorTextMeta,
        errorText.isAcceptableOrUnknown(data['error_text']!, _errorTextMeta),
      );
    }
    if (data.containsKey('sha1')) {
      context.handle(
        _sha1Meta,
        sha1.isAcceptableOrUnknown(data['sha1']!, _sha1Meta),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {localTrackId},
  ];
  @override
  DownloadedFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      )!,
      codec: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codec'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      uncensored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uncensored'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      errorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_text'],
      ),
      sha1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha1'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
    );
  }

  @override
  $DownloadedFilesTable createAlias(String alias) {
    return $DownloadedFilesTable(attachedDatabase, alias);
  }
}

class DownloadedFile extends DataClass implements Insertable<DownloadedFile> {
  final int id;
  final String localTrackId;
  final String filePath;
  final int sizeBytes;
  final String quality;
  final String? codec;

  /// manual | auto — ручная загрузка или автозагрузка лайков.
  final String origin;

  /// Локальная копия обложки; без неё «Скачанное» пустеет офлайн.
  final String? coverPath;

  /// Скачан незацензуренный файл из базы FckCensorData. У старых загрузок
  /// false: они могли скачаться до того, как трек попал в базу.
  final bool uncensored;

  /// pending | downloading | complete | failed
  final String state;
  final String source;
  final String? errorText;

  /// Контрольная сумма файла: перекачка после обрыва не должна портить трек.
  final String? sha1;
  final DateTime downloadedAt;
  const DownloadedFile({
    required this.id,
    required this.localTrackId,
    required this.filePath,
    required this.sizeBytes,
    required this.quality,
    this.codec,
    required this.origin,
    this.coverPath,
    required this.uncensored,
    required this.state,
    required this.source,
    this.errorText,
    this.sha1,
    required this.downloadedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_track_id'] = Variable<String>(localTrackId);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['quality'] = Variable<String>(quality);
    if (!nullToAbsent || codec != null) {
      map['codec'] = Variable<String>(codec);
    }
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['uncensored'] = Variable<bool>(uncensored);
    map['state'] = Variable<String>(state);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || errorText != null) {
      map['error_text'] = Variable<String>(errorText);
    }
    if (!nullToAbsent || sha1 != null) {
      map['sha1'] = Variable<String>(sha1);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  DownloadedFilesCompanion toCompanion(bool nullToAbsent) {
    return DownloadedFilesCompanion(
      id: Value(id),
      localTrackId: Value(localTrackId),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      quality: Value(quality),
      codec: codec == null && nullToAbsent
          ? const Value.absent()
          : Value(codec),
      origin: Value(origin),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      uncensored: Value(uncensored),
      state: Value(state),
      source: Value(source),
      errorText: errorText == null && nullToAbsent
          ? const Value.absent()
          : Value(errorText),
      sha1: sha1 == null && nullToAbsent ? const Value.absent() : Value(sha1),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory DownloadedFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedFile(
      id: serializer.fromJson<int>(json['id']),
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      quality: serializer.fromJson<String>(json['quality']),
      codec: serializer.fromJson<String?>(json['codec']),
      origin: serializer.fromJson<String>(json['origin']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      uncensored: serializer.fromJson<bool>(json['uncensored']),
      state: serializer.fromJson<String>(json['state']),
      source: serializer.fromJson<String>(json['source']),
      errorText: serializer.fromJson<String?>(json['errorText']),
      sha1: serializer.fromJson<String?>(json['sha1']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localTrackId': serializer.toJson<String>(localTrackId),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'quality': serializer.toJson<String>(quality),
      'codec': serializer.toJson<String?>(codec),
      'origin': serializer.toJson<String>(origin),
      'coverPath': serializer.toJson<String?>(coverPath),
      'uncensored': serializer.toJson<bool>(uncensored),
      'state': serializer.toJson<String>(state),
      'source': serializer.toJson<String>(source),
      'errorText': serializer.toJson<String?>(errorText),
      'sha1': serializer.toJson<String?>(sha1),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  DownloadedFile copyWith({
    int? id,
    String? localTrackId,
    String? filePath,
    int? sizeBytes,
    String? quality,
    Value<String?> codec = const Value.absent(),
    String? origin,
    Value<String?> coverPath = const Value.absent(),
    bool? uncensored,
    String? state,
    String? source,
    Value<String?> errorText = const Value.absent(),
    Value<String?> sha1 = const Value.absent(),
    DateTime? downloadedAt,
  }) => DownloadedFile(
    id: id ?? this.id,
    localTrackId: localTrackId ?? this.localTrackId,
    filePath: filePath ?? this.filePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    quality: quality ?? this.quality,
    codec: codec.present ? codec.value : this.codec,
    origin: origin ?? this.origin,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    uncensored: uncensored ?? this.uncensored,
    state: state ?? this.state,
    source: source ?? this.source,
    errorText: errorText.present ? errorText.value : this.errorText,
    sha1: sha1.present ? sha1.value : this.sha1,
    downloadedAt: downloadedAt ?? this.downloadedAt,
  );
  DownloadedFile copyWithCompanion(DownloadedFilesCompanion data) {
    return DownloadedFile(
      id: data.id.present ? data.id.value : this.id,
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      quality: data.quality.present ? data.quality.value : this.quality,
      codec: data.codec.present ? data.codec.value : this.codec,
      origin: data.origin.present ? data.origin.value : this.origin,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      uncensored: data.uncensored.present
          ? data.uncensored.value
          : this.uncensored,
      state: data.state.present ? data.state.value : this.state,
      source: data.source.present ? data.source.value : this.source,
      errorText: data.errorText.present ? data.errorText.value : this.errorText,
      sha1: data.sha1.present ? data.sha1.value : this.sha1,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedFile(')
          ..write('id: $id, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('quality: $quality, ')
          ..write('codec: $codec, ')
          ..write('origin: $origin, ')
          ..write('coverPath: $coverPath, ')
          ..write('uncensored: $uncensored, ')
          ..write('state: $state, ')
          ..write('source: $source, ')
          ..write('errorText: $errorText, ')
          ..write('sha1: $sha1, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localTrackId,
    filePath,
    sizeBytes,
    quality,
    codec,
    origin,
    coverPath,
    uncensored,
    state,
    source,
    errorText,
    sha1,
    downloadedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedFile &&
          other.id == this.id &&
          other.localTrackId == this.localTrackId &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.quality == this.quality &&
          other.codec == this.codec &&
          other.origin == this.origin &&
          other.coverPath == this.coverPath &&
          other.uncensored == this.uncensored &&
          other.state == this.state &&
          other.source == this.source &&
          other.errorText == this.errorText &&
          other.sha1 == this.sha1 &&
          other.downloadedAt == this.downloadedAt);
}

class DownloadedFilesCompanion extends UpdateCompanion<DownloadedFile> {
  final Value<int> id;
  final Value<String> localTrackId;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<String> quality;
  final Value<String?> codec;
  final Value<String> origin;
  final Value<String?> coverPath;
  final Value<bool> uncensored;
  final Value<String> state;
  final Value<String> source;
  final Value<String?> errorText;
  final Value<String?> sha1;
  final Value<DateTime> downloadedAt;
  const DownloadedFilesCompanion({
    this.id = const Value.absent(),
    this.localTrackId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.quality = const Value.absent(),
    this.codec = const Value.absent(),
    this.origin = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.uncensored = const Value.absent(),
    this.state = const Value.absent(),
    this.source = const Value.absent(),
    this.errorText = const Value.absent(),
    this.sha1 = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  DownloadedFilesCompanion.insert({
    this.id = const Value.absent(),
    required String localTrackId,
    required String filePath,
    this.sizeBytes = const Value.absent(),
    this.quality = const Value.absent(),
    this.codec = const Value.absent(),
    this.origin = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.uncensored = const Value.absent(),
    this.state = const Value.absent(),
    required String source,
    this.errorText = const Value.absent(),
    this.sha1 = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  }) : localTrackId = Value(localTrackId),
       filePath = Value(filePath),
       source = Value(source);
  static Insertable<DownloadedFile> custom({
    Expression<int>? id,
    Expression<String>? localTrackId,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<String>? quality,
    Expression<String>? codec,
    Expression<String>? origin,
    Expression<String>? coverPath,
    Expression<bool>? uncensored,
    Expression<String>? state,
    Expression<String>? source,
    Expression<String>? errorText,
    Expression<String>? sha1,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (quality != null) 'quality': quality,
      if (codec != null) 'codec': codec,
      if (origin != null) 'origin': origin,
      if (coverPath != null) 'cover_path': coverPath,
      if (uncensored != null) 'uncensored': uncensored,
      if (state != null) 'state': state,
      if (source != null) 'source': source,
      if (errorText != null) 'error_text': errorText,
      if (sha1 != null) 'sha1': sha1,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  DownloadedFilesCompanion copyWith({
    Value<int>? id,
    Value<String>? localTrackId,
    Value<String>? filePath,
    Value<int>? sizeBytes,
    Value<String>? quality,
    Value<String?>? codec,
    Value<String>? origin,
    Value<String?>? coverPath,
    Value<bool>? uncensored,
    Value<String>? state,
    Value<String>? source,
    Value<String?>? errorText,
    Value<String?>? sha1,
    Value<DateTime>? downloadedAt,
  }) {
    return DownloadedFilesCompanion(
      id: id ?? this.id,
      localTrackId: localTrackId ?? this.localTrackId,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      quality: quality ?? this.quality,
      codec: codec ?? this.codec,
      origin: origin ?? this.origin,
      coverPath: coverPath ?? this.coverPath,
      uncensored: uncensored ?? this.uncensored,
      state: state ?? this.state,
      source: source ?? this.source,
      errorText: errorText ?? this.errorText,
      sha1: sha1 ?? this.sha1,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (codec.present) {
      map['codec'] = Variable<String>(codec.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (uncensored.present) {
      map['uncensored'] = Variable<bool>(uncensored.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (errorText.present) {
      map['error_text'] = Variable<String>(errorText.value);
    }
    if (sha1.present) {
      map['sha1'] = Variable<String>(sha1.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedFilesCompanion(')
          ..write('id: $id, ')
          ..write('localTrackId: $localTrackId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('quality: $quality, ')
          ..write('codec: $codec, ')
          ..write('origin: $origin, ')
          ..write('coverPath: $coverPath, ')
          ..write('uncensored: $uncensored, ')
          ..write('state: $state, ')
          ..write('source: $source, ')
          ..write('errorText: $errorText, ')
          ..write('sha1: $sha1, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localTrackIdMeta = const VerificationMeta(
    'localTrackId',
  );
  @override
  late final GeneratedColumn<String> localTrackId = GeneratedColumn<String>(
    'local_track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _receivedBytesMeta = const VerificationMeta(
    'receivedBytes',
  );
  @override
  late final GeneratedColumn<int> receivedBytes = GeneratedColumn<int>(
    'received_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<String> quality = GeneratedColumn<String>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localTrackId,
    state,
    origin,
    priority,
    attempts,
    receivedBytes,
    totalBytes,
    quality,
    lastError,
    nextAttemptAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_track_id')) {
      context.handle(
        _localTrackIdMeta,
        localTrackId.isAcceptableOrUnknown(
          data['local_track_id']!,
          _localTrackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTrackIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('received_bytes')) {
      context.handle(
        _receivedBytesMeta,
        receivedBytes.isAcceptableOrUnknown(
          data['received_bytes']!,
          _receivedBytesMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localTrackId};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      localTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_track_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      receivedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}received_bytes'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final String localTrackId;

  /// queued | downloading | paused | failed | skipped | excluded
  final String state;
  final String origin;

  /// Меньше — раньше; ручные задачи идут впереди автозагрузки.
  final int priority;
  final int attempts;
  final int receivedBytes;
  final int? totalBytes;
  final String? quality;
  final String? lastError;
  final DateTime? nextAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadTask({
    required this.localTrackId,
    required this.state,
    required this.origin,
    required this.priority,
    required this.attempts,
    required this.receivedBytes,
    this.totalBytes,
    this.quality,
    this.lastError,
    this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_track_id'] = Variable<String>(localTrackId);
    map['state'] = Variable<String>(state);
    map['origin'] = Variable<String>(origin);
    map['priority'] = Variable<int>(priority);
    map['attempts'] = Variable<int>(attempts);
    map['received_bytes'] = Variable<int>(receivedBytes);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<String>(quality);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      localTrackId: Value(localTrackId),
      state: Value(state),
      origin: Value(origin),
      priority: Value(priority),
      attempts: Value(attempts),
      receivedBytes: Value(receivedBytes),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      localTrackId: serializer.fromJson<String>(json['localTrackId']),
      state: serializer.fromJson<String>(json['state']),
      origin: serializer.fromJson<String>(json['origin']),
      priority: serializer.fromJson<int>(json['priority']),
      attempts: serializer.fromJson<int>(json['attempts']),
      receivedBytes: serializer.fromJson<int>(json['receivedBytes']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      quality: serializer.fromJson<String?>(json['quality']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localTrackId': serializer.toJson<String>(localTrackId),
      'state': serializer.toJson<String>(state),
      'origin': serializer.toJson<String>(origin),
      'priority': serializer.toJson<int>(priority),
      'attempts': serializer.toJson<int>(attempts),
      'receivedBytes': serializer.toJson<int>(receivedBytes),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'quality': serializer.toJson<String?>(quality),
      'lastError': serializer.toJson<String?>(lastError),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadTask copyWith({
    String? localTrackId,
    String? state,
    String? origin,
    int? priority,
    int? attempts,
    int? receivedBytes,
    Value<int?> totalBytes = const Value.absent(),
    Value<String?> quality = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DownloadTask(
    localTrackId: localTrackId ?? this.localTrackId,
    state: state ?? this.state,
    origin: origin ?? this.origin,
    priority: priority ?? this.priority,
    attempts: attempts ?? this.attempts,
    receivedBytes: receivedBytes ?? this.receivedBytes,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    quality: quality.present ? quality.value : this.quality,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      localTrackId: data.localTrackId.present
          ? data.localTrackId.value
          : this.localTrackId,
      state: data.state.present ? data.state.value : this.state,
      origin: data.origin.present ? data.origin.value : this.origin,
      priority: data.priority.present ? data.priority.value : this.priority,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      receivedBytes: data.receivedBytes.present
          ? data.receivedBytes.value
          : this.receivedBytes,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      quality: data.quality.present ? data.quality.value : this.quality,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('localTrackId: $localTrackId, ')
          ..write('state: $state, ')
          ..write('origin: $origin, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('quality: $quality, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localTrackId,
    state,
    origin,
    priority,
    attempts,
    receivedBytes,
    totalBytes,
    quality,
    lastError,
    nextAttemptAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.localTrackId == this.localTrackId &&
          other.state == this.state &&
          other.origin == this.origin &&
          other.priority == this.priority &&
          other.attempts == this.attempts &&
          other.receivedBytes == this.receivedBytes &&
          other.totalBytes == this.totalBytes &&
          other.quality == this.quality &&
          other.lastError == this.lastError &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> localTrackId;
  final Value<String> state;
  final Value<String> origin;
  final Value<int> priority;
  final Value<int> attempts;
  final Value<int> receivedBytes;
  final Value<int?> totalBytes;
  final Value<String?> quality;
  final Value<String?> lastError;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.localTrackId = const Value.absent(),
    this.state = const Value.absent(),
    this.origin = const Value.absent(),
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.quality = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String localTrackId,
    this.state = const Value.absent(),
    this.origin = const Value.absent(),
    this.priority = const Value.absent(),
    this.attempts = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.quality = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localTrackId = Value(localTrackId);
  static Insertable<DownloadTask> custom({
    Expression<String>? localTrackId,
    Expression<String>? state,
    Expression<String>? origin,
    Expression<int>? priority,
    Expression<int>? attempts,
    Expression<int>? receivedBytes,
    Expression<int>? totalBytes,
    Expression<String>? quality,
    Expression<String>? lastError,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localTrackId != null) 'local_track_id': localTrackId,
      if (state != null) 'state': state,
      if (origin != null) 'origin': origin,
      if (priority != null) 'priority': priority,
      if (attempts != null) 'attempts': attempts,
      if (receivedBytes != null) 'received_bytes': receivedBytes,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (quality != null) 'quality': quality,
      if (lastError != null) 'last_error': lastError,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<String>? localTrackId,
    Value<String>? state,
    Value<String>? origin,
    Value<int>? priority,
    Value<int>? attempts,
    Value<int>? receivedBytes,
    Value<int?>? totalBytes,
    Value<String?>? quality,
    Value<String?>? lastError,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadTasksCompanion(
      localTrackId: localTrackId ?? this.localTrackId,
      state: state ?? this.state,
      origin: origin ?? this.origin,
      priority: priority ?? this.priority,
      attempts: attempts ?? this.attempts,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      quality: quality ?? this.quality,
      lastError: lastError ?? this.lastError,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localTrackId.present) {
      map['local_track_id'] = Variable<String>(localTrackId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (receivedBytes.present) {
      map['received_bytes'] = Variable<int>(receivedBytes.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (quality.present) {
      map['quality'] = Variable<String>(quality.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('localTrackId: $localTrackId, ')
          ..write('state: $state, ')
          ..write('origin: $origin, ')
          ..write('priority: $priority, ')
          ..write('attempts: $attempts, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('quality: $quality, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuthTokensTable extends AuthTokens
    with TableInfo<$AuthTokensTable, AuthToken> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthTokensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta(
    'accessToken',
  );
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta(
    'refreshToken',
  );
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenTypeMeta = const VerificationMeta(
    'tokenType',
  );
  @override
  late final GeneratedColumn<String> tokenType = GeneratedColumn<String>(
    'token_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OAuth'),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasPlusMeta = const VerificationMeta(
    'hasPlus',
  );
  @override
  late final GeneratedColumn<bool> hasPlus = GeneratedColumn<bool>(
    'has_plus',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_plus" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scopesCsvMeta = const VerificationMeta(
    'scopesCsv',
  );
  @override
  late final GeneratedColumn<String> scopesCsv = GeneratedColumn<String>(
    'scopes_csv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    provider,
    accessToken,
    refreshToken,
    tokenType,
    expiresAt,
    uid,
    login,
    displayName,
    hasPlus,
    scopesCsv,
    extraJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_tokens';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthToken> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(
          data['access_token']!,
          _accessTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accessTokenMeta);
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
        _refreshTokenMeta,
        refreshToken.isAcceptableOrUnknown(
          data['refresh_token']!,
          _refreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('token_type')) {
      context.handle(
        _tokenTypeMeta,
        tokenType.isAcceptableOrUnknown(data['token_type']!, _tokenTypeMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('has_plus')) {
      context.handle(
        _hasPlusMeta,
        hasPlus.isAcceptableOrUnknown(data['has_plus']!, _hasPlusMeta),
      );
    }
    if (data.containsKey('scopes_csv')) {
      context.handle(
        _scopesCsvMeta,
        scopesCsv.isAcceptableOrUnknown(data['scopes_csv']!, _scopesCsvMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provider};
  @override
  AuthToken map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthToken(
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      )!,
      refreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token'],
      ),
      tokenType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_type'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at'],
      ),
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      ),
      login: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      hasPlus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_plus'],
      )!,
      scopesCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scopes_csv'],
      )!,
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AuthTokensTable createAlias(String alias) {
    return $AuthTokensTable(attachedDatabase, alias);
  }
}

class AuthToken extends DataClass implements Insertable<AuthToken> {
  /// yandex | spotify | deezer | soundcloud
  final String provider;
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int? expiresAt;
  final String? uid;
  final String? login;
  final String? displayName;
  final bool hasPlus;
  final String scopesCsv;

  /// Всё остальное из ответа авторизации (device flow, expiry, region).
  final String? extraJson;
  final DateTime updatedAt;
  const AuthToken({
    required this.provider,
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
    this.expiresAt,
    this.uid,
    this.login,
    this.displayName,
    required this.hasPlus,
    required this.scopesCsv,
    this.extraJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['provider'] = Variable<String>(provider);
    map['access_token'] = Variable<String>(accessToken);
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    map['token_type'] = Variable<String>(tokenType);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<String>(uid);
    }
    if (!nullToAbsent || login != null) {
      map['login'] = Variable<String>(login);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['has_plus'] = Variable<bool>(hasPlus);
    map['scopes_csv'] = Variable<String>(scopesCsv);
    if (!nullToAbsent || extraJson != null) {
      map['extra_json'] = Variable<String>(extraJson);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuthTokensCompanion toCompanion(bool nullToAbsent) {
    return AuthTokensCompanion(
      provider: Value(provider),
      accessToken: Value(accessToken),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      tokenType: Value(tokenType),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      login: login == null && nullToAbsent
          ? const Value.absent()
          : Value(login),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      hasPlus: Value(hasPlus),
      scopesCsv: Value(scopesCsv),
      extraJson: extraJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extraJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AuthToken.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthToken(
      provider: serializer.fromJson<String>(json['provider']),
      accessToken: serializer.fromJson<String>(json['accessToken']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      tokenType: serializer.fromJson<String>(json['tokenType']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
      uid: serializer.fromJson<String?>(json['uid']),
      login: serializer.fromJson<String?>(json['login']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      hasPlus: serializer.fromJson<bool>(json['hasPlus']),
      scopesCsv: serializer.fromJson<String>(json['scopesCsv']),
      extraJson: serializer.fromJson<String?>(json['extraJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provider': serializer.toJson<String>(provider),
      'accessToken': serializer.toJson<String>(accessToken),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'tokenType': serializer.toJson<String>(tokenType),
      'expiresAt': serializer.toJson<int?>(expiresAt),
      'uid': serializer.toJson<String?>(uid),
      'login': serializer.toJson<String?>(login),
      'displayName': serializer.toJson<String?>(displayName),
      'hasPlus': serializer.toJson<bool>(hasPlus),
      'scopesCsv': serializer.toJson<String>(scopesCsv),
      'extraJson': serializer.toJson<String?>(extraJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AuthToken copyWith({
    String? provider,
    String? accessToken,
    Value<String?> refreshToken = const Value.absent(),
    String? tokenType,
    Value<int?> expiresAt = const Value.absent(),
    Value<String?> uid = const Value.absent(),
    Value<String?> login = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    bool? hasPlus,
    String? scopesCsv,
    Value<String?> extraJson = const Value.absent(),
    DateTime? updatedAt,
  }) => AuthToken(
    provider: provider ?? this.provider,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken.present ? refreshToken.value : this.refreshToken,
    tokenType: tokenType ?? this.tokenType,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    uid: uid.present ? uid.value : this.uid,
    login: login.present ? login.value : this.login,
    displayName: displayName.present ? displayName.value : this.displayName,
    hasPlus: hasPlus ?? this.hasPlus,
    scopesCsv: scopesCsv ?? this.scopesCsv,
    extraJson: extraJson.present ? extraJson.value : this.extraJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AuthToken copyWithCompanion(AuthTokensCompanion data) {
    return AuthToken(
      provider: data.provider.present ? data.provider.value : this.provider,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
      refreshToken: data.refreshToken.present
          ? data.refreshToken.value
          : this.refreshToken,
      tokenType: data.tokenType.present ? data.tokenType.value : this.tokenType,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      uid: data.uid.present ? data.uid.value : this.uid,
      login: data.login.present ? data.login.value : this.login,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      hasPlus: data.hasPlus.present ? data.hasPlus.value : this.hasPlus,
      scopesCsv: data.scopesCsv.present ? data.scopesCsv.value : this.scopesCsv,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthToken(')
          ..write('provider: $provider, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('tokenType: $tokenType, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('uid: $uid, ')
          ..write('login: $login, ')
          ..write('displayName: $displayName, ')
          ..write('hasPlus: $hasPlus, ')
          ..write('scopesCsv: $scopesCsv, ')
          ..write('extraJson: $extraJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    provider,
    accessToken,
    refreshToken,
    tokenType,
    expiresAt,
    uid,
    login,
    displayName,
    hasPlus,
    scopesCsv,
    extraJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthToken &&
          other.provider == this.provider &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.tokenType == this.tokenType &&
          other.expiresAt == this.expiresAt &&
          other.uid == this.uid &&
          other.login == this.login &&
          other.displayName == this.displayName &&
          other.hasPlus == this.hasPlus &&
          other.scopesCsv == this.scopesCsv &&
          other.extraJson == this.extraJson &&
          other.updatedAt == this.updatedAt);
}

class AuthTokensCompanion extends UpdateCompanion<AuthToken> {
  final Value<String> provider;
  final Value<String> accessToken;
  final Value<String?> refreshToken;
  final Value<String> tokenType;
  final Value<int?> expiresAt;
  final Value<String?> uid;
  final Value<String?> login;
  final Value<String?> displayName;
  final Value<bool> hasPlus;
  final Value<String> scopesCsv;
  final Value<String?> extraJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AuthTokensCompanion({
    this.provider = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.tokenType = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.login = const Value.absent(),
    this.displayName = const Value.absent(),
    this.hasPlus = const Value.absent(),
    this.scopesCsv = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuthTokensCompanion.insert({
    required String provider,
    required String accessToken,
    this.refreshToken = const Value.absent(),
    this.tokenType = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.uid = const Value.absent(),
    this.login = const Value.absent(),
    this.displayName = const Value.absent(),
    this.hasPlus = const Value.absent(),
    this.scopesCsv = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : provider = Value(provider),
       accessToken = Value(accessToken);
  static Insertable<AuthToken> custom({
    Expression<String>? provider,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<String>? tokenType,
    Expression<int>? expiresAt,
    Expression<String>? uid,
    Expression<String>? login,
    Expression<String>? displayName,
    Expression<bool>? hasPlus,
    Expression<String>? scopesCsv,
    Expression<String>? extraJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (provider != null) 'provider': provider,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (tokenType != null) 'token_type': tokenType,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (uid != null) 'uid': uid,
      if (login != null) 'login': login,
      if (displayName != null) 'display_name': displayName,
      if (hasPlus != null) 'has_plus': hasPlus,
      if (scopesCsv != null) 'scopes_csv': scopesCsv,
      if (extraJson != null) 'extra_json': extraJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuthTokensCompanion copyWith({
    Value<String>? provider,
    Value<String>? accessToken,
    Value<String?>? refreshToken,
    Value<String>? tokenType,
    Value<int?>? expiresAt,
    Value<String?>? uid,
    Value<String?>? login,
    Value<String?>? displayName,
    Value<bool>? hasPlus,
    Value<String>? scopesCsv,
    Value<String?>? extraJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AuthTokensCompanion(
      provider: provider ?? this.provider,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
      uid: uid ?? this.uid,
      login: login ?? this.login,
      displayName: displayName ?? this.displayName,
      hasPlus: hasPlus ?? this.hasPlus,
      scopesCsv: scopesCsv ?? this.scopesCsv,
      extraJson: extraJson ?? this.extraJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (tokenType.present) {
      map['token_type'] = Variable<String>(tokenType.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (hasPlus.present) {
      map['has_plus'] = Variable<bool>(hasPlus.value);
    }
    if (scopesCsv.present) {
      map['scopes_csv'] = Variable<String>(scopesCsv.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthTokensCompanion(')
          ..write('provider: $provider, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('tokenType: $tokenType, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('uid: $uid, ')
          ..write('login: $login, ')
          ..write('displayName: $displayName, ')
          ..write('hasPlus: $hasPlus, ')
          ..write('scopesCsv: $scopesCsv, ')
          ..write('extraJson: $extraJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, valueJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;

  /// JSON-значение: порядок источников правится без пересборки.
  final String valueJson;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.valueJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value_json'] = Variable<String>(valueJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      valueJson: Value(valueJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'valueJson': serializer.toJson<String>(valueJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? valueJson, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        valueJson: valueJson ?? this.valueJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, valueJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.valueJson == this.valueJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> valueJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String valueJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       valueJson = Value(valueJson);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? valueJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (valueJson != null) 'value_json': valueJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? valueJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('valueJson: $valueJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ArtistsTable artists = $ArtistsTable(this);
  late final $AlbumsTable albums = $AlbumsTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $TrackArtistsTable trackArtists = $TrackArtistsTable(this);
  late final $RemoteIdMappingsTable remoteIdMappings = $RemoteIdMappingsTable(
    this,
  );
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistTracksTable playlistTracks = $PlaylistTracksTable(this);
  late final $LikesTable likes = $LikesTable(this);
  late final $HistoryTable history = $HistoryTable(this);
  late final $QueueSnapshotsTable queueSnapshots = $QueueSnapshotsTable(this);
  late final $StreamResolutionsTable streamResolutions =
      $StreamResolutionsTable(this);
  late final $TrackFailuresTable trackFailures = $TrackFailuresTable(this);
  late final $DownloadedFilesTable downloadedFiles = $DownloadedFilesTable(
    this,
  );
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $AuthTokensTable authTokens = $AuthTokensTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index artistsBySource = Index(
    'artists_by_source',
    'CREATE UNIQUE INDEX artists_by_source ON artists (source, remote_artist_id)',
  );
  late final Index artistsByNameNorm = Index(
    'artists_by_name_norm',
    'CREATE INDEX artists_by_name_norm ON artists (name_norm)',
  );
  late final Index albumsBySource = Index(
    'albums_by_source',
    'CREATE UNIQUE INDEX albums_by_source ON albums (source, remote_album_id)',
  );
  late final Index tracksByFingerprint = Index(
    'tracks_by_fingerprint',
    'CREATE UNIQUE INDEX tracks_by_fingerprint ON tracks (fingerprint)',
  );
  late final Index tracksByTitleNorm = Index(
    'tracks_by_title_norm',
    'CREATE INDEX tracks_by_title_norm ON tracks (title_norm)',
  );
  late final Index tracksByIsrc = Index(
    'tracks_by_isrc',
    'CREATE INDEX tracks_by_isrc ON tracks (isrc)',
  );
  late final Index tracksByLastSeen = Index(
    'tracks_by_last_seen',
    'CREATE INDEX tracks_by_last_seen ON tracks (last_seen_at)',
  );
  late final Index trackArtistsByArtist = Index(
    'track_artists_by_artist',
    'CREATE INDEX track_artists_by_artist ON track_artists (artist_id)',
  );
  late final Index mappingsByTrack = Index(
    'mappings_by_track',
    'CREATE INDEX mappings_by_track ON remote_id_mappings (local_track_id)',
  );
  late final Index playlistsBySource = Index(
    'playlists_by_source',
    'CREATE UNIQUE INDEX playlists_by_source ON playlists (source, remote_playlist_id)',
  );
  late final Index playlistsByKind = Index(
    'playlists_by_kind',
    'CREATE INDEX playlists_by_kind ON playlists (kind)',
  );
  late final Index playlistTracksOrder = Index(
    'playlist_tracks_order',
    'CREATE INDEX playlist_tracks_order ON playlist_tracks (playlist_id, position)',
  );
  late final Index likesByState = Index(
    'likes_by_state',
    'CREATE INDEX likes_by_state ON likes (state, liked_at)',
  );
  late final Index historyByPlayedAt = Index(
    'history_by_played_at',
    'CREATE INDEX history_by_played_at ON history (played_at)',
  );
  late final Index historyByTrack = Index(
    'history_by_track',
    'CREATE INDEX history_by_track ON history (local_track_id, played_at)',
  );
  late final Index queueSnapshotsUnique = Index(
    'queue_snapshots_unique',
    'CREATE UNIQUE INDEX queue_snapshots_unique ON queue_snapshots (kind)',
  );
  late final Index streamResolutionsExpiry = Index(
    'stream_resolutions_expiry',
    'CREATE INDEX stream_resolutions_expiry ON stream_resolutions (expires_at)',
  );
  late final Index trackFailuresExpiry = Index(
    'track_failures_expiry',
    'CREATE INDEX track_failures_expiry ON track_failures (expires_at)',
  );
  late final Index downloadedFilesState = Index(
    'downloaded_files_state',
    'CREATE INDEX downloaded_files_state ON downloaded_files (state)',
  );
  late final Index authTokensExpiry = Index(
    'auth_tokens_expiry',
    'CREATE INDEX auth_tokens_expiry ON auth_tokens (expires_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    artists,
    albums,
    tracks,
    trackArtists,
    remoteIdMappings,
    playlists,
    playlistTracks,
    likes,
    history,
    queueSnapshots,
    streamResolutions,
    trackFailures,
    downloadedFiles,
    downloadTasks,
    authTokens,
    appSettings,
    artistsBySource,
    artistsByNameNorm,
    albumsBySource,
    tracksByFingerprint,
    tracksByTitleNorm,
    tracksByIsrc,
    tracksByLastSeen,
    trackArtistsByArtist,
    mappingsByTrack,
    playlistsBySource,
    playlistsByKind,
    playlistTracksOrder,
    likesByState,
    historyByPlayedAt,
    historyByTrack,
    queueSnapshotsUnique,
    streamResolutionsExpiry,
    trackFailuresExpiry,
    downloadedFilesState,
    authTokensExpiry,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'albums',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracks', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_artists', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('remote_id_mappings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_tracks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('likes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('history', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stream_resolutions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_failures', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('downloaded_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tracks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('download_tasks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ArtistsTableCreateCompanionBuilder = ArtistsCompanion Function({
  Value<int> id,
  required String name,
  required String nameNorm,
  Value<String?> coverUrl,
  required String source,
  required String remoteArtistId,
  Value<DateTime> updatedAt,
});
typedef $$ArtistsTableUpdateCompanionBuilder = ArtistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameNorm,
  Value<String?> coverUrl,
  Value<String> source,
  Value<String> remoteArtistId,
  Value<DateTime> updatedAt,
});

final class $$ArtistsTableReferences
    extends BaseReferences<_$AppDatabase, $ArtistsTable, Artist> {
  $$ArtistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'artists__id__tracks__main_artist_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.mainArtistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackArtistsTable, List<TrackArtist>>
  _trackArtistsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackArtists,
    aliasName: 'artists__id__track_artists__artist_id',
  );

  $$TrackArtistsTableProcessedTableManager get trackArtistsRefs {
    final manager = $$TrackArtistsTableTableManager(
      $_db,
      $_db.trackArtists,
    ).filter((f) => f.artistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackArtistsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteArtistId => $composableBuilder(
    column: $table.remoteArtistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.mainArtistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackArtistsRefs(
    Expression<bool> Function($$TrackArtistsTableFilterComposer f) f,
  ) {
    final $$TrackArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtists,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableFilterComposer(
            $db: $db,
            $table: $db.trackArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNorm => $composableBuilder(
    column: $table.nameNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteArtistId => $composableBuilder(
    column: $table.remoteArtistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtistsTable> {
  $$ArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNorm =>
      $composableBuilder(column: $table.nameNorm, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get remoteArtistId => $composableBuilder(
    column: $table.remoteArtistId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.mainArtistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackArtistsRefs<T extends Object>(
    Expression<T> Function($$TrackArtistsTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtists,
      getReferencedColumn: (t) => t.artistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtistsTable,
          Artist,
          $$ArtistsTableFilterComposer,
          $$ArtistsTableOrderingComposer,
          $$ArtistsTableAnnotationComposer,
          $$ArtistsTableCreateCompanionBuilder,
          $$ArtistsTableUpdateCompanionBuilder,
          (Artist, $$ArtistsTableReferences),
          Artist,
          PrefetchHooks Function({bool tracksRefs, bool trackArtistsRefs})
        > {
  $$ArtistsTableTableManager(_$AppDatabase db, $ArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNorm = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> remoteArtistId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ArtistsCompanion(
                id: id,
                name: name,
                nameNorm: nameNorm,
                coverUrl: coverUrl,
                source: source,
                remoteArtistId: remoteArtistId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameNorm,
                Value<String?> coverUrl = const Value.absent(),
                required String source,
                required String remoteArtistId,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ArtistsCompanion.insert(
                id: id,
                name: name,
                nameNorm: nameNorm,
                coverUrl: coverUrl,
                source: source,
                remoteArtistId: remoteArtistId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArtistsTable, Artist>(table),
                  $$ArtistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tracksRefs = false, trackArtistsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tracksRefs) db.tracks,
                    if (trackArtistsRefs) db.trackArtists,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tracksRefs)
                        await $_getPrefetchedData<Artist, $ArtistsTable, Track>(
                          currentTable: table,
                          referencedTable: $$ArtistsTableReferences
                              ._tracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistsTableReferences(
                                db,
                                table,
                                p0,
                              ).tracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mainArtistId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackArtistsRefs)
                        await $_getPrefetchedData<
                          Artist,
                          $ArtistsTable,
                          TrackArtist
                        >(
                          currentTable: table,
                          referencedTable: $$ArtistsTableReferences
                              ._trackArtistsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtistsTableReferences(
                                db,
                                table,
                                p0,
                              ).trackArtistsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artistId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtistsTable,
      Artist,
      $$ArtistsTableFilterComposer,
      $$ArtistsTableOrderingComposer,
      $$ArtistsTableAnnotationComposer,
      $$ArtistsTableCreateCompanionBuilder,
      $$ArtistsTableUpdateCompanionBuilder,
      (Artist, $$ArtistsTableReferences),
      Artist,
      PrefetchHooks Function({bool tracksRefs, bool trackArtistsRefs})
    >;
typedef $$AlbumsTableCreateCompanionBuilder = AlbumsCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> coverUrl,
  Value<int?> year,
  Value<DateTime?> releaseDate,
  required String source,
  required String remoteAlbumId,
  Value<String> artistIdsCsv,
  Value<DateTime> updatedAt,
});
typedef $$AlbumsTableUpdateCompanionBuilder = AlbumsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> coverUrl,
  Value<int?> year,
  Value<DateTime?> releaseDate,
  Value<String> source,
  Value<String> remoteAlbumId,
  Value<String> artistIdsCsv,
  Value<DateTime> updatedAt,
});

final class $$AlbumsTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTable, Album> {
  $$AlbumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'albums__id__tracks__album_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumsTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteAlbumId => $composableBuilder(
    column: $table.remoteAlbumId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artistIdsCsv => $composableBuilder(
    column: $table.artistIdsCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteAlbumId => $composableBuilder(
    column: $table.remoteAlbumId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artistIdsCsv => $composableBuilder(
    column: $table.artistIdsCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTable> {
  $$AlbumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get remoteAlbumId => $composableBuilder(
    column: $table.remoteAlbumId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artistIdsCsv => $composableBuilder(
    column: $table.artistIdsCsv,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTable,
          Album,
          $$AlbumsTableFilterComposer,
          $$AlbumsTableOrderingComposer,
          $$AlbumsTableAnnotationComposer,
          $$AlbumsTableCreateCompanionBuilder,
          $$AlbumsTableUpdateCompanionBuilder,
          (Album, $$AlbumsTableReferences),
          Album,
          PrefetchHooks Function({bool tracksRefs})
        > {
  $$AlbumsTableTableManager(_$AppDatabase db, $AlbumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> remoteAlbumId = const Value.absent(),
                Value<String> artistIdsCsv = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AlbumsCompanion(
                id: id,
                title: title,
                coverUrl: coverUrl,
                year: year,
                releaseDate: releaseDate,
                source: source,
                remoteAlbumId: remoteAlbumId,
                artistIdsCsv: artistIdsCsv,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> coverUrl = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                required String source,
                required String remoteAlbumId,
                Value<String> artistIdsCsv = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AlbumsCompanion.insert(
                id: id,
                title: title,
                coverUrl: coverUrl,
                year: year,
                releaseDate: releaseDate,
                source: source,
                remoteAlbumId: remoteAlbumId,
                artistIdsCsv: artistIdsCsv,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlbumsTable, Album>(table),
                  $$AlbumsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksRefs) db.tracks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedData<Album, $AlbumsTable, Track>(
                      currentTable: table,
                      referencedTable: $$AlbumsTableReferences._tracksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$AlbumsTableReferences(db, table, p0).tracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.albumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTable,
      Album,
      $$AlbumsTableFilterComposer,
      $$AlbumsTableOrderingComposer,
      $$AlbumsTableAnnotationComposer,
      $$AlbumsTableCreateCompanionBuilder,
      $$AlbumsTableUpdateCompanionBuilder,
      (Album, $$AlbumsTableReferences),
      Album,
      PrefetchHooks Function({bool tracksRefs})
    >;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  required String id,
  required String title,
  required String titleNorm,
  required int durationSec,
  Value<int?> mainArtistId,
  Value<int?> albumId,
  Value<String?> coverUrl,
  Value<String?> isrc,
  Value<bool> explicitFlag,
  Value<bool> lyricsAvailable,
  required String fingerprint,
  Value<int?> popularity,
  Value<String?> contentRating,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> lastSeenAt,
  required String metadataSource,
  Value<int> rowid,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> titleNorm,
  Value<int> durationSec,
  Value<int?> mainArtistId,
  Value<int?> albumId,
  Value<String?> coverUrl,
  Value<String?> isrc,
  Value<bool> explicitFlag,
  Value<bool> lyricsAvailable,
  Value<String> fingerprint,
  Value<int?> popularity,
  Value<String?> contentRating,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> lastSeenAt,
  Value<String> metadataSource,
  Value<int> rowid,
});

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArtistsTable _mainArtistIdTable(_$AppDatabase db) =>
      db.artists.createAlias('tracks__main_artist_id__artists__id');

  $$ArtistsTableProcessedTableManager? get mainArtistId {
    final $_column = $_itemColumn<int>('main_artist_id');
    if ($_column == null) return null;
    final manager = $$ArtistsTableTableManager(
      $_db,
      $_db.artists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mainArtistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AlbumsTable _albumIdTable(_$AppDatabase db) =>
      db.albums.createAlias('tracks__album_id__albums__id');

  $$AlbumsTableProcessedTableManager? get albumId {
    final $_column = $_itemColumn<int>('album_id');
    if ($_column == null) return null;
    final manager = $$AlbumsTableTableManager(
      $_db,
      $_db.albums,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TrackArtistsTable, List<TrackArtist>>
  _trackArtistsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackArtists,
    aliasName: 'tracks__id__track_artists__track_id',
  );

  $$TrackArtistsTableProcessedTableManager get trackArtistsRefs {
    final manager = $$TrackArtistsTableTableManager(
      $_db,
      $_db.trackArtists,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackArtistsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemoteIdMappingsTable, List<RemoteIdMapping>>
  _remoteIdMappingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remoteIdMappings,
    aliasName: 'tracks__id__remote_id_mappings__local_track_id',
  );

  $$RemoteIdMappingsTableProcessedTableManager get remoteIdMappingsRefs {
    final manager = $$RemoteIdMappingsTableTableManager(
      $_db,
      $_db.remoteIdMappings,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _remoteIdMappingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaylistTracksTable, List<PlaylistTrack>>
  _playlistTracksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistTracks,
    aliasName: 'tracks__id__playlist_tracks__local_track_id',
  );

  $$PlaylistTracksTableProcessedTableManager get playlistTracksRefs {
    final manager = $$PlaylistTracksTableTableManager(
      $_db,
      $_db.playlistTracks,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LikesTable, List<Like>> _likesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.likes,
    aliasName: 'tracks__id__likes__local_track_id',
  );

  $$LikesTableProcessedTableManager get likesRefs {
    final manager = $$LikesTableTableManager(
      $_db,
      $_db.likes,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_likesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HistoryTable, List<HistoryData>>
  _historyRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.history,
    aliasName: 'tracks__id__history__local_track_id',
  );

  $$HistoryTableProcessedTableManager get historyRefs {
    final manager = $$HistoryTableTableManager(
      $_db,
      $_db.history,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_historyRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StreamResolutionsTable, List<StreamResolution>>
  _streamResolutionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.streamResolutions,
        aliasName: 'tracks__id__stream_resolutions__local_track_id',
      );

  $$StreamResolutionsTableProcessedTableManager get streamResolutionsRefs {
    final manager = $$StreamResolutionsTableTableManager(
      $_db,
      $_db.streamResolutions,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _streamResolutionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackFailuresTable, List<TrackFailure>>
  _trackFailuresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackFailures,
    aliasName: 'tracks__id__track_failures__local_track_id',
  );

  $$TrackFailuresTableProcessedTableManager get trackFailuresRefs {
    final manager = $$TrackFailuresTableTableManager(
      $_db,
      $_db.trackFailures,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackFailuresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadedFilesTable, List<DownloadedFile>>
  _downloadedFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadedFiles,
    aliasName: 'tracks__id__downloaded_files__local_track_id',
  );

  $$DownloadedFilesTableProcessedTableManager get downloadedFilesRefs {
    final manager = $$DownloadedFilesTableTableManager(
      $_db,
      $_db.downloadedFiles,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _downloadedFilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DownloadTasksTable, List<DownloadTask>>
  _downloadTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadTasks,
    aliasName: 'tracks__id__download_tasks__local_track_id',
  );

  $$DownloadTasksTableProcessedTableManager get downloadTasksRefs {
    final manager = $$DownloadTasksTableTableManager(
      $_db,
      $_db.downloadTasks,
    ).filter((f) => f.localTrackId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicitFlag => $composableBuilder(
    column: $table.explicitFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lyricsAvailable => $composableBuilder(
    column: $table.lyricsAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentRating => $composableBuilder(
    column: $table.contentRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataSource => $composableBuilder(
    column: $table.metadataSource,
    builder: (column) => ColumnFilters(column),
  );

  $$ArtistsTableFilterComposer get mainArtistId {
    final $$ArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainArtistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableFilterComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableFilterComposer get albumId {
    final $$AlbumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableFilterComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> trackArtistsRefs(
    Expression<bool> Function($$TrackArtistsTableFilterComposer f) f,
  ) {
    final $$TrackArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtists,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableFilterComposer(
            $db: $db,
            $table: $db.trackArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remoteIdMappingsRefs(
    Expression<bool> Function($$RemoteIdMappingsTableFilterComposer f) f,
  ) {
    final $$RemoteIdMappingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remoteIdMappings,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemoteIdMappingsTableFilterComposer(
            $db: $db,
            $table: $db.remoteIdMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistTracksRefs(
    Expression<bool> Function($$PlaylistTracksTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> likesRefs(
    Expression<bool> Function($$LikesTableFilterComposer f) f,
  ) {
    final $$LikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.likes,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LikesTableFilterComposer(
            $db: $db,
            $table: $db.likes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> historyRefs(
    Expression<bool> Function($$HistoryTableFilterComposer f) f,
  ) {
    final $$HistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.history,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryTableFilterComposer(
            $db: $db,
            $table: $db.history,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> streamResolutionsRefs(
    Expression<bool> Function($$StreamResolutionsTableFilterComposer f) f,
  ) {
    final $$StreamResolutionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.streamResolutions,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StreamResolutionsTableFilterComposer(
            $db: $db,
            $table: $db.streamResolutions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackFailuresRefs(
    Expression<bool> Function($$TrackFailuresTableFilterComposer f) f,
  ) {
    final $$TrackFailuresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackFailures,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackFailuresTableFilterComposer(
            $db: $db,
            $table: $db.trackFailures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadedFilesRefs(
    Expression<bool> Function($$DownloadedFilesTableFilterComposer f) f,
  ) {
    final $$DownloadedFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadedFiles,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadedFilesTableFilterComposer(
            $db: $db,
            $table: $db.downloadedFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> downloadTasksRefs(
    Expression<bool> Function($$DownloadTasksTableFilterComposer f) f,
  ) {
    final $$DownloadTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadTasks,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadTasksTableFilterComposer(
            $db: $db,
            $table: $db.downloadTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleNorm => $composableBuilder(
    column: $table.titleNorm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isrc => $composableBuilder(
    column: $table.isrc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicitFlag => $composableBuilder(
    column: $table.explicitFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lyricsAvailable => $composableBuilder(
    column: $table.lyricsAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentRating => $composableBuilder(
    column: $table.contentRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataSource => $composableBuilder(
    column: $table.metadataSource,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArtistsTableOrderingComposer get mainArtistId {
    final $$ArtistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainArtistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableOrderingComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableOrderingComposer get albumId {
    final $$AlbumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableOrderingComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleNorm =>
      $composableBuilder(column: $table.titleNorm, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
    column: $table.durationSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get isrc =>
      $composableBuilder(column: $table.isrc, builder: (column) => column);

  GeneratedColumn<bool> get explicitFlag => $composableBuilder(
    column: $table.explicitFlag,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lyricsAvailable => $composableBuilder(
    column: $table.lyricsAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentRating => $composableBuilder(
    column: $table.contentRating,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataSource => $composableBuilder(
    column: $table.metadataSource,
    builder: (column) => column,
  );

  $$ArtistsTableAnnotationComposer get mainArtistId {
    final $$ArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainArtistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumsTableAnnotationComposer get albumId {
    final $$AlbumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albums,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableAnnotationComposer(
            $db: $db,
            $table: $db.albums,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> trackArtistsRefs<T extends Object>(
    Expression<T> Function($$TrackArtistsTableAnnotationComposer a) f,
  ) {
    final $$TrackArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackArtists,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackArtists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remoteIdMappingsRefs<T extends Object>(
    Expression<T> Function($$RemoteIdMappingsTableAnnotationComposer a) f,
  ) {
    final $$RemoteIdMappingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remoteIdMappings,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemoteIdMappingsTableAnnotationComposer(
            $db: $db,
            $table: $db.remoteIdMappings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistTracksRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> likesRefs<T extends Object>(
    Expression<T> Function($$LikesTableAnnotationComposer a) f,
  ) {
    final $$LikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.likes,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LikesTableAnnotationComposer(
            $db: $db,
            $table: $db.likes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> historyRefs<T extends Object>(
    Expression<T> Function($$HistoryTableAnnotationComposer a) f,
  ) {
    final $$HistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.history,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.history,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> streamResolutionsRefs<T extends Object>(
    Expression<T> Function($$StreamResolutionsTableAnnotationComposer a) f,
  ) {
    final $$StreamResolutionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.streamResolutions,
          getReferencedColumn: (t) => t.localTrackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StreamResolutionsTableAnnotationComposer(
                $db: $db,
                $table: $db.streamResolutions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> trackFailuresRefs<T extends Object>(
    Expression<T> Function($$TrackFailuresTableAnnotationComposer a) f,
  ) {
    final $$TrackFailuresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackFailures,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackFailuresTableAnnotationComposer(
            $db: $db,
            $table: $db.trackFailures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> downloadedFilesRefs<T extends Object>(
    Expression<T> Function($$DownloadedFilesTableAnnotationComposer a) f,
  ) {
    final $$DownloadedFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadedFiles,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadedFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadedFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> downloadTasksRefs<T extends Object>(
    Expression<T> Function($$DownloadTasksTableAnnotationComposer a) f,
  ) {
    final $$DownloadTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadTasks,
      getReferencedColumn: (t) => t.localTrackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({
            bool mainArtistId,
            bool albumId,
            bool trackArtistsRefs,
            bool remoteIdMappingsRefs,
            bool playlistTracksRefs,
            bool likesRefs,
            bool historyRefs,
            bool streamResolutionsRefs,
            bool trackFailuresRefs,
            bool downloadedFilesRefs,
            bool downloadTasksRefs,
          })
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleNorm = const Value.absent(),
                Value<int> durationSec = const Value.absent(),
                Value<int?> mainArtistId = const Value.absent(),
                Value<int?> albumId = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<bool> explicitFlag = const Value.absent(),
                Value<bool> lyricsAvailable = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int?> popularity = const Value.absent(),
                Value<String?> contentRating = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<String> metadataSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                title: title,
                titleNorm: titleNorm,
                durationSec: durationSec,
                mainArtistId: mainArtistId,
                albumId: albumId,
                coverUrl: coverUrl,
                isrc: isrc,
                explicitFlag: explicitFlag,
                lyricsAvailable: lyricsAvailable,
                fingerprint: fingerprint,
                popularity: popularity,
                contentRating: contentRating,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSeenAt: lastSeenAt,
                metadataSource: metadataSource,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String titleNorm,
                required int durationSec,
                Value<int?> mainArtistId = const Value.absent(),
                Value<int?> albumId = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> isrc = const Value.absent(),
                Value<bool> explicitFlag = const Value.absent(),
                Value<bool> lyricsAvailable = const Value.absent(),
                required String fingerprint,
                Value<int?> popularity = const Value.absent(),
                Value<String?> contentRating = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                required String metadataSource,
                Value<int> rowid = const Value.absent(),
              }) => TracksCompanion.insert(
                id: id,
                title: title,
                titleNorm: titleNorm,
                durationSec: durationSec,
                mainArtistId: mainArtistId,
                albumId: albumId,
                coverUrl: coverUrl,
                isrc: isrc,
                explicitFlag: explicitFlag,
                lyricsAvailable: lyricsAvailable,
                fingerprint: fingerprint,
                popularity: popularity,
                contentRating: contentRating,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSeenAt: lastSeenAt,
                metadataSource: metadataSource,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, Track>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mainArtistId = false,
                albumId = false,
                trackArtistsRefs = false,
                remoteIdMappingsRefs = false,
                playlistTracksRefs = false,
                likesRefs = false,
                historyRefs = false,
                streamResolutionsRefs = false,
                trackFailuresRefs = false,
                downloadedFilesRefs = false,
                downloadTasksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (trackArtistsRefs) db.trackArtists,
                    if (remoteIdMappingsRefs) db.remoteIdMappings,
                    if (playlistTracksRefs) db.playlistTracks,
                    if (likesRefs) db.likes,
                    if (historyRefs) db.history,
                    if (streamResolutionsRefs) db.streamResolutions,
                    if (trackFailuresRefs) db.trackFailures,
                    if (downloadedFilesRefs) db.downloadedFiles,
                    if (downloadTasksRefs) db.downloadTasks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (mainArtistId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.mainArtistId,
                            referencedTable: $$TracksTableReferences
                                ._mainArtistIdTable(db),
                            referencedColumn: $$TracksTableReferences
                                ._mainArtistIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (albumId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.albumId,
                            referencedTable: $$TracksTableReferences
                                ._albumIdTable(db),
                            referencedColumn: $$TracksTableReferences
                                ._albumIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (trackArtistsRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          TrackArtist
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._trackArtistsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).trackArtistsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.trackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remoteIdMappingsRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          RemoteIdMapping
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._remoteIdMappingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).remoteIdMappingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistTracksRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          PlaylistTrack
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._playlistTracksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistTracksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (likesRefs)
                        await $_getPrefetchedData<Track, $TracksTable, Like>(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._likesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(db, table, p0).likesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (historyRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          HistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._historyRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).historyRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (streamResolutionsRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          StreamResolution
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._streamResolutionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).streamResolutionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (trackFailuresRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          TrackFailure
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._trackFailuresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).trackFailuresRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadedFilesRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          DownloadedFile
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._downloadedFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadedFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (downloadTasksRefs)
                        await $_getPrefetchedData<
                          Track,
                          $TracksTable,
                          DownloadTask
                        >(
                          currentTable: table,
                          referencedTable: $$TracksTableReferences
                              ._downloadTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TracksTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localTrackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({
        bool mainArtistId,
        bool albumId,
        bool trackArtistsRefs,
        bool remoteIdMappingsRefs,
        bool playlistTracksRefs,
        bool likesRefs,
        bool historyRefs,
        bool streamResolutionsRefs,
        bool trackFailuresRefs,
        bool downloadedFilesRefs,
        bool downloadTasksRefs,
      })
    >;
typedef $$TrackArtistsTableCreateCompanionBuilder =
    TrackArtistsCompanion Function({
      required String trackId,
      required int artistId,
      Value<String> role,
      Value<int> position,
      Value<int> rowid,
    });
typedef $$TrackArtistsTableUpdateCompanionBuilder =
    TrackArtistsCompanion Function({
      Value<String> trackId,
      Value<int> artistId,
      Value<String> role,
      Value<int> position,
      Value<int> rowid,
    });

final class $$TrackArtistsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackArtistsTable, TrackArtist> {
  $$TrackArtistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _trackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('track_artists__track_id__tracks__id');

  $$TracksTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<String>('track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ArtistsTable _artistIdTable(_$AppDatabase db) =>
      db.artists.createAlias('track_artists__artist_id__artists__id');

  $$ArtistsTableProcessedTableManager get artistId {
    final $_column = $_itemColumn<int>('artist_id')!;

    final manager = $$ArtistsTableTableManager(
      $_db,
      $_db.artists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackArtistsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get trackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableFilterComposer get artistId {
    final $$ArtistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableFilterComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get trackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableOrderingComposer get artistId {
    final $$ArtistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableOrderingComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackArtistsTable> {
  $$TrackArtistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$TracksTableAnnotationComposer get trackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ArtistsTableAnnotationComposer get artistId {
    final $$ArtistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artistId,
      referencedTable: $db.artists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtistsTableAnnotationComposer(
            $db: $db,
            $table: $db.artists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackArtistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackArtistsTable,
          TrackArtist,
          $$TrackArtistsTableFilterComposer,
          $$TrackArtistsTableOrderingComposer,
          $$TrackArtistsTableAnnotationComposer,
          $$TrackArtistsTableCreateCompanionBuilder,
          $$TrackArtistsTableUpdateCompanionBuilder,
          (TrackArtist, $$TrackArtistsTableReferences),
          TrackArtist,
          PrefetchHooks Function({bool trackId, bool artistId})
        > {
  $$TrackArtistsTableTableManager(_$AppDatabase db, $TrackArtistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackArtistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackArtistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackArtistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<int> artistId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsCompanion(
                trackId: trackId,
                artistId: artistId,
                role: role,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required int artistId,
                Value<String> role = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackArtistsCompanion.insert(
                trackId: trackId,
                artistId: artistId,
                role: role,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackArtistsTable, TrackArtist>(table),
                  $$TrackArtistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false, artistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.trackId,
                        referencedTable: $$TrackArtistsTableReferences
                            ._trackIdTable(db),
                        referencedColumn: $$TrackArtistsTableReferences
                            ._trackIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (artistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.artistId,
                        referencedTable: $$TrackArtistsTableReferences
                            ._artistIdTable(db),
                        referencedColumn: $$TrackArtistsTableReferences
                            ._artistIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackArtistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackArtistsTable,
      TrackArtist,
      $$TrackArtistsTableFilterComposer,
      $$TrackArtistsTableOrderingComposer,
      $$TrackArtistsTableAnnotationComposer,
      $$TrackArtistsTableCreateCompanionBuilder,
      $$TrackArtistsTableUpdateCompanionBuilder,
      (TrackArtist, $$TrackArtistsTableReferences),
      TrackArtist,
      PrefetchHooks Function({bool trackId, bool artistId})
    >;
typedef $$RemoteIdMappingsTableCreateCompanionBuilder =
    RemoteIdMappingsCompanion Function({
      required String source,
      required String remoteId,
      Value<String?> albumRemoteId,
      required String localTrackId,
      Value<String> mappingConfidence,
      Value<String?> remoteJson,
      Value<DateTime> firstSeenAt,
      Value<DateTime> lastSeenAt,
      Value<int> rowid,
    });
typedef $$RemoteIdMappingsTableUpdateCompanionBuilder =
    RemoteIdMappingsCompanion Function({
      Value<String> source,
      Value<String> remoteId,
      Value<String?> albumRemoteId,
      Value<String> localTrackId,
      Value<String> mappingConfidence,
      Value<String?> remoteJson,
      Value<DateTime> firstSeenAt,
      Value<DateTime> lastSeenAt,
      Value<int> rowid,
    });

final class $$RemoteIdMappingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RemoteIdMappingsTable, RemoteIdMapping> {
  $$RemoteIdMappingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('remote_id_mappings__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemoteIdMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get albumRemoteId => $composableBuilder(
    column: $table.albumRemoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemoteIdMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get albumRemoteId => $composableBuilder(
    column: $table.albumRemoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemoteIdMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemoteIdMappingsTable> {
  $$RemoteIdMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get albumRemoteId => $composableBuilder(
    column: $table.albumRemoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mappingConfidence => $composableBuilder(
    column: $table.mappingConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteJson => $composableBuilder(
    column: $table.remoteJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemoteIdMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemoteIdMappingsTable,
          RemoteIdMapping,
          $$RemoteIdMappingsTableFilterComposer,
          $$RemoteIdMappingsTableOrderingComposer,
          $$RemoteIdMappingsTableAnnotationComposer,
          $$RemoteIdMappingsTableCreateCompanionBuilder,
          $$RemoteIdMappingsTableUpdateCompanionBuilder,
          (RemoteIdMapping, $$RemoteIdMappingsTableReferences),
          RemoteIdMapping,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$RemoteIdMappingsTableTableManager(
    _$AppDatabase db,
    $RemoteIdMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteIdMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteIdMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteIdMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> source = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<String?> albumRemoteId = const Value.absent(),
                Value<String> localTrackId = const Value.absent(),
                Value<String> mappingConfidence = const Value.absent(),
                Value<String?> remoteJson = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteIdMappingsCompanion(
                source: source,
                remoteId: remoteId,
                albumRemoteId: albumRemoteId,
                localTrackId: localTrackId,
                mappingConfidence: mappingConfidence,
                remoteJson: remoteJson,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String source,
                required String remoteId,
                Value<String?> albumRemoteId = const Value.absent(),
                required String localTrackId,
                Value<String> mappingConfidence = const Value.absent(),
                Value<String?> remoteJson = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteIdMappingsCompanion.insert(
                source: source,
                remoteId: remoteId,
                albumRemoteId: albumRemoteId,
                localTrackId: localTrackId,
                mappingConfidence: mappingConfidence,
                remoteJson: remoteJson,
                firstSeenAt: firstSeenAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemoteIdMappingsTable, RemoteIdMapping>(table),
                  $$RemoteIdMappingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$RemoteIdMappingsTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$RemoteIdMappingsTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemoteIdMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemoteIdMappingsTable,
      RemoteIdMapping,
      $$RemoteIdMappingsTableFilterComposer,
      $$RemoteIdMappingsTableOrderingComposer,
      $$RemoteIdMappingsTableAnnotationComposer,
      $$RemoteIdMappingsTableCreateCompanionBuilder,
      $$RemoteIdMappingsTableUpdateCompanionBuilder,
      (RemoteIdMapping, $$RemoteIdMappingsTableReferences),
      RemoteIdMapping,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  Value<String> source,
  Value<String?> remotePlaylistId,
  required String title,
  Value<String?> description,
  Value<String?> coverUrl,
  Value<String?> ownerUid,
  Value<String> kind,
  Value<int?> totalTracks,
  Value<bool> canEdit,
  Value<String> sortMode,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<String> source,
  Value<String?> remotePlaylistId,
  Value<String> title,
  Value<String?> description,
  Value<String?> coverUrl,
  Value<String?> ownerUid,
  Value<String> kind,
  Value<int?> totalTracks,
  Value<bool> canEdit,
  Value<String> sortMode,
  Value<DateTime?> lastSyncedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistTracksTable, List<PlaylistTrack>>
  _playlistTracksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistTracks,
    aliasName: 'playlists__id__playlist_tracks__playlist_id',
  );

  $$PlaylistTracksTableProcessedTableManager get playlistTracksRefs {
    final manager = $$PlaylistTracksTableTableManager(
      $_db,
      $_db.playlistTracks,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistTracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePlaylistId => $composableBuilder(
    column: $table.remotePlaylistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTracks => $composableBuilder(
    column: $table.totalTracks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canEdit => $composableBuilder(
    column: $table.canEdit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortMode => $composableBuilder(
    column: $table.sortMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistTracksRefs(
    Expression<bool> Function($$PlaylistTracksTableFilterComposer f) f,
  ) {
    final $$PlaylistTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableFilterComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePlaylistId => $composableBuilder(
    column: $table.remotePlaylistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTracks => $composableBuilder(
    column: $table.totalTracks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canEdit => $composableBuilder(
    column: $table.canEdit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortMode => $composableBuilder(
    column: $table.sortMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get remotePlaylistId => $composableBuilder(
    column: $table.remotePlaylistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get totalTracks => $composableBuilder(
    column: $table.totalTracks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canEdit =>
      $composableBuilder(column: $table.canEdit, builder: (column) => column);

  GeneratedColumn<String> get sortMode =>
      $composableBuilder(column: $table.sortMode, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistTracksRefs<T extends Object>(
    Expression<T> Function($$PlaylistTracksTableAnnotationComposer a) f,
  ) {
    final $$PlaylistTracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistTracks,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTracksTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistTracksRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> remotePlaylistId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> totalTracks = const Value.absent(),
                Value<bool> canEdit = const Value.absent(),
                Value<String> sortMode = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                source: source,
                remotePlaylistId: remotePlaylistId,
                title: title,
                description: description,
                coverUrl: coverUrl,
                ownerUid: ownerUid,
                kind: kind,
                totalTracks: totalTracks,
                canEdit: canEdit,
                sortMode: sortMode,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> source = const Value.absent(),
                Value<String?> remotePlaylistId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> ownerUid = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> totalTracks = const Value.absent(),
                Value<bool> canEdit = const Value.absent(),
                Value<String> sortMode = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                source: source,
                remotePlaylistId: remotePlaylistId,
                title: title,
                description: description,
                coverUrl: coverUrl,
                ownerUid: ownerUid,
                kind: kind,
                totalTracks: totalTracks,
                canEdit: canEdit,
                sortMode: sortMode,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, Playlist>(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistTracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistTracksRefs) db.playlistTracks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistTracksRefs)
                    await $_getPrefetchedData<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistTrack
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistTracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistTracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistTracksRefs})
    >;
typedef $$PlaylistTracksTableCreateCompanionBuilder =
    PlaylistTracksCompanion Function({
      required String playlistId,
      required String localTrackId,
      Value<int> position,
      required String sourceId,
      required String remoteId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$PlaylistTracksTableUpdateCompanionBuilder =
    PlaylistTracksCompanion Function({
      Value<String> playlistId,
      Value<String> localTrackId,
      Value<int> position,
      Value<String> sourceId,
      Value<String> remoteId,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$PlaylistTracksTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistTracksTable, PlaylistTrack> {
  $$PlaylistTracksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_tracks__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('playlist_tracks__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistTracksTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistTracksTable> {
  $$PlaylistTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistTracksTable,
          PlaylistTrack,
          $$PlaylistTracksTableFilterComposer,
          $$PlaylistTracksTableOrderingComposer,
          $$PlaylistTracksTableAnnotationComposer,
          $$PlaylistTracksTableCreateCompanionBuilder,
          $$PlaylistTracksTableUpdateCompanionBuilder,
          (PlaylistTrack, $$PlaylistTracksTableReferences),
          PlaylistTrack,
          PrefetchHooks Function({bool playlistId, bool localTrackId})
        > {
  $$PlaylistTracksTableTableManager(
    _$AppDatabase db,
    $PlaylistTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> localTrackId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksCompanion(
                playlistId: playlistId,
                localTrackId: localTrackId,
                position: position,
                sourceId: sourceId,
                remoteId: remoteId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String localTrackId,
                Value<int> position = const Value.absent(),
                required String sourceId,
                required String remoteId,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistTracksCompanion.insert(
                playlistId: playlistId,
                localTrackId: localTrackId,
                position: position,
                sourceId: sourceId,
                remoteId: remoteId,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistTracksTable, PlaylistTrack>(table),
                  $$PlaylistTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistTracksTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistTracksTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$PlaylistTracksTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$PlaylistTracksTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistTracksTable,
      PlaylistTrack,
      $$PlaylistTracksTableFilterComposer,
      $$PlaylistTracksTableOrderingComposer,
      $$PlaylistTracksTableAnnotationComposer,
      $$PlaylistTracksTableCreateCompanionBuilder,
      $$PlaylistTracksTableUpdateCompanionBuilder,
      (PlaylistTrack, $$PlaylistTracksTableReferences),
      PlaylistTrack,
      PrefetchHooks Function({bool playlistId, bool localTrackId})
    >;
typedef $$LikesTableCreateCompanionBuilder = LikesCompanion Function({
  required String localTrackId,
  Value<int> state,
  Value<DateTime> likedAt,
  Value<bool> syncedToRemote,
  Value<String?> remoteSource,
  Value<int?> pendingOp,
  Value<int> rowid,
});
typedef $$LikesTableUpdateCompanionBuilder = LikesCompanion Function({
  Value<String> localTrackId,
  Value<int> state,
  Value<DateTime> likedAt,
  Value<bool> syncedToRemote,
  Value<String?> remoteSource,
  Value<int?> pendingOp,
  Value<int> rowid,
});

final class $$LikesTableReferences
    extends BaseReferences<_$AppDatabase, $LikesTable, Like> {
  $$LikesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('likes__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LikesTableFilterComposer extends Composer<_$AppDatabase, $LikesTable> {
  $$LikesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncedToRemote => $composableBuilder(
    column: $table.syncedToRemote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteSource => $composableBuilder(
    column: $table.remoteSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingOp => $composableBuilder(
    column: $table.pendingOp,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LikesTableOrderingComposer
    extends Composer<_$AppDatabase, $LikesTable> {
  $$LikesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get likedAt => $composableBuilder(
    column: $table.likedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncedToRemote => $composableBuilder(
    column: $table.syncedToRemote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteSource => $composableBuilder(
    column: $table.remoteSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingOp => $composableBuilder(
    column: $table.pendingOp,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LikesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LikesTable> {
  $$LikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get likedAt =>
      $composableBuilder(column: $table.likedAt, builder: (column) => column);

  GeneratedColumn<bool> get syncedToRemote => $composableBuilder(
    column: $table.syncedToRemote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteSource => $composableBuilder(
    column: $table.remoteSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingOp =>
      $composableBuilder(column: $table.pendingOp, builder: (column) => column);

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LikesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LikesTable,
          Like,
          $$LikesTableFilterComposer,
          $$LikesTableOrderingComposer,
          $$LikesTableAnnotationComposer,
          $$LikesTableCreateCompanionBuilder,
          $$LikesTableUpdateCompanionBuilder,
          (Like, $$LikesTableReferences),
          Like,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$LikesTableTableManager(_$AppDatabase db, $LikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localTrackId = const Value.absent(),
                Value<int> state = const Value.absent(),
                Value<DateTime> likedAt = const Value.absent(),
                Value<bool> syncedToRemote = const Value.absent(),
                Value<String?> remoteSource = const Value.absent(),
                Value<int?> pendingOp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LikesCompanion(
                localTrackId: localTrackId,
                state: state,
                likedAt: likedAt,
                syncedToRemote: syncedToRemote,
                remoteSource: remoteSource,
                pendingOp: pendingOp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localTrackId,
                Value<int> state = const Value.absent(),
                Value<DateTime> likedAt = const Value.absent(),
                Value<bool> syncedToRemote = const Value.absent(),
                Value<String?> remoteSource = const Value.absent(),
                Value<int?> pendingOp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LikesCompanion.insert(
                localTrackId: localTrackId,
                state: state,
                likedAt: likedAt,
                syncedToRemote: syncedToRemote,
                remoteSource: remoteSource,
                pendingOp: pendingOp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LikesTable, Like>(table),
                  $$LikesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$LikesTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$LikesTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LikesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LikesTable,
      Like,
      $$LikesTableFilterComposer,
      $$LikesTableOrderingComposer,
      $$LikesTableAnnotationComposer,
      $$LikesTableCreateCompanionBuilder,
      $$LikesTableUpdateCompanionBuilder,
      (Like, $$LikesTableReferences),
      Like,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$HistoryTableCreateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  required String localTrackId,
  Value<DateTime> playedAt,
  Value<int> playedMs,
  Value<bool> completed,
  required String source,
  Value<String> quality,
  Value<String?> skipReason,
  Value<String?> device,
  Value<String?> eventJson,
});
typedef $$HistoryTableUpdateCompanionBuilder = HistoryCompanion Function({
  Value<int> id,
  Value<String> localTrackId,
  Value<DateTime> playedAt,
  Value<int> playedMs,
  Value<bool> completed,
  Value<String> source,
  Value<String> quality,
  Value<String?> skipReason,
  Value<String?> device,
  Value<String?> eventJson,
});

final class $$HistoryTableReferences
    extends BaseReferences<_$AppDatabase, $HistoryTable, HistoryData> {
  $$HistoryTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('history__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistoryTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedMs => $composableBuilder(
    column: $table.playedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventJson => $composableBuilder(
    column: $table.eventJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedMs => $composableBuilder(
    column: $table.playedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get device => $composableBuilder(
    column: $table.device,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventJson => $composableBuilder(
    column: $table.eventJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTable> {
  $$HistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get playedMs =>
      $composableBuilder(column: $table.playedMs, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get device =>
      $composableBuilder(column: $table.device, builder: (column) => column);

  GeneratedColumn<String> get eventJson =>
      $composableBuilder(column: $table.eventJson, builder: (column) => column);

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTable,
          HistoryData,
          $$HistoryTableFilterComposer,
          $$HistoryTableOrderingComposer,
          $$HistoryTableAnnotationComposer,
          $$HistoryTableCreateCompanionBuilder,
          $$HistoryTableUpdateCompanionBuilder,
          (HistoryData, $$HistoryTableReferences),
          HistoryData,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$HistoryTableTableManager(_$AppDatabase db, $HistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localTrackId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playedMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> quality = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<String?> device = const Value.absent(),
                Value<String?> eventJson = const Value.absent(),
              }) => HistoryCompanion(
                id: id,
                localTrackId: localTrackId,
                playedAt: playedAt,
                playedMs: playedMs,
                completed: completed,
                source: source,
                quality: quality,
                skipReason: skipReason,
                device: device,
                eventJson: eventJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localTrackId,
                Value<DateTime> playedAt = const Value.absent(),
                Value<int> playedMs = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                required String source,
                Value<String> quality = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<String?> device = const Value.absent(),
                Value<String?> eventJson = const Value.absent(),
              }) => HistoryCompanion.insert(
                id: id,
                localTrackId: localTrackId,
                playedAt: playedAt,
                playedMs: playedMs,
                completed: completed,
                source: source,
                quality: quality,
                skipReason: skipReason,
                device: device,
                eventJson: eventJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HistoryTable, HistoryData>(table),
                  $$HistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$HistoryTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$HistoryTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTable,
      HistoryData,
      $$HistoryTableFilterComposer,
      $$HistoryTableOrderingComposer,
      $$HistoryTableAnnotationComposer,
      $$HistoryTableCreateCompanionBuilder,
      $$HistoryTableUpdateCompanionBuilder,
      (HistoryData, $$HistoryTableReferences),
      HistoryData,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$QueueSnapshotsTableCreateCompanionBuilder =
    QueueSnapshotsCompanion Function({
      Value<int> id,
      required String kind,
      required String itemsJson,
      Value<int> queueIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> shuffleEnabled,
      Value<String?> sourceHintJson,
      Value<DateTime> savedAt,
    });
typedef $$QueueSnapshotsTableUpdateCompanionBuilder =
    QueueSnapshotsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> itemsJson,
      Value<int> queueIndex,
      Value<int> positionMs,
      Value<String> repeatMode,
      Value<bool> shuffleEnabled,
      Value<String?> sourceHintJson,
      Value<DateTime> savedAt,
    });

class $$QueueSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHintJson => $composableBuilder(
    column: $table.sourceHintJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHintJson => $composableBuilder(
    column: $table.sourceHintJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueSnapshotsTable> {
  $$QueueSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<int> get queueIndex => $composableBuilder(
    column: $table.queueIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatMode => $composableBuilder(
    column: $table.repeatMode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleEnabled => $composableBuilder(
    column: $table.shuffleEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceHintJson => $composableBuilder(
    column: $table.sourceHintJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$QueueSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueSnapshotsTable,
          QueueSnapshot,
          $$QueueSnapshotsTableFilterComposer,
          $$QueueSnapshotsTableOrderingComposer,
          $$QueueSnapshotsTableAnnotationComposer,
          $$QueueSnapshotsTableCreateCompanionBuilder,
          $$QueueSnapshotsTableUpdateCompanionBuilder,
          (
            QueueSnapshot,
            BaseReferences<_$AppDatabase, $QueueSnapshotsTable, QueueSnapshot>,
          ),
          QueueSnapshot,
          PrefetchHooks Function()
        > {
  $$QueueSnapshotsTableTableManager(
    _$AppDatabase db,
    $QueueSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int> queueIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String?> sourceHintJson = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => QueueSnapshotsCompanion(
                id: id,
                kind: kind,
                itemsJson: itemsJson,
                queueIndex: queueIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleEnabled: shuffleEnabled,
                sourceHintJson: sourceHintJson,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String itemsJson,
                Value<int> queueIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> repeatMode = const Value.absent(),
                Value<bool> shuffleEnabled = const Value.absent(),
                Value<String?> sourceHintJson = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => QueueSnapshotsCompanion.insert(
                id: id,
                kind: kind,
                itemsJson: itemsJson,
                queueIndex: queueIndex,
                positionMs: positionMs,
                repeatMode: repeatMode,
                shuffleEnabled: shuffleEnabled,
                sourceHintJson: sourceHintJson,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueSnapshotsTable, QueueSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QueueSnapshotsTable,
                    QueueSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueSnapshotsTable,
      QueueSnapshot,
      $$QueueSnapshotsTableFilterComposer,
      $$QueueSnapshotsTableOrderingComposer,
      $$QueueSnapshotsTableAnnotationComposer,
      $$QueueSnapshotsTableCreateCompanionBuilder,
      $$QueueSnapshotsTableUpdateCompanionBuilder,
      (
        QueueSnapshot,
        BaseReferences<_$AppDatabase, $QueueSnapshotsTable, QueueSnapshot>,
      ),
      QueueSnapshot,
      PrefetchHooks Function()
    >;
typedef $$StreamResolutionsTableCreateCompanionBuilder =
    StreamResolutionsCompanion Function({
      required String localTrackId,
      required String source,
      required String quality,
      required String url,
      Value<String> headersJson,
      Value<String?> codec,
      Value<int?> bitrateKbps,
      Value<String> targetKind,
      Value<String?> filePath,
      Value<DateTime> createdAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$StreamResolutionsTableUpdateCompanionBuilder =
    StreamResolutionsCompanion Function({
      Value<String> localTrackId,
      Value<String> source,
      Value<String> quality,
      Value<String> url,
      Value<String> headersJson,
      Value<String?> codec,
      Value<int?> bitrateKbps,
      Value<String> targetKind,
      Value<String?> filePath,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

final class $$StreamResolutionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StreamResolutionsTable,
          StreamResolution
        > {
  $$StreamResolutionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('stream_resolutions__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StreamResolutionsTableFilterComposer
    extends Composer<_$AppDatabase, $StreamResolutionsTable> {
  $$StreamResolutionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreamResolutionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StreamResolutionsTable> {
  $$StreamResolutionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreamResolutionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreamResolutionsTable> {
  $$StreamResolutionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get headersJson => $composableBuilder(
    column: $table.headersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codec =>
      $composableBuilder(column: $table.codec, builder: (column) => column);

  GeneratedColumn<int> get bitrateKbps => $composableBuilder(
    column: $table.bitrateKbps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetKind => $composableBuilder(
    column: $table.targetKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StreamResolutionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreamResolutionsTable,
          StreamResolution,
          $$StreamResolutionsTableFilterComposer,
          $$StreamResolutionsTableOrderingComposer,
          $$StreamResolutionsTableAnnotationComposer,
          $$StreamResolutionsTableCreateCompanionBuilder,
          $$StreamResolutionsTableUpdateCompanionBuilder,
          (StreamResolution, $$StreamResolutionsTableReferences),
          StreamResolution,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$StreamResolutionsTableTableManager(
    _$AppDatabase db,
    $StreamResolutionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreamResolutionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreamResolutionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreamResolutionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> localTrackId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> quality = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> headersJson = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<int?> bitrateKbps = const Value.absent(),
                Value<String> targetKind = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StreamResolutionsCompanion(
                localTrackId: localTrackId,
                source: source,
                quality: quality,
                url: url,
                headersJson: headersJson,
                codec: codec,
                bitrateKbps: bitrateKbps,
                targetKind: targetKind,
                filePath: filePath,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localTrackId,
                required String source,
                required String quality,
                required String url,
                Value<String> headersJson = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<int?> bitrateKbps = const Value.absent(),
                Value<String> targetKind = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => StreamResolutionsCompanion.insert(
                localTrackId: localTrackId,
                source: source,
                quality: quality,
                url: url,
                headersJson: headersJson,
                codec: codec,
                bitrateKbps: bitrateKbps,
                targetKind: targetKind,
                filePath: filePath,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StreamResolutionsTable, StreamResolution>(table),
                  $$StreamResolutionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$StreamResolutionsTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$StreamResolutionsTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StreamResolutionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreamResolutionsTable,
      StreamResolution,
      $$StreamResolutionsTableFilterComposer,
      $$StreamResolutionsTableOrderingComposer,
      $$StreamResolutionsTableAnnotationComposer,
      $$StreamResolutionsTableCreateCompanionBuilder,
      $$StreamResolutionsTableUpdateCompanionBuilder,
      (StreamResolution, $$StreamResolutionsTableReferences),
      StreamResolution,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$TrackFailuresTableCreateCompanionBuilder =
    TrackFailuresCompanion Function({
      required String localTrackId,
      required String source,
      required String reason,
      Value<int?> httpStatus,
      Value<String?> note,
      Value<DateTime> firstFailedAt,
      Value<DateTime> lastFailedAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$TrackFailuresTableUpdateCompanionBuilder =
    TrackFailuresCompanion Function({
      Value<String> localTrackId,
      Value<String> source,
      Value<String> reason,
      Value<int?> httpStatus,
      Value<String?> note,
      Value<DateTime> firstFailedAt,
      Value<DateTime> lastFailedAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

final class $$TrackFailuresTableReferences
    extends BaseReferences<_$AppDatabase, $TrackFailuresTable, TrackFailure> {
  $$TrackFailuresTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('track_failures__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackFailuresTableFilterComposer
    extends Composer<_$AppDatabase, $TrackFailuresTable> {
  $$TrackFailuresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstFailedAt => $composableBuilder(
    column: $table.firstFailedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFailedAt => $composableBuilder(
    column: $table.lastFailedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackFailuresTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackFailuresTable> {
  $$TrackFailuresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstFailedAt => $composableBuilder(
    column: $table.firstFailedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFailedAt => $composableBuilder(
    column: $table.lastFailedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackFailuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackFailuresTable> {
  $$TrackFailuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get firstFailedAt => $composableBuilder(
    column: $table.firstFailedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFailedAt => $composableBuilder(
    column: $table.lastFailedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackFailuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackFailuresTable,
          TrackFailure,
          $$TrackFailuresTableFilterComposer,
          $$TrackFailuresTableOrderingComposer,
          $$TrackFailuresTableAnnotationComposer,
          $$TrackFailuresTableCreateCompanionBuilder,
          $$TrackFailuresTableUpdateCompanionBuilder,
          (TrackFailure, $$TrackFailuresTableReferences),
          TrackFailure,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$TrackFailuresTableTableManager(_$AppDatabase db, $TrackFailuresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackFailuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackFailuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackFailuresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localTrackId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int?> httpStatus = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> firstFailedAt = const Value.absent(),
                Value<DateTime> lastFailedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackFailuresCompanion(
                localTrackId: localTrackId,
                source: source,
                reason: reason,
                httpStatus: httpStatus,
                note: note,
                firstFailedAt: firstFailedAt,
                lastFailedAt: lastFailedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localTrackId,
                required String source,
                required String reason,
                Value<int?> httpStatus = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> firstFailedAt = const Value.absent(),
                Value<DateTime> lastFailedAt = const Value.absent(),
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => TrackFailuresCompanion.insert(
                localTrackId: localTrackId,
                source: source,
                reason: reason,
                httpStatus: httpStatus,
                note: note,
                firstFailedAt: firstFailedAt,
                lastFailedAt: lastFailedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackFailuresTable, TrackFailure>(table),
                  $$TrackFailuresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$TrackFailuresTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$TrackFailuresTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackFailuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackFailuresTable,
      TrackFailure,
      $$TrackFailuresTableFilterComposer,
      $$TrackFailuresTableOrderingComposer,
      $$TrackFailuresTableAnnotationComposer,
      $$TrackFailuresTableCreateCompanionBuilder,
      $$TrackFailuresTableUpdateCompanionBuilder,
      (TrackFailure, $$TrackFailuresTableReferences),
      TrackFailure,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$DownloadedFilesTableCreateCompanionBuilder =
    DownloadedFilesCompanion Function({
      Value<int> id,
      required String localTrackId,
      required String filePath,
      Value<int> sizeBytes,
      Value<String> quality,
      Value<String?> codec,
      Value<String> origin,
      Value<String?> coverPath,
      Value<bool> uncensored,
      Value<String> state,
      required String source,
      Value<String?> errorText,
      Value<String?> sha1,
      Value<DateTime> downloadedAt,
    });
typedef $$DownloadedFilesTableUpdateCompanionBuilder =
    DownloadedFilesCompanion Function({
      Value<int> id,
      Value<String> localTrackId,
      Value<String> filePath,
      Value<int> sizeBytes,
      Value<String> quality,
      Value<String?> codec,
      Value<String> origin,
      Value<String?> coverPath,
      Value<bool> uncensored,
      Value<String> state,
      Value<String> source,
      Value<String?> errorText,
      Value<String?> sha1,
      Value<DateTime> downloadedAt,
    });

final class $$DownloadedFilesTableReferences
    extends
        BaseReferences<_$AppDatabase, $DownloadedFilesTable, DownloadedFile> {
  $$DownloadedFilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('downloaded_files__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadedFilesTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uncensored => $composableBuilder(
    column: $table.uncensored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorText => $composableBuilder(
    column: $table.errorText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha1 => $composableBuilder(
    column: $table.sha1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadedFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codec => $composableBuilder(
    column: $table.codec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uncensored => $composableBuilder(
    column: $table.uncensored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorText => $composableBuilder(
    column: $table.errorText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha1 => $composableBuilder(
    column: $table.sha1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadedFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedFilesTable> {
  $$DownloadedFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get codec =>
      $composableBuilder(column: $table.codec, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<bool> get uncensored => $composableBuilder(
    column: $table.uncensored,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get errorText =>
      $composableBuilder(column: $table.errorText, builder: (column) => column);

  GeneratedColumn<String> get sha1 =>
      $composableBuilder(column: $table.sha1, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadedFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedFilesTable,
          DownloadedFile,
          $$DownloadedFilesTableFilterComposer,
          $$DownloadedFilesTableOrderingComposer,
          $$DownloadedFilesTableAnnotationComposer,
          $$DownloadedFilesTableCreateCompanionBuilder,
          $$DownloadedFilesTableUpdateCompanionBuilder,
          (DownloadedFile, $$DownloadedFilesTableReferences),
          DownloadedFile,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$DownloadedFilesTableTableManager(
    _$AppDatabase db,
    $DownloadedFilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localTrackId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> quality = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<bool> uncensored = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> errorText = const Value.absent(),
                Value<String?> sha1 = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => DownloadedFilesCompanion(
                id: id,
                localTrackId: localTrackId,
                filePath: filePath,
                sizeBytes: sizeBytes,
                quality: quality,
                codec: codec,
                origin: origin,
                coverPath: coverPath,
                uncensored: uncensored,
                state: state,
                source: source,
                errorText: errorText,
                sha1: sha1,
                downloadedAt: downloadedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localTrackId,
                required String filePath,
                Value<int> sizeBytes = const Value.absent(),
                Value<String> quality = const Value.absent(),
                Value<String?> codec = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<bool> uncensored = const Value.absent(),
                Value<String> state = const Value.absent(),
                required String source,
                Value<String?> errorText = const Value.absent(),
                Value<String?> sha1 = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
              }) => DownloadedFilesCompanion.insert(
                id: id,
                localTrackId: localTrackId,
                filePath: filePath,
                sizeBytes: sizeBytes,
                quality: quality,
                codec: codec,
                origin: origin,
                coverPath: coverPath,
                uncensored: uncensored,
                state: state,
                source: source,
                errorText: errorText,
                sha1: sha1,
                downloadedAt: downloadedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadedFilesTable, DownloadedFile>(table),
                  $$DownloadedFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$DownloadedFilesTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$DownloadedFilesTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadedFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedFilesTable,
      DownloadedFile,
      $$DownloadedFilesTableFilterComposer,
      $$DownloadedFilesTableOrderingComposer,
      $$DownloadedFilesTableAnnotationComposer,
      $$DownloadedFilesTableCreateCompanionBuilder,
      $$DownloadedFilesTableUpdateCompanionBuilder,
      (DownloadedFile, $$DownloadedFilesTableReferences),
      DownloadedFile,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder =
    DownloadTasksCompanion Function({
      required String localTrackId,
      Value<String> state,
      Value<String> origin,
      Value<int> priority,
      Value<int> attempts,
      Value<int> receivedBytes,
      Value<int?> totalBytes,
      Value<String?> quality,
      Value<String?> lastError,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadTasksTableUpdateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<String> localTrackId,
      Value<String> state,
      Value<String> origin,
      Value<int> priority,
      Value<int> attempts,
      Value<int> receivedBytes,
      Value<int?> totalBytes,
      Value<String?> quality,
      Value<String?> lastError,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DownloadTasksTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask> {
  $$DownloadTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TracksTable _localTrackIdTable(_$AppDatabase db) =>
      db.tracks.createAlias('download_tasks__local_track_id__tracks__id');

  $$TracksTableProcessedTableManager get localTrackId {
    final $_column = $_itemColumn<String>('local_track_id')!;

    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localTrackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TracksTableFilterComposer get localTrackId {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TracksTableOrderingComposer get localTrackId {
    final $$TracksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableOrderingComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get receivedBytes => $composableBuilder(
    column: $table.receivedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TracksTableAnnotationComposer get localTrackId {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localTrackId,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTask,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (DownloadTask, $$DownloadTasksTableReferences),
          DownloadTask,
          PrefetchHooks Function({bool localTrackId})
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localTrackId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String?> quality = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion(
                localTrackId: localTrackId,
                state: state,
                origin: origin,
                priority: priority,
                attempts: attempts,
                receivedBytes: receivedBytes,
                totalBytes: totalBytes,
                quality: quality,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localTrackId,
                Value<String> state = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> receivedBytes = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String?> quality = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                localTrackId: localTrackId,
                state: state,
                origin: origin,
                priority: priority,
                attempts: attempts,
                receivedBytes: receivedBytes,
                totalBytes: totalBytes,
                quality: quality,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadTasksTable, DownloadTask>(table),
                  $$DownloadTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localTrackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localTrackId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.localTrackId,
                        referencedTable: $$DownloadTasksTableReferences
                            ._localTrackIdTable(db),
                        referencedColumn: $$DownloadTasksTableReferences
                            ._localTrackIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTask,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (DownloadTask, $$DownloadTasksTableReferences),
      DownloadTask,
      PrefetchHooks Function({bool localTrackId})
    >;
typedef $$AuthTokensTableCreateCompanionBuilder = AuthTokensCompanion Function({
  required String provider,
  required String accessToken,
  Value<String?> refreshToken,
  Value<String> tokenType,
  Value<int?> expiresAt,
  Value<String?> uid,
  Value<String?> login,
  Value<String?> displayName,
  Value<bool> hasPlus,
  Value<String> scopesCsv,
  Value<String?> extraJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AuthTokensTableUpdateCompanionBuilder = AuthTokensCompanion Function({
  Value<String> provider,
  Value<String> accessToken,
  Value<String?> refreshToken,
  Value<String> tokenType,
  Value<int?> expiresAt,
  Value<String?> uid,
  Value<String?> login,
  Value<String?> displayName,
  Value<bool> hasPlus,
  Value<String> scopesCsv,
  Value<String?> extraJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AuthTokensTableFilterComposer
    extends Composer<_$AppDatabase, $AuthTokensTable> {
  $$AuthTokensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenType => $composableBuilder(
    column: $table.tokenType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasPlus => $composableBuilder(
    column: $table.hasPlus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopesCsv => $composableBuilder(
    column: $table.scopesCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthTokensTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthTokensTable> {
  $$AuthTokensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenType => $composableBuilder(
    column: $table.tokenType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasPlus => $composableBuilder(
    column: $table.hasPlus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopesCsv => $composableBuilder(
    column: $table.scopesCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthTokensTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthTokensTable> {
  $$AuthTokensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refreshToken => $composableBuilder(
    column: $table.refreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tokenType =>
      $composableBuilder(column: $table.tokenType, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasPlus =>
      $composableBuilder(column: $table.hasPlus, builder: (column) => column);

  GeneratedColumn<String> get scopesCsv =>
      $composableBuilder(column: $table.scopesCsv, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AuthTokensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthTokensTable,
          AuthToken,
          $$AuthTokensTableFilterComposer,
          $$AuthTokensTableOrderingComposer,
          $$AuthTokensTableAnnotationComposer,
          $$AuthTokensTableCreateCompanionBuilder,
          $$AuthTokensTableUpdateCompanionBuilder,
          (
            AuthToken,
            BaseReferences<_$AppDatabase, $AuthTokensTable, AuthToken>,
          ),
          AuthToken,
          PrefetchHooks Function()
        > {
  $$AuthTokensTableTableManager(_$AppDatabase db, $AuthTokensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthTokensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthTokensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthTokensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> provider = const Value.absent(),
                Value<String> accessToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<String> tokenType = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> uid = const Value.absent(),
                Value<String?> login = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> hasPlus = const Value.absent(),
                Value<String> scopesCsv = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthTokensCompanion(
                provider: provider,
                accessToken: accessToken,
                refreshToken: refreshToken,
                tokenType: tokenType,
                expiresAt: expiresAt,
                uid: uid,
                login: login,
                displayName: displayName,
                hasPlus: hasPlus,
                scopesCsv: scopesCsv,
                extraJson: extraJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String provider,
                required String accessToken,
                Value<String?> refreshToken = const Value.absent(),
                Value<String> tokenType = const Value.absent(),
                Value<int?> expiresAt = const Value.absent(),
                Value<String?> uid = const Value.absent(),
                Value<String?> login = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<bool> hasPlus = const Value.absent(),
                Value<String> scopesCsv = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuthTokensCompanion.insert(
                provider: provider,
                accessToken: accessToken,
                refreshToken: refreshToken,
                tokenType: tokenType,
                expiresAt: expiresAt,
                uid: uid,
                login: login,
                displayName: displayName,
                hasPlus: hasPlus,
                scopesCsv: scopesCsv,
                extraJson: extraJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthTokensTable, AuthToken>(table),
                  BaseReferences<_$AppDatabase, $AuthTokensTable, AuthToken>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthTokensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthTokensTable,
      AuthToken,
      $$AuthTokensTableFilterComposer,
      $$AuthTokensTableOrderingComposer,
      $$AuthTokensTableAnnotationComposer,
      $$AuthTokensTableCreateCompanionBuilder,
      $$AuthTokensTableUpdateCompanionBuilder,
      (AuthToken, BaseReferences<_$AppDatabase, $AuthTokensTable, AuthToken>),
      AuthToken,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String valueJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> valueJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String valueJson,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                valueJson: valueJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ArtistsTableTableManager get artists =>
      $$ArtistsTableTableManager(_db, _db.artists);
  $$AlbumsTableTableManager get albums =>
      $$AlbumsTableTableManager(_db, _db.albums);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$TrackArtistsTableTableManager get trackArtists =>
      $$TrackArtistsTableTableManager(_db, _db.trackArtists);
  $$RemoteIdMappingsTableTableManager get remoteIdMappings =>
      $$RemoteIdMappingsTableTableManager(_db, _db.remoteIdMappings);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistTracksTableTableManager get playlistTracks =>
      $$PlaylistTracksTableTableManager(_db, _db.playlistTracks);
  $$LikesTableTableManager get likes =>
      $$LikesTableTableManager(_db, _db.likes);
  $$HistoryTableTableManager get history =>
      $$HistoryTableTableManager(_db, _db.history);
  $$QueueSnapshotsTableTableManager get queueSnapshots =>
      $$QueueSnapshotsTableTableManager(_db, _db.queueSnapshots);
  $$StreamResolutionsTableTableManager get streamResolutions =>
      $$StreamResolutionsTableTableManager(_db, _db.streamResolutions);
  $$TrackFailuresTableTableManager get trackFailures =>
      $$TrackFailuresTableTableManager(_db, _db.trackFailures);
  $$DownloadedFilesTableTableManager get downloadedFiles =>
      $$DownloadedFilesTableTableManager(_db, _db.downloadedFiles);
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$AuthTokensTableTableManager get authTokens =>
      $$AuthTokensTableTableManager(_db, _db.authTokens);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
