import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cvik.dart';
import '../models/profil.dart';
import '../models/serie.dart';
import '../models/trenink.dart';

class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _otevri();
    return _db!;
  }

  Future<Database> _otevri() async {
    final cesta = join(await getDatabasesPath(), 'trenink_denik.db');
    return openDatabase(
      cesta,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, verze) async {
        await db.execute('''
          CREATE TABLE profil (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jmeno TEXT NOT NULL,
            hmotnost REAL NOT NULL,
            vyska REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cvik (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nazev TEXT NOT NULL,
            svalovaSkupina TEXT NOT NULL,
            poznamka TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE trenink (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            datum TEXT NOT NULL,
            nazev TEXT NOT NULL,
            poznamka TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE serie (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            treninkId INTEGER NOT NULL,
            cvikId INTEGER NOT NULL,
            poradi INTEGER NOT NULL,
            vaha REAL NOT NULL,
            opakovani INTEGER NOT NULL,
            FOREIGN KEY (treninkId) REFERENCES trenink(id) ON DELETE CASCADE,
            FOREIGN KEY (cvikId) REFERENCES cvik(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ---------- CVIKY ----------
  Future<int> pridejCvik(Cvik c) async {
    final db = await database;
    return db.insert('cvik', c.toMap()..remove('id'));
  }

  Future<List<Cvik>> nactiCviky() async {
    final db = await database;
    final data = await db.query('cvik', orderBy: 'nazev COLLATE NOCASE');
    return data.map(Cvik.fromMap).toList();
  }

  Future<int> upravCvik(Cvik c) async {
    final db = await database;
    return db.update('cvik', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> smazCvik(int id) async {
    final db = await database;
    return db.delete('cvik', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- PROFIL ----------
  Future<Profil?> nactiProfil() async {
    final db = await database;
    final data = await db.query('profil', limit: 1);
    return data.isEmpty ? null : Profil.fromMap(data.first);
  }

  Future<void> ulozProfil(Profil p) async {
    final db = await database;
    if (p.id == null) {
      await db.insert('profil', p.toMap()..remove('id'));
    } else {
      await db.update('profil', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    }
  }

  // ---------- TRENINKY A SERIE ----------
  Future<int> pridejTrenink(Trenink t) async {
    final db = await database;
    return db.insert('trenink', t.toMap()..remove('id'));
  }

  Future<List<Trenink>> nactiTreninky() async {
    final db = await database;
    final data = await db.query('trenink', orderBy: 'datum DESC');
    return data.map(Trenink.fromMap).toList();
  }

  Future<int> pridejSerii(Serie s) async {
    final db = await database;
    return db.insert('serie', s.toMap()..remove('id'));
  }

  Future<List<Serie>> nactiSerie(int treninkId) async {
    final db = await database;
    final data = await db.query('serie',
        where: 'treninkId = ?', whereArgs: [treninkId], orderBy: 'poradi');
    return data.map(Serie.fromMap).toList();
  }
}