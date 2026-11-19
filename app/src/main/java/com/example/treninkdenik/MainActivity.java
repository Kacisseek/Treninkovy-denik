package com.example.treninkdenik;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.treninkdenik.database.DbHelper;
import com.example.treninkdenik.model.Cvik;

import java.util.ArrayList;

// Obrazovka se seznamem cviků.
public class MainActivity extends AppCompatActivity {

    private DbHelper db;
    private ListView lvCviky;
    private TextView tvPrazdno;
    private ArrayList<Cvik> cviky; // aktuální seznam načtený z databáze

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        db = new DbHelper(this);
        lvCviky = findViewById(R.id.lvCviky);
        tvPrazdno = findViewById(R.id.tvPrazdno);
        Button btnPridat = findViewById(R.id.btnPridat);

        // Tlačítko Přidat otevře formulář bez dat (nový cvik).
        btnPridat.setOnClickListener(v -> {
            Intent intent = new Intent(this, CvikFormularActivity.class);
            startActivity(intent);
        });

        // Klepnutí na cvik otevře formulář a předá mu data cviku (úprava).
        lvCviky.setOnItemClickListener((parent, view, position, id) -> {
            Cvik cvik = cviky.get(position);
            Intent intent = new Intent(this, CvikFormularActivity.class);
            intent.putExtra("id", cvik.getId());
            intent.putExtra("nazev", cvik.getNazev());
            intent.putExtra("skupina", cvik.getSvalovaSkupina());
            intent.putExtra("poznamka", cvik.getPoznamka());
            startActivity(intent);
        });

        // Dlouhé podržení zobrazí dialog s potvrzením smazání.
        lvCviky.setOnItemLongClickListener((parent, view, position, id) -> {
            Cvik cvik = cviky.get(position);
            new AlertDialog.Builder(this)
                    .setTitle("Smazat cvik?")
                    .setMessage("Cvik \"" + cvik.getNazev() + "\" bude smazán "
                            + "včetně všech jeho sérií.")
                    .setPositiveButton("Smazat", (dialog, which) -> {
                        db.smazCvik(cvik.getId());
                        nactiSeznam();
                    })
                    .setNegativeButton("Zrušit", null)
                    .show();
            return true; // true = událost je vyřízená
        });
    }

    // onResume se zavolá pokaždé, když se obrazovka zobrazí, i po návratu
    // z formuláře. Proto se tady seznam znovu načte z databáze.
    @Override
    protected void onResume() {
        super.onResume();
        nactiSeznam();
    }

    private void nactiSeznam() {
        cviky = db.nactiCviky();

        // Do seznamu na obrazovce dáme jen texty (název a svalová skupina).
        ArrayList<String> texty = new ArrayList<>();
        for (Cvik c : cviky) {
            texty.add(c.getNazev() + " (" + c.getSvalovaSkupina() + ")");
        }
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_list_item_1, texty);
        lvCviky.setAdapter(adapter);

        // Prázdný seznam: ukaž vysvětlující text.
        if (cviky.isEmpty()) {
            tvPrazdno.setVisibility(View.VISIBLE);
        } else {
            tvPrazdno.setVisibility(View.GONE);
        }
    }
}