// =====================================================================
//  PIEZAS 6, 7 y 8 de 8 — LOS TRES PASADORES
//  Son los que traban cada encastre. Salen los tres juntos en un solo
//  STL, acostados, con una cara plana abajo para que peguen a la cama.
//
//  Abrir con OpenSCAD -> F6 -> F7 -> guardar STL.  No hay que tocar nada.
//
//  IMPRESION: tal cual salen. 100% de relleno, 0.16 mm de capa.
//   Sin soportes. ~10 g los tres. Imprimi 2 juegos, alguno se rompe.
//
//  CUAL VA DONDE (van marcados por el largo)
//   92 mm -> tapa de hombro    (pieza 2 + pieza 3)
//   80 mm -> union del humero  (pieza 1 + pieza 2)
//   50 mm -> tapa de muñeca    (pieza 4 + pieza 5)
//
//  Si un pasador entra muy forzado, lijalo un poco. Si queda flojo,
//  pasale una vuelta de cinta o una bandita elastica alrededor de la
//  cabeza y la punta. NO usar calor ni pegamento.
// =====================================================================

$fn = 48;

d_pasador_impreso = 6.0;   // el agujero es de 6.4
d_cabeza = 11;
esp_cabeza = 3;
plano = 0.6;               // cara plana para apoyar en la cama

// largos = 2 * radio exterior del hueso en ese punto + 8 mm
largos = [92, 80, 50];

module pasador(L) {
    intersection() {
        translate([0, 0, d_pasador_impreso/2 - plano])
            rotate([0, 90, 0]) union() {
                // cuerpo con punta achaflanada
                cylinder(d = d_pasador_impreso, h = L - 2);
                translate([0, 0, L - 2]) cylinder(d1 = d_pasador_impreso, d2 = d_pasador_impreso - 2, h = 2);
                // cabeza
                translate([0, 0, -esp_cabeza]) cylinder(d = d_cabeza, h = esp_cabeza);
            }
        translate([-10, -10, 0]) cube([L + 20, 20, 20]);
    }
}

for (i = [0 : len(largos) - 1])
    translate([0, i * 16, 0]) pasador(largos[i]);
