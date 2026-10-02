import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/cvik.dart';
import '../models/profil.dart';
import '../models/serie.dart';
import '../models/trenink.dart';

// DbHelper je jediné místo v aplikaci, které komunikuje s databází.
// Obrazovky volají jeho metody a o SQL se nestarají.
class DbHelper {
  // SINGLETON: privátní konstruktor DbHelper._() zabrání vytváření
  // dalších objektů. Existuje jen DbHelper.instance, takže celá
  // aplikace používá jedno jediné připojení k databázi.
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  // Samotné připojení. Na začátku je null (databáze ještě není otevřená).
  static Database? _db;

  // Getter, který vrátí databázi. Future + async = práce s databází
  // trvá, a aby aplikace nezamrzla, počká se na výsledek přes await.
  Future<Database> get database async {
    // ??= znamená: "pokud je _db null, otevři ji a ulož".
    // Databáze se tak otevře jen jednou, při prvním použití.
    _db ??= await _otevri();
    return _db!; // ! = jistota, že už null není
  }

  Future<Database> _otevri() async {
    // Soubor databáze se uloží do interního úložiště aplikace.
    final cesta = join(await getDatabasesPath(), 'trenink_denik.db');
    return openDatabase(
      cesta,
      version: 1, // verze schématu, při změně tabulek se zvyšuje
      onConfigure: (db) async {
        // V SQLite jsou cizí klíče ve výchozím stavu vypnuté.
        // Bez tohoto řádku by nefungovalo ON DELETE CASCADE.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // onCreate se spustí jen jednou, když databáze ještě neexistuje.
      onCreate: (db, verze) async {
        // PRIMARY KEY AUTOINCREMENT = id si databáze přidělí sama.
        // NOT NULL = hodnota je povinná.
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
        // Tabulka serie propojuje trenink a cvik pomocí cizích klíčů.
        // ON DELETE CASCADE = smazání tréninku (nebo cviku) automaticky
        // smaže i jeho série, aby v databázi nezůstaly "osiřelé" řádky.
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

  // ---------- CVIKY (CRUD) ----------

  // CREATE: vloží nový cvik. Vrací id nově vloženého řádku.
  Future<int> pridejCvik(Cvik c) async {
    final db = await database;
    // ..remove('id') odstraní id z mapy, ať si ho databáze přidělí sama.
    return db.insert('cvik', c.toMap()..remove('id'));
  }

  // READ: načte všechny cviky seřazené podle názvu (bez ohledu na velikost písmen).
  Future<List<Cvik>> nactiCviky() async {
    final db = await database;
    final data = await db.query('cvik', orderBy: 'nazev COLLATE NOCASE');
    // Každý řádek (mapu) převede na objekt Cvik.
    return data.map(Cvik.fromMap).toList();
  }

  // UPDATE: upraví cvik podle id. Vrací počet změněných řádků.
  Future<int> upravCvik(Cvik c) async {
    final db = await database;
    // "?" se nahradí hodnotou z whereArgs. Je to bezpečnější než
    // skládání textu (chrání proti SQL injection).
    return db.update('cvik', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  // DELETE: smaže cvik podle id (včetně jeho sérií díky CASCADE).
  Future<int> smazCvik(int id) async {
    final db = await database;
    return db.delete('cvik', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- PROFIL ----------

  // Vrátí profil, nebo null, pokud ještě žádný neexistuje (Profil?).
  Future<Profil?> nactiProfil() async {
    final db = await database;
    final data = await db.query('profil', limit: 1);
    return data.isEmpty ? null : Profil.fromMap(data.first);
  }

  // Uloží profil: bez id = vloží nový, s id = upraví existující.
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

  // Nejnovější tréninky první (DESC = sestupně).
  Future<List<Trenink>> nactiTreninky() async {
    final db = await database;
    final data = await db.query('trenink', orderBy: 'datum DESC');
    return data.map(Trenink.fromMap).toList();
  }

  Future<int> pridejSerii(Serie s) async {
    final db = await database;
    return db.insert('serie', s.toMap()..remove('id'));
  }

  // Načte série jednoho tréninku v pořadí, v jakém byly odcvičené.
  Future<List<Serie>> nactiSerie(int treninkId) async {
    final db = await database;
    final data = await db.query('serie',
        where: 'treninkId = ?', whereArgs: [treninkId], orderBy: 'poradi');
    return data.map(Serie.fromMap).toList();
  }
}