# A4 Register (OpenSCAD)

Dieses Projekt enthält ein parametrisierbares OpenSCAD-Skript zum Erstellen von **A4-Registern** mit Tabs, Wabenmuster, Titel-Kachel und optionalen Beschriftungen.

## Features

* **A4-Grundform** mit 2- oder 4-Loch-Punch (DIN)
* **Tabs** seitlich oder oben, **abrundbar** (nur äußere Ecken oder alle)
* **Wabenmuster** zum Material sparen, mit Aussparungen für Löcher, Tab und Kachel
* **Titel-Kachel** mit innenliegendem Rahmen (keine Waben im Bereich)
* **Beschriftungen** für Tab und Titel (beliebige Schriftarten)
* **Multicolor-Unterstützung** für MMU / FLUSH-INLAY
* **Separat exportierbare Bodies** für Grundplatte, Text und Rahmen (Farbwechsel im Slicer)

## Parameter (Auszug)

| Parameter          | Beschreibung                                              |
| ------------------ | --------------------------------------------------------- |
| `thickness`        | Plattendicke in mm                                        |
| `holes`            | 2 oder 4 Löcher (DIN)                                     |
| `tab_side`         | "right" oder "top"                                        |
| `tab_r`            | Abrundungsradius der Tab-Ecken                            |
| `tab_round_inner`  | `true` = alle Ecken rund, `false` = nur äußere Ecken rund |
| `label_text`       | Beschriftungstext                                         |
| `honeycomb_enable` | Wabenmuster aktivieren/deaktivieren                       |
| `inlay_mode`       | "engrave", "emboss" oder "flush\_inlay"                   |
| `inlay_gap`        | Spiel für Inlay-Teile (mm)                                |

## Verwendung

1. **Datei in OpenSCAD öffnen**
2. Parameter anpassen (Tab-Position, Beschriftung, Maße, etc.)
3. Rendern (`F6`) und als STL/3MF/AMF exportieren
4. Bei Multicolor: 3MF/AMF nutzen, damit der Slicer die Bodies als separate Farben erkennt

## Export-Tipps für Multicolor

* **Flush-Inlay** nutzen für plan liegende Mehrfarbenflächen
* Im Slicer die **Bodies** jeweils einem Extruder/Farbwechsel zuweisen
* Falls notwendig, Spiel (`inlay_gap`) anpassen, um einen sauberen Sitz zu erhalten

## Beispiele

* **Seitlicher Tab mit Beschriftung**, 2-Loch DIN, Wabenmuster an, Titel-Kachel mit Rahmen und Flush-Inlay-Text
* **Oberer Tab**, alle Ecken rund, ohne Wabenmuster, nur Gravur-Beschriftung

## Lizenz

MIT License – frei nutzbar, Änderungen erlaubt
