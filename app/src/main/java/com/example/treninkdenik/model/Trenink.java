package com.example.treninkdenik.model;

// Jeden trénink. Obsahuje víc sérií.
public class Trenink {
    private int id;
    private long datum; // datum jako počet milisekund od roku 1970
    private String nazev;
    private String poznamka;

    public Trenink(int id, long datum, String nazev, String poznamka) {
        this.id = id;
        this.datum = datum;
        this.nazev = nazev;
        this.poznamka = poznamka;
    }

    public int getId() { return id; }
    public long getDatum() { return datum; }
    public String getNazev() { return nazev; }
    public String getPoznamka() { return poznamka; }
}