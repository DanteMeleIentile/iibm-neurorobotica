// =====================================================================
//  PIEZA 2 de 8 — HUMERO, SECCION DEL HOMBRO (superior)
//  Lleva la ESPIGA MACHO abajo (entra en la seccion del codo) y un
//  ALOJAMIENTO HEMBRA arriba (donde entra la tapa de hombro).
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION
//   Ya sale girada: apoya sobre el anillo del hombro y la espiga queda
//   arriba. Brim de 8 mm. Sin soportes.
//   Alto: 155 mm.  Filamento: ~130 g.
// =====================================================================

$fn = 48;
girar_para_imprimir = true;

// --- geometria general -------------------------------------------------
h_brazo  = 300;  r_hombro = 42;  r_codo = 31;  esp = 3;
alto_junta = 50;  r_junta = 19;

// --- encastres ---------------------------------------------------------
z_corte    = 175;
enc        = 30;     // encastre con la seccion del codo
enc_t      = 20;     // encastre de la tapa de hombro
esp_anillo = 4;
holgura    = 0.3;
ch_w = 3.0;  ch_t = 1.6;    // chavetas (macho)
ran_w = 3.8; ran_d = 2.2;   // ranuras (hembra)
d_pasador  = 6.4;

// --- celosia -----------------------------------------------------------
grosor_nervio = 8;  cols = 8;  filas = 8;

// --- derivados ---------------------------------------------------------
zb = alto_junta - 8;
z_cel_0 = zb + 28;  z_cel_1 = h_brazo - 32;
paso_z = (z_cel_1 - z_cel_0) / filas;  alto_r = paso_z - grosor_nervio;
function R(z)  = r_codo + (r_hombro - r_codo) * (z - zb) / (h_brazo - zb);
function Ri(z) = R(z) - esp;
r_bore   = Ri(z_corte - enc) - esp_anillo;      // alojamiento del codo (en pieza 1)
r_espiga = r_bore - holgura;                    // espiga de esta pieza
r_bore_t = Ri(h_brazo - enc_t) - esp_anillo;    // alojamiento de la tapa
z_pas    = z_corte - enc/2;
z_pas_t  = h_brazo - enc_t/2;

echo(str(">>> alto de la pieza: ", h_brazo - (z_corte - enc), " mm"));

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

module pieza() {
    difference() {
        union() {
            // cascara
            translate([0, 0, z_corte]) difference() {
                cylinder(h = h_brazo - z_corte, r1 = R(z_corte), r2 = r_hombro);
                translate([0, 0, -1]) cylinder(h = h_brazo - z_corte + 2, r1 = Ri(z_corte), r2 = Ri(h_brazo));
            }
            // puente macizo que une la cascara con la espiga
            translate([0, 0, z_corte]) difference() {
                cylinder(h = 6, r1 = R(z_corte), r2 = R(z_corte + 6));
                translate([0, 0, -1]) cylinder(h = 8, r = r_espiga - esp_anillo);
            }
            // espiga macho (cilindrica, hueca)
            translate([0, 0, z_corte - enc]) difference() {
                cylinder(h = enc + 1, r = r_espiga);
                translate([0, 0, -1]) cylinder(h = enc + 3, r = r_espiga - esp_anillo);
            }
            // 4 chavetas
            for (a = [45 : 90 : 359])
                rotate([0, 0, a]) translate([r_espiga - 0.5, -ch_w/2, z_corte - enc + 1.5])
                    cube([ch_t + 0.5, ch_w, enc - 1.5]);
            // anillo hembra para la tapa de hombro
            translate([0, 0, h_brazo - enc_t]) difference() {
                cylinder(h = enc_t, r1 = Ri(h_brazo - enc_t) + 0.5, r2 = Ri(h_brazo) + 0.5);
                translate([0, 0, -1]) cylinder(h = enc_t + 2, r = r_bore_t);
            }
        }
        celosia(z_corte + 9, h_brazo - enc_t - 3);
        // chaflan en la punta de la espiga
        translate([0, 0, z_corte - enc - 1]) difference() {
            cylinder(h = 2.5, r = r_espiga + 5);
            cylinder(h = 2.5, r1 = r_espiga - 1.5, r2 = r_espiga + 1);
        }
        // ranuras para la tapa
        for (a = [45 : 90 : 359])
            rotate([0, 0, a]) translate([r_bore_t - ran_d, -ran_w/2, h_brazo - enc_t - 1])
                cube([ran_d + 1, ran_w, enc_t + 2]);
        // pasadores
        translate([-60, 0, z_pas])   rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
        translate([-60, 0, z_pas_t]) rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
    }
}

if (girar_para_imprimir) translate([0, 0, h_brazo]) rotate([180, 0, 0]) pieza();
else pieza();
