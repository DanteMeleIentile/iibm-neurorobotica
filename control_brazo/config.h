#ifndef CONFIG_H
#define CONFIG_H
#include <Arduino.h>

typedef enum {
    EV_NONE,
    EV_BTN_V1_PRESS,   EV_BTN_V1_IDLE,
    EV_BTN_V2_PRESS,   EV_BTN_V2_IDLE,
    EV_BTN_V3_PRESS,   EV_BTN_V3_IDLE,
    EV_BTN_V4_PRESS,   EV_BTN_V4_IDLE,
    EV_BTN_PUMP_PRESS, EV_BTN_PUMP_IDLE
} system_ev_t;

typedef enum {
    EV_ACT_NONE,
    EV_ACT_ON,
    EV_ACT_OFF
} act_ev_t;

// Estados del Actuador
typedef enum {
    ST_ACT_OFF,
    ST_ACT_ON
} act_st_t;

// Estructura del Actuador
typedef struct {
    uint8_t pin;
    act_st_t state;    // Corregido: antes actuator_st_t
    act_ev_t event;    // Corregido: antes actuator_ev_t
} act_t;

typedef enum {
    ST_BTN_IDLE,
    ST_BTN_PRESS
} button_st_t;

// Estructura del Sensor/Botón
typedef struct {
    uint8_t pin;
    system_ev_t ev_press;
    system_ev_t ev_idle;    // Corregido: antes ev_off
    button_st_t state;      // FSM del botón
    bool last_reading;      // Para detectar cambios físicos
    uint32_t last_debounce; // Filtro de tiempo
} button_t;

#endif
