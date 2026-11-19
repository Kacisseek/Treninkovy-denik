package com.example.treninkdenik;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.treninkdenik.database.DbHelper;
import com.example.treninkdenik.model.Cvik;

// Formulář pro přidání nového cviku nebo úpravu existujícího.
public class CvikFormularActivity extends AppCompatActivity {

    private EditText etNazev, etSkupina, etPoznamka;
    private int cvikId = 0; // 0 = přidáváme nový, jinak upravujeme

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_cvik_formular);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        etNazev = findViewById(R.id.etNazev);
        etSkupina = findViewById(R.id.etSkupina);
        etPoznamka = findViewById(R.id.etPoznamka);
        Button btnUlozit = findViewById(R.id.btnUlozit);

        // Zjistíme, jestli nám seznam poslal data cviku (= úprava).
        Intent intent = getIntent();
        cvikId = intent.getIntExtra("id", 0);
        if (cvikId != 0) {
            setTitle("Upravit cvik");
            etNazev.setText(intent.getStringExtra("nazev"));
            etSkupina.setText(intent.getStringExtra("skupina"));
            etPoznamka.setText(intent.getStringExtra("poznamka"));
        } else {
            setTitle("Nový cvik");
        }

        btnUlozit.setOnClickListener(v -> ulozCvik());
    }

    private void ulozCvik() {
        // trim() odstraní mezery na začátku a na konci.
        String nazev = etNazev.getText().toString().trim();
        String skupina = etSkupina.getText().toString().trim();
        String poznamka = etPoznamka.getText().toString().trim();

        // Kontrola vstupů: povinná pole nesmí být prázdná.
        if (nazev.isEmpty()) {
            etNazev.setError("Zadej název cviku");
            return;
        }
        if (skupina.isEmpty()) {
            etSkupina.setError("Zadej svalovou skupinu");
            return;
        }

        Cvik cvik = new Cvik(cvikId, nazev, skupina, poznamka);
        DbHelper db = new DbHelper(this);
        if (cvikId == 0) {
            db.pridejCvik(cvik);
        } else {
            db.upravCvik(cvik);
        }

        finish(); // zavře formulář a vrátí se na seznam
    }
}