// A4-Register (OpenSCAD)
// Rand-Rundung fürs komplette Register + variable Flush-Inlay-Tiefe
// Tabs mit Außenradien, Batch-Schalter mit tab-sicherem Raster
// Separate Bodies: Platte, Text, Rahmen (für MMU)
// ---------------------------------------------------------------------

// =================== BASIS ===================
thickness   = 0.8;  // Mindesthöhe bei 0.2 mm Layer
page_w      = 210;  // A4 Breite (mm)
page_h      = 297;  // A4 Höhe (mm)
page_r      = 5;    // NEU: Rundungsradius der Seitenaußenkante (0 = eckig)

// Lochreihe (DIN)
punch_edge  = 12;   // Abstand linker Rand -> Lochmitte (mm)
hole_d      = 6;    // Loch-Ø (mm)
holes       = 2;    // 2 oder 4
hole_spacing= 80;   // 2-Loch: 80 mm; 4-Loch: 80-80-80

// Register / Tab
tab_w       = 20;   // Reiter-Breite (ragt rechts raus)
tab_h       = 70;   // Reiter-Höhe
tab_side    = "right"; // "right" (empfohlen) oder "top"
tab_margin  = 5;    // Verteilrand oben/unten (0 = durchgehend)
num_registers  = 7; // Gesamtzahl Register (steuert Auto-Position der Tabs)
register_index = 1; // Einzel-Render: Index dieses Registers (1..n)

// Tabs abrunden (nur Außenecken standard)
tab_r = 3;                 // 0 = eckig; >0 = Radius
tab_round_inner = false;   // true = alle 4 Ecken rund

// Beschriftung (Tab + Titel)
label_text  = "Dokumente"; // Default-Text
label_list = [ /* optional: "A", "B", "C", ... (max. num_registers) */ ];
text_rotation_deg = 90;  // Quer auf dem Tab (90 = seitlich lesbar)

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
text_depth  = 0.4; // nur für "engrave"/"emboss"

// Titel + Kachel
show_title       = true; // Überschrift anzeigen
title_size       = 20;   // Überschrift-Schriftgröße (mm)
title_depth      = 0.4;  // nur für "engrave"/"emboss"

// Kachel (Vollmaterial) im Wabenfeld – Standardwerte
title_tile_enable = true; // Kachel aktiv
title_tile_top    = 46; // Abstand Oberkante Seite -> Kachel-Oberkante (mm)
title_tile_left   = 16;   // Abstand links (mm)
title_tile_right  = 17;   // Abstand rechts (mm)
title_tile_h      = 40;   // Kachel-Höhe (mm)
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
hc_shrink        = 2;    // kleiner machen für stärkere Stege

// Extra-Stabilität um die Kachel (Vollmaterial-Halo)
honey_clear_tile = 2.5;  // 0 = aus; 2–3 mm empfohlen

// ====== INLAY / MULTICOLOR ======
// Modus: "engrave" | "emboss" | "flush_inlay"
inlay_mode   = "flush_inlay";     // plan + getrennte Bodies (für MMU)

// Seitliches Spiel (mm)
inlay_gap_text   = 0.06;
inlay_gap_border = 0.06;

// Inlay-Tiefe (mm)
inlay_depth_text   = 0.4;  // Tiefe der Schrift-Tasche
inlay_depth_border = 0.4;  // Tiefe der Rahmen-Tasche

// Farben (AMF/3MF)
plate_color  = [1,1,1,1];          // Extruder 1
text_color   = [0,0,0,1];          // Extruder 2
border_color = [0,0,0,1];          // Extruder 3 (optional)

$fn = 48;

// =================== BATCH-LAYOUT ===================
// Rendert mehrere Registerblätter im Raster, abstandssicher inkl. Tab
batch_enable = false;       // AN = mehrere Blätter rendern, AUS = nur register_index
batch_count  = 7;          // wie viele Blätter erzeugen (üblich = num_registers)
batch_cols   = 3;          // Spalten im Raster
batch_gap_x  = 12;         // zusätzlicher horizontaler Abstand (mm)
batch_gap_y  = 8;          // zusätzlicher vertikaler Abstand (mm)

// =================== HILFSFUNKTIONEN ===================
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
function use_font() = (font_set_num>=1 && font_set_num<=len(font_list)) ? font_list[font_set_num-1] : font_name;

function tab_y_pos(num, idx, tab_h_, margin_, page_h_) =
    let(n=max(1,num), ii=clamp(idx,1,n), usable=page_h_-2*margin_,
        step=(n==1)?0:(usable-tab_h_)/(n-1), top_y = page_h_ - margin_ - tab_h_)
    top_y - (ii-1)*step;

