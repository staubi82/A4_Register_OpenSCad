# A4 Register – OpenSCAD

Parametrisierbares OpenSCAD-Projekt für **A4‑Registerblätter** mit Tabs, Wabenmuster, Titel‑Kachel und Multicolor‑(Flush‑)Inlays. Inklusive **Batch‑Generator**, **seitenweiter Abrundung**, **stabiles Kachel‑Halo**, und **variabler Inlay‑Tiefe**.

---

## Highlights

* **A4‑Seite** mit 2‑/4‑Loch (DIN)
* **Tabs** rechts oder oben, **nur äußere Ecken** rundbar (oder alle 4 optional)
* **Wabenmuster** mit geschützten Zonen (Löcher, Tab, Kachel)
* **Titel‑Kachel** mit **innenliegendem Rahmen** (fasst nicht die Waben ein)
* **Halo um die Kachel** (Vollmaterial‑Sicherheitszone gegen Ausbrechen)
* **Flush‑Inlay** mit **getrennter Tiefe** für **Text** und **Rahmen**
* **Separate Bodies** (Platte / Text / Rahmen) → einfache Farbzuteilung im Slicer
* **Batch‑Ausgabe** (Raster) mit **tab‑sicherem Abstand** und Schalter `batch_enable`
* **Seitenaußenkante abgerundet** (`page_r`) – Rahmen/Waben folgen der Rundung

---

## Wichtige Parameter (Auszug)

### Seite & Löcher

* `page_w = 210;`, `page_h = 297;` – A4
* `page_r = 5;` – **neuer Außenradius** (0 = eckig)
* `punch_edge = 12;`, `hole_d = 6;`, `holes = 2|4;`, `hole_spacing = 80;`

### Tab

* `tab_side = "right" | "top"`
* `tab_w = 20;`, `tab_h = 70;`
* `num_registers = 7;` – steuert Auto‑Verteilung der Tab‑Positionen
* `tab_r = 3;` – Rundungsradius
* `tab_round_inner = false;` – **false = nur äußere Ecken**, true = alle 4

### Titel‑Kachel & Rahmen

* `title_tile_enable = true;`
* **Standard‑Offsets:** `title_tile_top = 48.9;`, `title_tile_left = 14;`, `title_tile_right = 15;`, `title_tile_h = 40;`, `title_tile_r = 3;`
* `title_tile_border = true;`, `title_tile_bw = 1;` – **innenliegender** Rahmen
* `honey_clear_tile = 2.5;` – **Halo** (mm) um die Kachel → keine Waben dort

### Text / Fonts

* `label_text = "Volksbank";` – Default; alternativ `label_list=["A","B",...]` für Batch
* `text_size = 7;`, `title_size = 20;`, `text_rotation_deg = 90;`
* `font_set_num = 1;` oder `font_name = "..."`

### Waben

* `honeycomb_enable = true;`
* `frame_w = 10;` – Außenrahmen (Vollmaterial) in mm
* `cell_radius = 6;`, `hc_shrink = 1;` – Zellgröße / Stegdicke
* `honey_clear_tab = 1.5;`, `honey_clear_hole = 6;`

### Inlay (Multicolor)

* `inlay_mode = "flush_inlay" | "engrave" | "emboss"`
* **Seitliches Spiel:** `inlay_gap_text = 0.06;`, `inlay_gap_border = 0.06;`
* **Tiefe:** `inlay_depth_text = 0.6;`, `inlay_depth_border = 0.6;`
  (0..`thickness`, Vielfache der Layerhöhe empfohlen)
* **Farben (3MF/AMF):** `plate_color`, `text_color`, `border_color`

### Batch‑Layout (Mehrere Blätter in einer Datei)

* `batch_enable = true|false` – **Schalter** (Multi vs. Einzelblatt)
* `batch_count = 7;`, `batch_cols = 3;`
* `batch_gap_x = 12;`, `batch_gap_y = 8;` – Abstände **inkl. Tab** (tab‑sicher)

---

## Nutzung

1. **OpenSCAD öffnen**, Datei laden (z. B. „A4‑Register – Rand‑Rundung + variable Tiefe (kompilierbar)“).
2. Oben die **Parameter** anpassen (Tab‑Seite, Rundungen, Texte, Kachel, Waben, Inlay etc.).
3. **Rendern** (`F6`) und als **3MF/AMF** (für Multicolor) oder **STL** exportieren.
4. Im **Slicer** Bodies den gewünschten **Farben/Extrudern** zuordnen.

### Batch‑Beispiele

* **Einzelblatt:** `batch_enable=false;` → rendert `register_index`
* **7 Register, 3 Spalten:** `batch_enable=true; batch_count=7; batch_cols=3;`
* **Kein Tab‑Überlappen:** `batch_gap_x` ggf. erhöhen (z. B. 12–15 mm)
* **Eigene Labels pro Blatt:** `label_list=["Bank","Versicherung",...]`

---

## Stabilität & Drucktipps

* **Kachel bricht aus?** `honey_clear_tile=2.5` (oder 3.0), ggf. `thickness=1.0–1.2`, `cell_radius` kleiner (5–6), `hc_shrink` erhöhen (1.5–2.0)
* **Slicer:** 3+ Perimeter, 4–5 Top/Bottom‑Layer, ggf. +5 °C Nozzle
* **Flush‑Inlay‑Tiefe:** Vielfache der Layerhöhe wählen (0.4/0.6/0.8 bei 0.2 mm)
* **Coplanar‑Warnung:** Bei planem Flush‑Inlay sind mehrere Bodies auf gleicher Z‑Ebene → Manche Tools warnen. Funktional OK. Auf Wunsch minimale Z‑Staffelung ±0.01 mm einbauen.

---

## Changelog

* **2025‑08‑12**
  ‑ `page_r` (abgerundete Seitenaußenkante)
  ‑ `honey_clear_tile` (Halo um Kachel)
  ‑ `inlay_depth_text` / `inlay_depth_border` (variable Flush‑Inlay‑Tiefe)
  ‑ Batch‑Raster tab‑sicher (`batch_gap_x/y`, `sheet_w/h`)
  ‑ Nur äußere Tab‑Ecken rundbar; `tab_round_inner` optional für alle 4
  ‑ Standard‑Kachel‑Offsets: `top=48.9`, `left=14`, `right=15`, `h=40`

---

## Lizenz

MIT License – frei nutzbar, Änderungen erlaubt.

---

## Credits & Hinweise

* Entwickelt für **0.4 mm Nozzle / 0.2 mm Layer**; Parameter sind offen.
* Für MMU/Farbwechsel **3MF/AMF** exportieren (separate Bodies).
