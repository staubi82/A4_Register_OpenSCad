// A4-Register (OpenSCAD)
// Tab (quer), 2/4-Loch, Wabenmuster, Titel-Kachel mit INNEN-Rahmen
// FLUSH-INLAY (plan), separate Bodies: Platte, Text, Rahmen (für Farben/Extruder)
// Optimiert für 0.4 mm Nozzle & 0.2 mm Layer
// ---------------------------------------------------------------------

// =================== BASIS ===================
thickness   = 0.8;  // Mindesthöhe bei 0.2 mm Layer
page_w      = 210;  // A4 Breite (mm)
page_h      = 297;  // A4 Höhe (mm)

// Lochreihe (DIN)
punch_edge  = 12;   // Abstand linker Rand -> Lochmitte (mm)
hole_d      = 6;    // Loch-Ø (mm)
holes       = 4;    // 2 oder 4
hole_spacing= 80;   // 2-Loch: 80 mm; 4-Loch: 80-80-80

// Register / Tab
tab_w       = 20;   // Reiter-Breite (ragt rechts raus)
tab_h       = 70;   // Reiter-Höhe
tab_side    = "right"; // "right" (empfohlen) oder "top"
tab_margin  = 0;    // Verteilrand oben/unten (0 = durchgehend)
num_registers  = 7; // Gesamtzahl Register
register_index = 1; // Index dieses Registers (1..n)

// Tabs abrunden
// 0 = eckig; >0 = Radius. Nur die freien Außenkanten werden gerundet,
// außer du setzt tab_round_inner=true (dann alle vier Ecken).
tab_r = 3;
tab_round_inner = false;

// Beschriftung (ein Feld für Tab + Titel)
label_text  = "Dokumente"; // ⇦ einmal setzen
text_rotation_deg = 90;         // Quer auf dem Tab (90 = seitlich lesbar)

// Schriftarten
font_name    = "DejaVu Sans:style=Bold"; // Fallback-Font
font_set_num = 1;  // 1..10 – wählt aus font_list; 0 = benutze font_name
font_list = [
  "DejaVu Sans:style=Bold",
  "DejaVu Serif:style=Bold",
  "Liberation Sans:style=Bold",
  "Liberation Serif:style=Bold",
  "Nimbus Sans L:style=Bold",
  "Nimbus Roman:style=Bold",
  "FreeSans:style=Bold",
  "FreeSerif:style=Bold",
  "URW Gothic L:style=Demi",
  "Ubuntu:style=Bold"
];

// Tab-Text
text_size   = 7;   // Tab-Schriftgröße (mm)
text_depth  = 0.4; // für "engrave"/"emboss"

// Titel + Kachel
show_title       = true; // Überschrift anzeigen
title_size       = 20;   // Überschrift-Schriftgröße (mm)
title_depth      = 0.4;  // für "engrave"/"emboss"

// Kachel (Vollmaterial) im Wabenfeld
title_tile_enable = true; // Kachel aktiv
title_tile_top    = 50;   // Abstand Oberkante Seite -> Kachel-Oberkante (mm)
title_tile_left   = 15;   // Abstand links (mm)
title_tile_right  = 15;   // Abstand rechts (mm)
title_tile_h      = 30;   // Kachel-Höhe (mm)
title_tile_r      = 3;    // Eckenradius (mm)

// Rahmen der Kachel (liegt NUR innerhalb der Kachel)
title_tile_border = true; // Rahmen anzeigen
title_tile_bw     = 2;    // Rahmenbreite (mm) – innenliegend

// Wabenmuster (Material sparen)
honeycomb_enable = true; // Waben ein/aus
frame_w          = 10;   // Außenrahmen stehen lassen (mm)
honey_clear_tab  = 1.5;  // Puffer um den Tab (mm)
honey_clear_hole = 6;    // Puffer um Löcher (mm)
cell_radius      = 6;    // Hexagon-"Radius" (~Zellgröße)
hc_shrink        = 1;    // kleiner machen für stärkere Stege

