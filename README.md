# Brazo robótico con celosía para músculos artificiales fluídicos

Estructura pasiva de un brazo a escala humana (húmero + antebrazo) para montar
músculos McKibben o músculos tejidos, inspirada en el brazo de
[Afsar et al., *Electrofluidic fiber muscles*, Science Robotics 2026](https://www.science.org/doi/10.1126/scirobotics.ady6438).

Todas las piezas se unen por **encastre mecánico** (espiga con chavetas + pasador
impreso). No lleva pegamento ni soldadura. El único tornillo es el perno del codo.

## Piezas

| # | Archivo | Pieza | Alto | Encastre |
|---|---|---|---|---|
| 1 | `1_humero_codo.scad` | húmero, mitad del codo (con horquilla) | 194 mm | hembra arriba |
| 2 | `2_humero_hombro.scad` | húmero, mitad del hombro | 155 mm | macho abajo, hembra arriba |
| 3 | `3_tapa_hombro.scad` | tapa con anclajes de músculos y fijación a mesa | 28 mm | macho |
| 4 | `4_antebrazo.scad` | antebrazo entero | 284 mm | hembra en la muñeca |
| 5 | `5_tapa_muneca.scad` | tapa con agujero para armella M8 | 28 mm | macho |
| 6 | `6_pasadores.scad` | los 3 pasadores (salen juntos) | 9 mm | — |

## Cómo generar los STL

1. Instalar [OpenSCAD](https://openscad.org/downloads.html) (gratis, versión 2019.05 o más nueva).
2. Abrir el `.scad`.
3. **F6** (render, tarda 1-3 minutos por las perforaciones).
4. **F7** → guardar el `.stl`.

No hace falta editar nada. Cada archivo ya sale en la orientación correcta para
imprimir. Los parámetros están arriba de cada archivo por si se quiere cambiar
medidas; la consola de OpenSCAD avisa el alto resultante.

## Impresión

- Material: PLA sirve para las cáscaras. Piezas 1 y 4 (horquilla y lengüeta del
  codo, que concentran la carga) mejor en PETG.
- 3 perímetros, 15-20 % de relleno, capa 0,2 mm. Pasadores: 100 % de relleno.
- **Brim de 8-10 mm en las piezas 1, 2 y 4.** Apoyan sobre un anillo y sin brim
  se despegan.
- Sin soportes en ninguna pieza. Los rombos de la celosía son autosoportados.
- Altura máxima de impresión necesaria: 284 mm (pieza 4).

Orden sugerido: primero `6_pasadores` y `5_tapa_muneca` (piezas chicas) para
verificar que el encastre calza bien en la impresora antes de mandar las grandes.

## Armado

1. Espiga de la pieza 2 dentro de la pieza 1, alineando las 4 chavetas con las
   4 ranuras. Pasador de **80 mm**.
2. Tapa de hombro (3) en la boca de la pieza 2. Pasador de **92 mm**.
3. Tapa de muñeca (5) en la boca del antebrazo (4). Pasador de **50 mm**
   (va descentrado 9 mm para no chocar con la armella).
4. Lengüeta del antebrazo entre las orejas de la horquilla. Perno M6 × 70.

Si un encastre entra forzado, lijar las chavetas con lija 220. Nunca a martillo.
Si entra flojo, subir `holgura` en el archivo macho a 0,5 y reimprimir.

## Tornillería y accesorios

- 1 × perno M6 × 70 + tuerca autoblocante + 2 arandelas grandes (codo)
- 2 × armella M5 (anclaje de los músculos, en la tapa de hombro)
- 4 × tornillo M5 (fijación de la tapa de hombro a mesa o perfil 2020)
- 1 × armella M8 + tuerca + arandela grande (tapa de muñeca, para colgar pesas)

## Anclaje del músculo

La barra del antebrazo tiene 4 agujeros a 25, 35, 45 y 55 mm del eje del codo.
Cambiando de agujero se cambia el brazo de palanca:

    rango (grados) ≈ 57,3 × carrera del músculo / palanca

Ej.: músculo de 420 mm que contrae 20 % → 84 mm de carrera → con 45 mm de
palanca da ~107° de flexión. Con 25 mm hay más torque pero el codo topea antes.

## Parámetros compartidos entre archivos

Si se cambia alguno de estos, hay que cambiarlo igual en todos los archivos
donde aparece: `esp_lengueta`, `z_corte`, `enc`, `enc_t`, `esp_anillo`,
`holgura`, `y_pasador`, y las medidas generales (`h_brazo`, `r_hombro`,
`r_codo`, `h_antebrazo`, `r_prox`, `r_dist`, `esp`).
