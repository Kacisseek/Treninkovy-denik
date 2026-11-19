    package com.example.treninkdenik;

import android.os.Bundle;
import android.util.Log;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.treninkdenik.database.DbHelper;
import com.example.treninkdenik.model.Cvik;

    public class MainActivity extends AppCompatActivity {

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
        // DOČASNÝ TEST databáze, po ověření smazat.
        DbHelper db = new DbHelper(this);
        db.pridejCvik(new Cvik(0, "Bench press", "hrudník", ""));
        Log.d("DB", "Počet cviků: " + db.nactiCviky().size());
    }
}