// =====================================================================
//  PIEZA 1 de 8 — HUMERO, SECCION DEL CODO (inferior)
//  Lleva la horquilla del codo abajo y el ALOJAMIENTO HEMBRA arriba,
//  donde entra la espiga de la seccion del hombro.
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION
//   Ya sale girada: apoya sobre el anillo del alojamiento (7 mm de pared)
//   y la horquilla queda arriba. Brim de 8 mm. Sin soportes.
//   Alto: 194 mm.  Filamento: ~150 g.
//
//  ENCASTRE
//   Alojamiento cilindrico de 30 mm de profundidad con 4 ranuras.
//   Agujero de pasador a 15 mm de la boca, atraviesa todo.
// =====================================================================

$fn = 48;
girar_para_imprimir = true;

// --- geometria general (igual en todos los archivos) -------------------
h_brazo  = 300;  r_hombro = 42;  r_codo = 31;  esp = 3;
alto_junta = 50;  r_junta = 19;  d_pin = 6.4;
esp_horquilla = 12;  esp_lengueta = 24;  luz_horquilla = esp_lengueta + 2;

// --- encastres (igual en todos los archivos) ---------------------------
z_corte    = 175;   // altura del corte del humero desde el eje del codo
enc        = 30;    // profundidad del encastre
esp_anillo = 4;
holgura    = 0.3;
ran_w = 3.8;  ran_d = 2.2;   // ranuras (hembra)
d_pasador  = 6.4;

// --- celosia -------------------------------------------------------------
grosor_nervio = 8;  cols = 8;  filas = 8;

// --- derivados -----------------------------------------------------------
zb = alto_junta - 8;
z_cel_0 = zb + 28;  z_cel_1 = h_brazo - 32;
paso_z = (z_cel_1 - z_cel_0) / filas;  alto_r = paso_z - grosor_nervio;
function R(z)  = r_codo + (r_hombro - r_codo) * (z - zb) / (h_brazo - zb);
function Ri(z) = R(z) - esp;
r_bore = Ri(z_corte - enc) - esp_anillo;   // radio del alojamiento (cilindrico)
z_pas  = z_corte - enc/2;                   // altura del pasador

echo(str(">>> alto de la pieza: ", z_corte + r_junta, " mm"));
echo(str(">>> diametro del alojamiento: ", 2*r_bore, " mm"));

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

module horquilla() {
    for (s = [-1, 1])
        translate([s*(luz_horquilla + esp_horquilla)/2 - esp_horquilla/2, 0, 0])
            rotate([0, 90, 0]) linear_extrude(esp_horquilla)
                hull() { circle(r = r_junta); translate([-alto_junta, 0]) circle(r = r_codo*0.75); }
}

module pieza() {
    difference() {
        union() {
            horquilla();
            translate([0, 0, zb - 14]) cylinder(h = 22, r = r_codo);
            // cascara
            translate([0, 0, zb]) difference() {
                cylinder(h = z_corte - zb, r1 = r_codo, r2 = R(z_corte));
                translate([0, 0, -1]) cylinder(h = z_corte - zb + 2, r1 = Ri(zb), r2 = Ri(z_corte));
            }
            // anillo del alojamiento hembra
            translate([0, 0, z_corte - enc]) difference() {
                cylinder(h = enc, r1 = Ri(z_corte - enc) + 0.5, r2 = Ri(z_corte) + 0.5);
                translate([0, 0, -1]) cylinder(h = enc + 2, r = r_bore);
            }
        }
        celosia(zb + 20, z_corte - enc - 3);
        // perno M6 del codo
        translate([-60, 0, 0]) rotate([0, 90, 0]) cylinder(d = d_pin, h = 120);
        // aligerado del tapon
        translate([0, 0, zb - 2]) cylinder(h = 26, r = Ri(zb) - 6);
        // 4 ranuras para las chavetas
        for (a = [45 : 90 : 359])
            rotate([0, 0, a]) translate([r_bore - ran_d, -ran_w/2, z_corte - enc - 1])
                cube([ran_d + 1, ran_w, enc + 2]);
        // pasador
        translate([-60, 0, z_pas]) rotate([0, 90, 0]) cylinder(d = d_pasador, h = 120);
    }
}

if (girar_para_imprimir) translate([0, 0, z_corte]) rotate([180, 0, 0]) pieza();
else pieza();