// ====== FLUSH-INLAY / MULTICOLOR ======
// Modus: "engrave" | "emboss" | "flush_inlay"
inlay_mode   = "flush_inlay";     // plan + getrennte Bodies (für MMU)

// Inlay-Spiel separat für Text & Rahmen
inlay_gap_text   = 0.06;  // seitliches Spiel (mm)
inlay_gap_border = 0.06;  // seitliches Spiel (mm)

// Farben (AMF/3MF)
plate_color  = [1,1,1,1];          // Extruder 1
text_color   = [0,0,0,1];          // Extruder 2
border_color = [0,0,0,1];          // Extruder 3 (optional)

$fn = 48;

// =================== HILFSFUNKTIONEN ===================
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
function use_font() = (font_set_num>=1 && font_set_num<=len(font_list)) ? font_list[font_set_num-1] : font_name;

function tab_y_pos(num, idx, tab_h, margin, page_h) =
    let(n=max(1,num), ii=clamp(idx,1,n), usable=page_h-2*margin,
        step=(n==1)?0:(usable-tab_h)/(n-1), top_y = page_h - margin - tab_h)
    top_y - (ii-1)*step;

// Titel-Kachel-Geometrie (2D helpers)
function title_tile_x0() = title_tile_left;
function title_tile_x1() = page_w - title_tile_right;
function title_tile_y1() = page_h - title_tile_top;
function title_tile_y0() = title_tile_y1() - title_tile_h;

// =================== GRUNDFORMEN ===================
module divider_plate(){ square([page_w, page_h], center=false); }

module ring_holes(){
  translate([punch_edge, page_h/2]) {
    if (holes==2){
      for (y=[-hole_spacing/2, hole_spacing/2]) translate([0,y]) circle(d=hole_d);
    } else {
      base = hole_spacing/2; // 40 -> -120,-40,40,120
      for (y=[-3*base,-1*base,1*base,3*base]) translate([0,y]) circle(d=hole_d);
    }
  }
}

function tab_pos_right(idx) = [page_w, tab_y_pos(num_registers, idx, tab_h, tab_margin, page_h)];
function tab_pos_top(idx)   = let(n=max(1,num_registers), ii=clamp(idx,1,n), usable=page_w-2*tab_margin, step=(n==1)?0:(usable-tab_w)/(n-1), tx=tab_margin+(ii-1)*step) [tx, page_h];

// Helper: Rundrechteck am Ursprung (0,0) mit Breite/Höhe (flächentreu)
module roundrect_wh(w,h,r=0){
  if (r <= 0) square([w,h]);
  else offset(r=r) offset(r=-r) square([w,h]);
}

// =================== TABS ===================
module tab_shape(idx=register_index){
  let(pr = tab_pos_right(idx),
      pt = tab_pos_top(idx),
      pos = (tab_side=="right") ? pr : pt)
  translate(pos){
    if (tab_r <= 0){
      square([tab_w, tab_h]);
    } else if (tab_side == "right"){
      if (tab_round_inner){
        // alle vier Ecken rund
        roundrect_wh(tab_w, tab_h, tab_r);
      } else {
        // nur die rechten Außenecken rund
        union(){
          // Grundkörper links + Mittelsteg
          square([tab_w - tab_r, tab_h]);
          translate([tab_w - tab_r, tab_r]) square([tab_r, tab_h - 2*tab_r]);
          // Viertelkreise oben rechts & unten rechts
          translate([tab_w - tab_r, tab_h - tab_r]) circle(r=tab_r);
          translate([tab_w - tab_r, tab_r]) circle(r=tab_r);
        }
      }
    } else { // tab_side == "top"
      if (tab_round_inner){
        // alle vier Ecken rund
        roundrect_wh(tab_w, tab_h, tab_r);
      } else {
        // nur die oberen Außenecken rund
        union(){
          // Grundkörper unten + Mittelsteg
          square([tab_w, tab_h - tab_r]);
          translate([tab_r, tab_h - tab_r]) square([tab_w - 2*tab_r, tab_r]);
          // Viertelkreise links oben & rechts oben
          translate([tab_r, tab_h - tab_r]) circle(r=tab_r);
          translate([tab_w - tab_r, tab_h - tab_r]) circle(r=tab_r);
        }
      }
    }
  }
}

