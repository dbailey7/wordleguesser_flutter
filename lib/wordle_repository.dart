import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class WordResult {
  final String word;
  final int? rank;
  const WordResult(this.word, this.rank);
}

class WordleRepository {
  static const _dbAssetPath = 'assets/wordlist.db';
  static const _dbFileName = 'wordlist.db';

  Database? _db;

  Future<Database> _openDb() async {
    final existing = _db;
    if (existing != null) return existing;

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, _dbFileName);

    if (!await File(dbPath).exists()) {
      final bytes = await rootBundle.load(_dbAssetPath);
      await File(dbPath).writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    }

    final db = await openDatabase(dbPath, readOnly: true);
    _db = db;
    return db;
  }

  Future<List<WordResult>> getGuesses({
    required int wordLength,
    required Map<int, String> greenLetters,
    required Map<int, Set<String>> yellowLetters,
    required Set<String> blackLetters,
  }) async {
    final db = await _openDb();

    final conditions = <String>[];
    final args = <Object?>[];

    conditions.add('LENGTH(headword) = ?');
    args.add(wordLength);

    for (final entry in greenLetters.entries) {
      conditions.add('LOWER(SUBSTR(headword, ?, 1)) = ?');
      args.add(entry.key);
      args.add(entry.value.toLowerCase());
    }

    // Each letter marked yellow at a position must appear in the word but
    // NOT at that position — a position can have more than one such letter
    // (different guesses can each rule out a different letter for the same
    // spot).
    for (final entry in yellowLetters.entries) {
      for (final letter in entry.value) {
        conditions.add('LOWER(SUBSTR(headword, ?, 1)) != ?');
        args.add(entry.key);
        args.add(letter.toLowerCase());
        conditions.add('LOWER(headword) LIKE ?');
        args.add('%${letter.toLowerCase()}%');
      }
    }

    for (final letter in blackLetters) {
      conditions.add('LOWER(headword) NOT LIKE ?');
      args.add('%${letter.toLowerCase()}%');
    }

    conditions.add("headword NOT LIKE '%.%'");
    conditions.add("headword NOT LIKE '%-%'");

    final where = conditions.join(' AND ');
    final query = '''
      SELECT headword, rank FROM wordlist
      WHERE $where
      ORDER BY CASE WHEN rank IS NULL THEN 1 ELSE 0 END, rank
    ''';

    final rows = await db.rawQuery(query, args);
    return rows
        .map((row) => WordResult(row['headword'] as String, row['rank'] as int?))
        .toList();
  }
}
