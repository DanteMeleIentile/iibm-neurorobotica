#ifndef CONFIG_H
#define CONFIG_H
#include <Arduino.h>

// Eventos de entrada para el Sistema (Generados por los Botones)
typedef enum {
    EV_NONE,
    EV_BTN_V1_PRESSED,   EV_BTN_V1_RELEASED,
    EV_BTN_V2_PRESSED,   EV_BTN_V2_RELEASED,
    EV_BTN_V3_PRESSED,   EV_BTN_V3_RELEASED,
    EV_BTN_V4_PRESSED,   EV_BTN_V4_RELEASED,
    EV_BTN_PUMP_PRESSED, EV_BTN_PUMP_RELEASED
} system_ev_t;

// Eventos internos para los Actuadores (Generados por el Sistema)
typedef enum {
    EV_ACT_NONE,
    EV_ACT_ON,
    EV_ACT_OFF
} actuator_ev_t;

// Máquina de estados del Actuador
typedef enum {
    ST_ACT_OFF,
    ST_ACT_ON
} actuator_st_t;

// Máquina de estados del Sensor (Botón)
typedef enum {
    ST_BTN_RELEASED,
    ST_BTN_PRESSED
} button_st_t;

// Estructura del Sensor/Botón
typedef struct {
    uint8_t pin;
    system_ev_t ev_pressed;
    system_ev_t ev_released;
    button_st_t state;      // FSM del botón
    bool last_reading;      // Para detectar cambios físicos
    uint32_t last_debounce; // Filtro de tiempo
} button_t;

// Estructura del Actuador
typedef struct {
    uint8_t pin;
    actuator_st_t state;   // FSM del actuador
    actuator_ev_t event;   // Buzón de eventos individual
} actuator_t;

#endif