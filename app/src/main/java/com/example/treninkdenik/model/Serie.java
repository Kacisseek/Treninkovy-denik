package com.example.treninkdenik.model;

// Jedna série: váha a počet opakování u jednoho cviku v jednom tréninku.
public class Serie {
    private int id;
    private int treninkId; // ke kterému tréninku série patří
    private int cvikId;    // který cvik se cvičil
    private int poradi;    // která série to byla (1., 2., 3.)
    private double vaha;   // v kg
    private int opakovani;

    public Serie(int id, int treninkId, int cvikId, int poradi,
                 double vaha, int opakovani) {
        this.id = id;
        this.treninkId = treninkId;
        this.cvikId = cvikId;
        this.poradi = poradi;
        this.vaha = vaha;
        this.opakovani = opakovani;
    }

    public int getId() { return id; }
    public int getTreninkId() { return treninkId; }
    public int getCvikId() { return cvikId; }
    public int getPoradi() { return poradi; }
    public double getVaha() { return vaha; }
    public int getOpakovani() { return opakovani; }
}