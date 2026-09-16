// =====================================================================
//  PIEZA 4 de 8 — ANTEBRAZO (una sola pieza)
//  Con 30 cm de altura de impresion entra entero: 284 mm.
//  Lleva la lengueta del codo y la barra de anclaje del musculo abajo,
//  y un ALOJAMIENTO HEMBRA en la muñeca donde entra la tapa.
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION
//   Ya sale girada: apoya sobre el anillo de la muñeca (7 mm de pared),
//   la lengueta y la barra quedan arriba. Brim de 10 mm, es alta y
//   angosta. Sin soportes. Alto: 284 mm.  Filamento: ~190 g.
//
//  ACOPLE CON EL HUMERO: la lengueta tiene 24 mm de espesor y entra en
//  la horquilla de la pieza 1, con un perno M6 x 70.
// =====================================================================

$fn = 48;
girar_para_imprimir = true;

// --- geometria general -------------------------------------------------
h_antebrazo = 265;  r_prox = 33;  r_dist = 22;  esp = 3;
alto_junta = 50;  r_junta = 19;  d_pin = 6.4;  esp_lengueta = 24;

// --- encastre de la tapa de muñeca ------------------------------------
enc_t      = 20;
esp_anillo = 4;
ran_w = 3.8;  ran_d = 2.2;
d_pasador  = 6.4;
y_pasador  = 9;     // el pasador va descentrado para no chocar con la armella

// --- anclaje del musculo -------------------------------------------------
// Varios agujeros para poder cambiar el brazo de palanca:
//   rango_grados = 57.3 * carrera_del_musculo / palanca
palancas  = [25, 35, 45, 55];
esp_barra = 10;
d_anclaje = 5.4;

// --- celosia -----------------------------------------------------------
grosor_nervio = 8;  cols = 7;  filas = 8;

// --- derivados ---------------------------------------------------------
zb = alto_junta - 8;
z_cel_0 = zb + 26;  z_cel_1 = h_antebrazo - 30;
paso_z = (z_cel_1 - z_cel_0) / filas;  alto_r = paso_z - grosor_nervio;
function R(z)  = r_prox + (r_dist - r_prox) * (z - zb) / (h_antebrazo - zb);
function Ri(z) = R(z) - esp;
r_bore_t = Ri(h_antebrazo) - esp_anillo;     // alojamiento en la boca de la muñeca
z_pas_t  = h_antebrazo - enc_t/2;

echo(str(">>> alto de la pieza: ", h_antebrazo + r_junta, " mm"));
echo(str(">>> alto del rombo: ", alto_r, " mm"));

// =====================================================================
module celosia(z_min, z_max) {
    for (i = [0 : filas - 1]) {
        z = z_cel_0 + paso_z * (i + 0.5);
        r = R(z);
        ancho = min(2*PI*r/cols - grosor_nervio, alto_r);
        off = (i % 2) * (180 / cols);
        if (ancho > 2 && z - alto_r/2 > z_min && z + alto_r/2 < z_max)
            for (j = [0 : cols - 1])
                rotate([0, 0, j*360/cols + off]) translate([r - 30, 0, z])
                    rotate([0, 90, 0]) linear_extrude(60)
                        polygon([[alto_r/2, 0], [0, ancho/2], [-alto_r/2, 0], [0, -ancho/2]]);
    }
}

module lengueta() {
    translate([-esp_lengueta/2, 0, 0]) rotate([0, 90, 0]) linear_extrude(esp_lengueta)
        hull() { circle(r = r_junta); translate([-alto_junta, 0]) circle(r = r_prox*0.75); }
}

module barra_anclaje() {
    L = max(palancas) + 14;
    translate([-esp_barra/2, 0, 0]) rotate([0, 90, 0]) linear_extrude(esp_barra)
        hull() { circle(r = r_junta); translate([0, L]) circle(r = 9); }
}

module pieza() {
    difference() {
        union() {
            lengueta();
            barra_anclaje();
            translate([0, 0, zb - 14]) cylinder(h = 22, r = r_prox);
            // cascara
            translate([0, 0, zb]) difference() {
                cylinder(h = h_antebrazo - zb, r1 = r_prox, r2 = r_dist);
                translate([0, 0, -1]) cylinder(h = h_antebrazo - zb + 2, r1 = Ri(zb), r2 = Ri(h_antebrazo));
            }
            // anillo hembra en la muñeca (cilindrico por dentro)
            translate([0, 0, h_antebrazo - enc_t]) difference() {
                cylinder(h = enc_t, r1 = Ri(h_antebrazo - enc_t) + 0.5, r2 = Ri(h_antebrazo) + 0.5);
                translate([0, 0, -1]) cylinder(h = enc_t + 2, r = r_bore_t);
            }
        }
        celosia(zb + 20, h_antebrazo - enc_t - 3);
        // perno M6 del codo
        translate([-60, 0, 0]) rotate([0, 90, 0]) cylinder(d = d_pin, h = 120);
        // agujeros de palanca
        for (p = palancas)
            translate([-30, p, 0]) rotate([0, 90, 0]) cylinder(d = d_anclaje, h = 60);
        // aligerado del tapon
        translate([0, 0, zb - 2]) cylinder(h = 26, r = Ri(zb) - 6);
        // 4 ranuras para las chavetas de la tapa
        for (a = [45 : 90 : 359])
            rotate([0, 0, a]) translate([r_bore_t - ran_d, -ran_w/2, h_antebrazo - enc_t - 1])
                cube([ran_d + 1, ran_w, enc_t + 2]);
        // pasador de la tapa (descentrado en Y)
        translate([-60, y_pasador, z_pas_t]) rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
    }
}

if (girar_para_imprimir) translate([0, 0, h_antebrazo]) rotate([180, 0, 0]) pieza();
else pieza();