// =================== TEXTE (2D) ===================
module label_tab_2d(idx=register_index){
  let(pr = tab_pos_right(idx), pt = tab_pos_top(idx), cx = (tab_side=="right") ? (pr[0] + tab_w/2) : (pt[0] + tab_w/2), cy = (tab_side=="right") ? (pr[1] + tab_h/2) : (pt[1] + tab_h/2))
    translate([cx,cy]) rotate(text_rotation_deg)
      text(label_text, size=text_size, font=use_font(), halign="center", valign="center");
}

module title_2d(){
  if (show_title){
    cx = title_tile_enable ? (title_tile_x0()+title_tile_x1())/2 : page_w/2;
    cy = title_tile_enable ? (title_tile_y0()+title_tile_y1())/2 : (page_h - title_tile_top - title_size/2);
    translate([cx,cy]) text(label_text, size=title_size, font=use_font(), halign="center", valign="center");
  }
}

// =================== TITEL-KACHEL ===================
module roundrect2d(x0,y0,x1,y1,r=0){
  w = max(0, x1-x0); h = max(0, y1-y0);
  if (r <= 0) translate([x0,y0]) square([w,h]);
  else translate([x0,y0]) offset(r=r) offset(r=-r) square([w,h]);
}

// Vollmaterial-Bereich der Kachel (blockiert Waben)
module title_tile_region2d(){
  if (title_tile_enable)
    roundrect2d(title_tile_x0(), title_tile_y0(), title_tile_x1(), title_tile_y1(), title_tile_r);
}

// Rahmenelemente (nur innerhalb der Kachel)
module title_border_outer2d(){
  roundrect2d(title_tile_x0(), title_tile_y0(), title_tile_x1(), title_tile_y1(), title_tile_r);
}
module title_border_inner2d(){
  roundrect2d(title_tile_x0()+title_tile_bw, title_tile_y0()+title_tile_bw,
              title_tile_x1()-title_tile_bw, title_tile_y1()-title_tile_bw,
              max(0, title_tile_r - title_tile_bw));
}
module title_border_region2d(){
  if (title_tile_enable && title_tile_border) difference(){ title_border_outer2d(); title_border_inner2d(); }
}

// Nut- / Inlay-Geometrien für flush_inlay
module title_border_cutout2d(g){ // größerer Nutbereich im Grundkörper
  if (title_tile_enable && title_tile_border) difference(){
    offset(delta=+g) title_border_outer2d();  // außen größer
    offset(delta=-g) title_border_inner2d();  // innen größer (Loch größer)
  }
}
module title_border_inlay2d(g){ // etwas kleinerer Inlay-Ring
  if (title_tile_enable && title_tile_border) difference(){
    offset(delta=-g) title_border_outer2d();  // außen kleiner
    offset(delta=+g) title_border_inner2d();  // innen kleiner (Loch kleiner)
  }
}

// =================== WABEN (2D) ===================
module hex2d(r){ polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]); }

module honey_region(){
  difference(){
    // Innenrechteck (ohne Außenrahmen)
    translate([frame_w, frame_w]) square([page_w-2*frame_w, page_h-2*frame_w], center=false);

    // Tab-Schutz
    let(p = (tab_side=="right") ? tab_pos_right(register_index) : tab_pos_top(register_index))
      translate([p[0]-honey_clear_tab, p[1]-honey_clear_tab]) square([tab_w+2*honey_clear_tab, tab_h+2*honey_clear_tab]);

    // Loch-Schutzkreise
    translate([punch_edge, page_h/2]){
      if (holes==2){ for (y=[-hole_spacing/2, hole_spacing/2]) translate([0,y]) circle(r=hole_d/2 + honey_clear_hole); }
      else { base = hole_spacing/2; for (y=[-3*base,-1*base,1*base,3*base]) translate([0,y]) circle(r=hole_d/2 + honey_clear_hole); }
    }

    // Titel-Kachel vollmaterialig → hier keine Waben
    title_tile_region2d();
  }
}

