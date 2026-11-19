package com.example.treninkdenik.model;

// Jeden cvik v katalogu (např. Bench press, hrudník).
public class Cvik {
    private int id; // 0 = ještě není uložený v databázi
    private String nazev;
    private String svalovaSkupina;
    private String poznamka;

    public Cvik(int id, String nazev, String svalovaSkupina, String poznamka) {
        this.id = id;
        this.nazev = nazev;
        this.svalovaSkupina = svalovaSkupina;
        this.poznamka = poznamka;
    }

    public int getId() { return id; }
    public String getNazev() { return nazev; }
    public String getSvalovaSkupina() { return svalovaSkupina; }
    public String getPoznamka() { return poznamka; }
}