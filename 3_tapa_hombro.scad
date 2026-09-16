// =====================================================================
//  PIEZA 3 de 8 — TAPA DE HOMBRO
//  Cierra el humero por arriba. Tiene:
//   - un faldon MACHO con 4 chavetas que entra en la seccion del hombro
//   - 2 agujeros M5 para las armellas donde se atan los musculos
//   - 4 agujeros M5 en la brida para fijar el brazo a una mesa o perfil
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION: acostada, brida contra la cama, faldon para arriba.
//   Sin soportes. Alto 28 mm. ~40 g.
// =====================================================================

$fn = 64;

// --- geometria general -------------------------------------------------
h_brazo  = 300;  r_hombro = 42;  r_codo = 31;  esp = 3;
alto_junta = 50;

// --- encastres ---------------------------------------------------------
enc_t      = 20;
esp_anillo = 4;
holgura    = 0.3;
ch_w = 3.0;  ch_t = 1.6;
d_pasador  = 6.4;

// --- herrajes ----------------------------------------------------------
esp_brida  = 8;
r_brida    = r_hombro + 10;
d_anclaje  = 5.4;   // M5 armellas de los musculos
d_frame    = 5.4;   // M5 fijacion a bancada

// --- derivados ---------------------------------------------------------
zb = alto_junta - 8;
function R(z)  = r_codo + (r_hombro - r_codo) * (z - zb) / (h_brazo - zb);
function Ri(z) = R(z) - esp;
r_bore_t = Ri(h_brazo - enc_t) - esp_anillo;
r_faldon = r_bore_t - holgura;

echo(str(">>> diametro del faldon: ", 2*r_faldon, " mm"));

// =====================================================================
module pieza() {
    difference() {
        union() {
            cylinder(h = esp_brida, r = r_brida);
            // faldon macho hueco
            translate([0, 0, esp_brida - 0.01]) difference() {
                cylinder(h = enc_t, r = r_faldon);
                translate([0, 0, -1]) cylinder(h = enc_t + 2, r = r_faldon - esp_anillo);
            }
            // 4 chavetas
            for (a = [45 : 90 : 359])
                rotate([0, 0, a]) translate([r_faldon - 0.5, -ch_w/2, esp_brida])
                    cube([ch_t + 0.5, ch_w, enc_t - 1.5]);
        }
        // chaflan en la punta del faldon
        translate([0, 0, esp_brida + enc_t - 1.5]) difference() {
            cylinder(h = 2.5, r = r_faldon + 5);
            cylinder(h = 2.5, r1 = r_faldon + 1, r2 = r_faldon - 1.5);
        }
        // pasador (a mitad del faldon, mismo alto que en la pieza 2)
        translate([-60, 0, esp_brida + enc_t/2]) rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
        // armellas de los musculos (flexor y extensor)
        for (s = [-1, 1])
            translate([0, s*(r_faldon - esp_anillo - 6), -1]) cylinder(d = d_anclaje, h = 40);
        // fijacion a bancada, en la brida por fuera del hueso
        for (a = [45 : 90 : 359])
            rotate([0, 0, a]) translate([r_brida - 5.5, 0, -1]) cylinder(d = d_frame, h = 12);
        // aligerado central
        translate([0, 0, -1]) cylinder(h = 40, r = r_faldon - esp_anillo - 16);
    }
}

pieza();
