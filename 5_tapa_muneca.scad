// =====================================================================
//  PIEZA 5 de 8 — TAPA DE MUÑECA
//  Cierra el antebrazo y lleva el agujero para una armella M8, de donde
//  se cuelgan las pesas de ensayo. Faldon MACHO con 4 chavetas.
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION: acostada, brida contra la cama, faldon para arriba.
//   Sin soportes. Alto 28 mm. ~15 g.
//
//  ARMELLA: M8, se mete desde abajo (por fuera) y la tuerca queda
//  adentro del faldon. Ponele una arandela grande del lado de afuera.
// =====================================================================

$fn = 64;

// --- geometria general -------------------------------------------------
h_antebrazo = 265;  r_prox = 33;  r_dist = 22;  esp = 3;
alto_junta = 50;

// --- encastre ----------------------------------------------------------
enc_t      = 20;
esp_anillo = 4;
holgura    = 0.3;
ch_w = 3.0;  ch_t = 1.6;
d_pasador  = 6.4;
y_pasador  = 9;     // igual que en el antebrazo

// --- herrajes ----------------------------------------------------------
esp_brida = 8;
r_brida   = r_dist + 4;
d_armella = 8.4;    // M8

// --- derivados ---------------------------------------------------------
zb = alto_junta - 8;
function R(z)  = r_prox + (r_dist - r_prox) * (z - zb) / (h_antebrazo - zb);
function Ri(z) = R(z) - esp;
r_bore_t = Ri(h_antebrazo) - esp_anillo;
r_faldon = r_bore_t - holgura;

echo(str(">>> diametro del faldon: ", 2*r_faldon, " mm"));

// =====================================================================
module pieza() {
    difference() {
        union() {
            cylinder(h = esp_brida, r = r_brida);
            translate([0, 0, esp_brida - 0.01]) difference() {
                cylinder(h = enc_t, r = r_faldon);
                translate([0, 0, -1]) cylinder(h = enc_t + 2, r = r_faldon - esp_anillo);
            }
            for (a = [45 : 90 : 359])
                rotate([0, 0, a]) translate([r_faldon - 0.5, -ch_w/2, esp_brida])
                    cube([ch_t + 0.5, ch_w, enc_t - 1.5]);
        }
        // chaflan en la punta del faldon
        translate([0, 0, esp_brida + enc_t - 1.5]) difference() {
            cylinder(h = 2.5, r = r_faldon + 5);
            cylinder(h = 2.5, r1 = r_faldon + 1, r2 = r_faldon - 1.5);
        }
        // pasador, descentrado igual que en el antebrazo
        translate([-60, y_pasador, esp_brida + enc_t/2]) rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
        // armella M8 en el centro
        translate([0, 0, -1]) cylinder(d = d_armella, h = 40);
    }
}

pieza();