function label_for(i) = (len(label_list) > 0 && i <= len(label_list)) ? label_list[i-1] : label_text;
function dcap(d) = max(0, min(d, thickness)); // Tiefe auf [0..thickness] begrenzen

// Batch-Helfer – Tab in Breite/Höhe berücksichtigen
function sheet_w() = page_w + ((tab_side=="right") ? tab_w : 0);
function sheet_h() = page_h + ((tab_side=="top")   ? tab_h : 0);

// Titel-Kachel-Geometrie (2D helpers)
function title_tile_x0() = title_tile_left;
function title_tile_x1() = page_w - title_tile_right;
function title_tile_y1() = page_h - title_tile_top;
function title_tile_y0() = title_tile_y1() - title_tile_h;

// =================== TITEL-KACHEL / PAGE OUTLINE ===================
module roundrect2d(x0,y0,x1,y1,r=0){
  w = max(0, x1-x0); h = max(0, y1-y0);
  if (r <= 0) translate([x0,y0]) square([w,h]);
  else translate([x0,y0]) offset(r=r) offset(r=-r) square([w,h]);
}

// NEU: Seitenkontur mit Rundung
module plate_outline_2d(){
  roundrect2d(0, 0, page_w, page_h, page_r);
}

module title_tile_region2d(){
  if (title_tile_enable)
    roundrect2d(title_tile_x0(), title_tile_y0(), title_tile_x1(), title_tile_y1(), title_tile_r);
}

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

// Nut- / Inlay-Geometrien für flush_inlay (2D)
module title_border_cutout2d(g){
  if (title_tile_enable && title_tile_border) difference(){
    offset(delta=+g) title_border_outer2d();
    offset(delta=-g) title_border_inner2d();
  }
}
module title_border_inlay2d(g){
  if (title_tile_enable && title_tile_border) difference(){
    offset(delta=-g) title_border_outer2d();
    offset(delta=+g) title_border_inner2d();
  }
}

// =================== GRUNDFORMEN ===================
module divider_plate(){ plate_outline_2d(); }

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
        roundrect_wh(tab_w, tab_h, tab_r);
      } else {
        union(){
          square([tab_w - tab_r, tab_h]);
          translate([tab_w - tab_r, tab_r]) square([tab_r, tab_h - 2*tab_r]);
          translate([tab_w - tab_r, tab_h - tab_r]) circle(r=tab_r);
          translate([tab_w - tab_r, tab_r]) circle(r=tab_r);
        }
      }
    } else { // top
      if (tab_round_inner){
        roundrect_wh(tab_w, tab_h, tab_r);
      } else {
        union(){
          square([tab_w, tab_h - tab_r]);
          translate([tab_r, tab_h - tab_r]) square([tab_w - 2*tab_r, tab_r]);
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
      text(label_for(idx), size=text_size, font=use_font(), halign="center", valign="center");
}

module title_2d(idx=register_index){
  if (show_title){
    cx = title_tile_enable ? (title_tile_x0()+title_tile_x1())/2 : page_w/2;
    cy = title_tile_enable ? (title_tile_y0()+title_tile_y1())/2 : (page_h - title_tile_top - title_size/2);
    translate([cx,cy]) text(label_for(idx), size=title_size, font=use_font(), halign="center", valign="center");
  }
}

// =================== WABEN (2D) ===================
module hex2d(r){ polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]); }

module honey_region(idx){
  difference(){
    // Innenkontur = Seitenkontur um frame_w nach innen versetzt (bleibt rund)
    offset(delta=-frame_w) plate_outline_2d();

    // Tab-Schutz (pro Register-Index)
    let(p = (tab_side=="right") ? tab_pos_right(idx) : tab_pos_top(idx))
      translate([p[0]-honey_clear_tab, p[1]-honey_clear_tab]) square([tab_w+2*honey_clear_tab, tab_h+2*honey_clear_tab]);

    // Loch-Schutzkreise
    translate([punch_edge, page_h/2]){
      if (holes==2){ for (y=[-hole_spacing/2, hole_spacing/2]) translate([0,y]) circle(r=hole_d/2 + honey_clear_hole); }
      else { base = hole_spacing/2; for (y=[-3*base,-1*base,1*base,3*base]) translate([0,y]) circle(r=hole_d/2 + honey_clear_hole); }
    }

    // Titel-Kachel + Halo → hier keine Waben
    offset(delta=+honey_clear_tile) title_tile_region2d();
  }
}

