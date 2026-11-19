package com.example.treninkdenik.database;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.example.treninkdenik.model.Cvik;
import com.example.treninkdenik.model.Profil;
import com.example.treninkdenik.model.Serie;
import com.example.treninkdenik.model.Trenink;

import java.util.ArrayList;

// Třída pro práci s databází. Dědí z SQLiteOpenHelper, ten sám
// vytvoří databázi při prvním spuštění aplikace.
public class DbHelper extends SQLiteOpenHelper {

    public DbHelper(Context context) {
        // název souboru databáze, null, verze databáze
        super(context, "trenink_denik.db", null, 1);
    }

    // Zapne cizí klíče (v SQLite jsou ve výchozím stavu vypnuté).
    @Override
    public void onConfigure(SQLiteDatabase db) {
        super.onConfigure(db);
        db.setForeignKeyConstraintsEnabled(true);
    }

    // Spustí se jednou, když databáze ještě neexistuje. Vytvoří tabulky.
    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE profil ("
                + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "jmeno TEXT NOT NULL, "
                + "hmotnost REAL NOT NULL, "
                + "vyska REAL NOT NULL)");

        db.execSQL("CREATE TABLE cvik ("
                + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "nazev TEXT NOT NULL, "
                + "svalovaSkupina TEXT NOT NULL, "
                + "poznamka TEXT)");

        db.execSQL("CREATE TABLE trenink ("
                + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "datum INTEGER NOT NULL, "
                + "nazev TEXT NOT NULL, "
                + "poznamka TEXT)");

        // Tabulka serie odkazuje na trenink a cvik (cizí klíče).
        // ON DELETE CASCADE = po smazání tréninku nebo cviku se smažou i jeho série.
        db.execSQL("CREATE TABLE serie ("
                + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                + "treninkId INTEGER NOT NULL, "
                + "cvikId INTEGER NOT NULL, "
                + "poradi INTEGER NOT NULL, "
                + "vaha REAL NOT NULL, "
                + "opakovani INTEGER NOT NULL, "
                + "FOREIGN KEY (treninkId) REFERENCES trenink(id) ON DELETE CASCADE, "
                + "FOREIGN KEY (cvikId) REFERENCES cvik(id) ON DELETE CASCADE)");
    }

    // Spustí se při zvýšení verze databáze. Zatím tabulky smaže a vytvoří znovu.
    @Override
    public void onUpgrade(SQLiteDatabase db, int staraVerze, int novaVerze) {
        db.execSQL("DROP TABLE IF EXISTS serie");
        db.execSQL("DROP TABLE IF EXISTS trenink");
        db.execSQL("DROP TABLE IF EXISTS cvik");
        db.execSQL("DROP TABLE IF EXISTS profil");
        onCreate(db);
    }

    // ---------- CVIKY ----------

    // Přidá nový cvik. Id se nezadává, přidělí ho databáze.
    public void pridejCvik(Cvik cvik) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues hodnoty = new ContentValues();
        hodnoty.put("nazev", cvik.getNazev());
        hodnoty.put("svalovaSkupina", cvik.getSvalovaSkupina());
        hodnoty.put("poznamka", cvik.getPoznamka());
        db.insert("cvik", null, hodnoty);
    }

    // Vrátí seznam všech cviků seřazený podle názvu.
    public ArrayList<Cvik> nactiCviky() {
        ArrayList<Cvik> seznam = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.rawQuery("SELECT * FROM cvik ORDER BY nazev COLLATE NOCASE", null);
        // Cursor jde po řádcích výsledku. Čísla v závorkách jsou pořadí
        // sloupců v tabulce: 0 = id, 1 = nazev, 2 = svalovaSkupina, 3 = poznamka.
        while (c.moveToNext()) {
            seznam.add(new Cvik(c.getInt(0), c.getString(1),
                    c.getString(2), c.getString(3)));
        }
        c.close();
        return seznam;
    }

    // Upraví cvik podle jeho id.
    public void upravCvik(Cvik cvik) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues hodnoty = new ContentValues();
        hodnoty.put("nazev", cvik.getNazev());
        hodnoty.put("svalovaSkupina", cvik.getSvalovaSkupina());
        hodnoty.put("poznamka", cvik.getPoznamka());
        // Otazník se nahradí hodnotou z pole (id cviku).
        db.update("cvik", hodnoty, "id = ?",
                new String[]{String.valueOf(cvik.getId())});
    }

    // Smaže cvik podle id.
    public void smazCvik(int id) {
        SQLiteDatabase db = getWritableDatabase();
        db.delete("cvik", "id = ?", new String[]{String.valueOf(id)});
    }

    // ---------- PROFIL ----------

    // Vrátí profil, nebo null, když ještě žádný neexistuje.
    public Profil nactiProfil() {
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.rawQuery("SELECT * FROM profil LIMIT 1", null);
        Profil profil = null;
        if (c.moveToFirst()) {
            profil = new Profil(c.getInt(0), c.getString(1),
                    c.getDouble(2), c.getDouble(3));
        }
        c.close();
        return profil;
    }

    // Když má profil id 0, vloží se nový, jinak se upraví existující.
    public void ulozProfil(Profil profil) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues hodnoty = new ContentValues();
        hodnoty.put("jmeno", profil.getJmeno());
        hodnoty.put("hmotnost", profil.getHmotnost());
        hodnoty.put("vyska", profil.getVyska());
        if (profil.getId() == 0) {
            db.insert("profil", null, hodnoty);
        } else {
            db.update("profil", hodnoty, "id = ?",
                    new String[]{String.valueOf(profil.getId())});
        }
    }

    // ---------- TRENINKY A SERIE ----------

    // Přidá trénink a vrátí jeho nové id (budeme ho potřebovat u sérií).
    public int pridejTrenink(Trenink trenink) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues hodnoty = new ContentValues();
        hodnoty.put("datum", trenink.getDatum());
        hodnoty.put("nazev", trenink.getNazev());
        hodnoty.put("poznamka", trenink.getPoznamka());
        return (int) db.insert("trenink", null, hodnoty);
    }

    // Nejnovější tréninky jsou první (DESC = sestupně).
    public ArrayList<Trenink> nactiTreninky() {
        ArrayList<Trenink> seznam = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.rawQuery("SELECT * FROM trenink ORDER BY datum DESC", null);
        while (c.moveToNext()) {
            seznam.add(new Trenink(c.getInt(0), c.getLong(1),
                    c.getString(2), c.getString(3)));
        }
        c.close();
        return seznam;
    }

    public void pridejSerii(Serie serie) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues hodnoty = new ContentValues();
        hodnoty.put("treninkId", serie.getTreninkId());
        hodnoty.put("cvikId", serie.getCvikId());
        hodnoty.put("poradi", serie.getPoradi());
        hodnoty.put("vaha", serie.getVaha());
        hodnoty.put("opakovani", serie.getOpakovani());
        db.insert("serie", null, hodnoty);
    }

    // Vrátí série jednoho tréninku v pořadí, v jakém se cvičily.
    public ArrayList<Serie> nactiSerie(int treninkId) {
        ArrayList<Serie> seznam = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.rawQuery("SELECT * FROM serie WHERE treninkId = ? ORDER BY poradi",
                new String[]{String.valueOf(treninkId)});
        while (c.moveToNext()) {
            seznam.add(new Serie(c.getInt(0), c.getInt(1), c.getInt(2),
                    c.getInt(3), c.getDouble(4), c.getInt(5)));
        }
        c.close();
        return seznam;
    }
}