module honeycomb_holes(){
  dx = 1.5*cell_radius;  // Spaltenabstand
  dy = sqrt(3)*cell_radius; // Zeilenabstand
  cols = ceil((page_w-2*frame_w)/dx) + 2;
  rows = ceil((page_h-2*frame_w)/dy) + 2;

  intersection(){
    honey_region();
    union(){
      for (ix=[-1:1:cols]){
        x = frame_w + ix*dx;
        yoff = (ix % 2 == 0) ? 0 : dy/2; // versetzte Reihen
        for (iy=[-1:1:rows]){
          y = frame_w + yoff + iy*dy;
          translate([x,y]) hex2d(max(cell_radius - hc_shrink, 0.1));
        }
      }
    }
  }
}

// =================== KÖRPER-AUSGABEN ===================
// 1) Basisplatte (mit/ohne Waben, Ausschnitte für TEXT + RAHMEN bei flush_inlay)
module plate_body(){
  color(plate_color)
  difference(){
    // Grundplatte + Tab
    linear_extrude(thickness) union(){ divider_plate(); tab_shape(register_index); }

    // Löcher
    linear_extrude(thickness+0.3) ring_holes();

    // Waben sparen Material
    if (honeycomb_enable) linear_extrude(thickness) honeycomb_holes();

    // FLUSH-INLAY: Text- und Rahmen-Nuten
    if (inlay_mode == "flush_inlay"){
      linear_extrude(thickness)
        offset(delta=+inlay_gap_text) union(){
          label_tab_2d(register_index);
          if (show_title) title_2d();
        }
      ;
      if (title_tile_enable && title_tile_border)
        linear_extrude(thickness) title_border_cutout2d(inlay_gap_border);
    }

    // Klassisch eingraviert (Text/Rahmen)
    if (inlay_mode == "engrave"){
      translate([0,0,thickness - text_depth]) linear_extrude(text_depth) label_tab_2d(register_index);
      if (show_title) translate([0,0,thickness - title_depth]) linear_extrude(title_depth) title_2d();
      if (title_tile_enable && title_tile_border)
        translate([0,0,thickness - title_depth]) linear_extrude(title_depth) title_border_region2d();
    }
  }
}

// 2) Inlay-Körper: TEXT (eigener Body, gleiche Ebene)
module text_inlay_body(){
  if (inlay_mode == "flush_inlay"){
    color(text_color)
    linear_extrude(thickness)
      offset(delta=-inlay_gap_text) union(){
        label_tab_2d(register_index);
        if (show_title) title_2d();
      }
    ;
  } else if (inlay_mode == "emboss"){
    color(text_color)
    translate([0,0,thickness]) linear_extrude(text_depth) union(){
      label_tab_2d(register_index);
      if (show_title) title_2d();
    }
  }
}

// 3) Inlay-Körper: RAHMEN (eigener Body, gleiche Ebene)
module border_inlay_body(){
  if (title_tile_enable && title_tile_border){
    if (inlay_mode == "flush_inlay"){
      color(border_color)
      linear_extrude(thickness) title_border_inlay2d(inlay_gap_border);
    } else if (inlay_mode == "emboss"){
      color(border_color)
      translate([0,0,thickness]) linear_extrude(title_depth) title_border_region2d();
    }
  }
}

// =================== SZENE ===================
// Export als AMF/3MF → Slicer erkennt die einzelnen Bodies/Extruder
plate_body();
text_inlay_body();
border_inlay_body();

// Debug
echo(str("Register ", register_index, "/", num_registers,
         " | ", holes, "-Loch | TabSide=", tab_side,
         " | Wabe=", honeycomb_enable,
         " | Kachel=", title_tile_enable,
         " | FontSet=", font_set_num,
         " | InlayMode=", inlay_mode,
         " | gap(text,border)=", inlay_gap_text, ", ", inlay_gap_border));