module honeycomb_holes(idx){
  dx = 1.5*cell_radius;  // Spaltenabstand
  dy = sqrt(3)*cell_radius; // Zeilenabstand
  cols = ceil((page_w-2*frame_w)/dx) + 2;
  rows = ceil((page_h-2*frame_w)/dy) + 2;

  intersection(){
    honey_region(idx);
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

// =================== KÖRPER-AUSGABEN (ein Blatt) ===================
module plate_body(idx){
  color(plate_color)
  difference(){
    // Grundplatte (abgerundet) + Tab
    linear_extrude(thickness) union(){ plate_outline_2d(); tab_shape(idx); }

    // Löcher
    linear_extrude(thickness+0.3) ring_holes();

    // Waben sparen Material
    if (honeycomb_enable) linear_extrude(thickness) honeycomb_holes(idx);

    // FLUSH-INLAY: Text- und Rahmen-Taschen mit individueller Tiefe
    if (inlay_mode == "flush_inlay"){
      // Text-Tasche
      translate([0,0, thickness - dcap(inlay_depth_text)])
        linear_extrude(dcap(inlay_depth_text))
          offset(delta=+inlay_gap_text) union(){
            label_tab_2d(idx);
            if (show_title) title_2d(idx);
          }
      ;
      // Rahmen-Tasche
      if (title_tile_enable && title_tile_border)
        translate([0,0, thickness - dcap(inlay_depth_border)])
          linear_extrude(dcap(inlay_depth_border))
            title_border_cutout2d(inlay_gap_border);
    }

    // Klassisch eingraviert (Text/Rahmen)
    if (inlay_mode == "engrave"){
      translate([0,0,thickness - text_depth]) linear_extrude(text_depth) label_tab_2d(idx);
      if (show_title) translate([0,0,thickness - title_depth]) linear_extrude(title_depth) title_2d(idx);
      if (title_tile_enable && title_tile_border)
        translate([0,0,thickness - title_depth]) linear_extrude(title_depth) title_border_region2d();
    }
  }
}

// 2) Inlay-Körper: TEXT (eigener Body, sitzt in der Tasche)
module text_inlay_body(idx){
  if (inlay_mode == "flush_inlay"){
    color(text_color)
    translate([0,0, thickness - dcap(inlay_depth_text)])
      linear_extrude(dcap(inlay_depth_text))
        offset(delta=-inlay_gap_text) union(){
          label_tab_2d(idx);
          if (show_title) title_2d(idx);
        }
    ;
  } else if (inlay_mode == "emboss"){
    color(text_color)
    translate([0,0,thickness]) linear_extrude(text_depth) union(){
      label_tab_2d(idx);
      if (show_title) title_2d(idx);
    }
  }
}

// 3) Inlay-Körper: RAHMEN (eigener Body, sitzt in der Tasche)
module border_inlay_body(idx){
  if (title_tile_enable && title_tile_border){
    if (inlay_mode == "flush_inlay"){
      color(border_color)
      translate([0,0, thickness - dcap(inlay_depth_border)])
        linear_extrude(dcap(inlay_depth_border))
          title_border_inlay2d(inlay_gap_border);
    } else if (inlay_mode == "emboss"){
      color(border_color)
      translate([0,0,thickness]) linear_extrude(title_depth) title_border_region2d();
    }
  }
}

module render_sheet(idx){
  plate_body(idx);
  text_inlay_body(idx);
  border_inlay_body(idx);
}

// =================== BATCH-SZENE ===================
module render_batch(){
  cols = max(1, batch_cols);
  sx = sheet_w() + batch_gap_x; // Blattbreite inkl. Tab + Abstand
  sy = sheet_h() + batch_gap_y; // Blatthöhe  inkl. Tab + Abstand
  for(i = [1:batch_count]){
    col = (i-1) % cols;
    row = floor((i-1)/cols);
    translate([col*sx, -row*sy, 0]) render_sheet(i);
  }
}

// =================== SZENE ===================
if (batch_enable) render_batch();
else render_sheet(register_index);

// Debug
echo(str("Batch=", batch_enable, " (", batch_count, "), cols=", batch_cols,
         " | Register ", register_index, "/", num_registers,
         " | page_r=", page_r,
         " | InlayMode=", inlay_mode,
         " | depth(text,border)=", inlay_depth_text, ", ", inlay_depth_border,
         " | gap(text,border)=", inlay_gap_text, ", ", inlay_gap_border));
