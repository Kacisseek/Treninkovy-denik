package com.example.treninkdenik.model;

// Profil uživatele.
public class Profil {
    private int id;
    private String jmeno;
    private double hmotnost; // kg
    private double vyska;    // cm

    public Profil(int id, String jmeno, double hmotnost, double vyska) {
        this.id = id;
        this.jmeno = jmeno;
        this.hmotnost = hmotnost;
        this.vyska = vyska;
    }

    public int getId() { return id; }
    public String getJmeno() { return jmeno; }
    public double getHmotnost() { return hmotnost; }
    public double getVyska() { return vyska; }
}