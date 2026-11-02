#include "config.h"

#define DEBOUNCE_MS 50
#define RELAY_ON LOW
#define RELAY_OFF HIGH

// Cola de Eventos (Ring Buffer)
#define QUEUE_SIZE 15
system_ev_t event_queue[QUEUE_SIZE];
uint8_t queue_head = 0;
uint8_t queue_tail = 0;

void put_event(system_ev_t ev) {
    uint8_t next_head = (queue_head + 1) % QUEUE_SIZE;
    if (next_head != queue_tail) { 
        event_queue[queue_head] = ev;
        queue_head = next_head;
    }
}

system_ev_t get_event() {
    if (queue_head == queue_tail) return EV_NONE;
    system_ev_t ev = event_queue[queue_tail];
    queue_tail = (queue_tail + 1) % QUEUE_SIZE;
    return ev;
}

// Configuración de Hardware
button_t buttons[5] = {
    {2, EV_BTN_V1_PRESSED,   EV_BTN_V1_RELEASED,   ST_BTN_RELEASED, HIGH, 0},
    {3, EV_BTN_V2_PRESSED,   EV_BTN_V2_RELEASED,   ST_BTN_RELEASED, HIGH, 0},
    {4, EV_BTN_V3_PRESSED,   EV_BTN_V3_RELEASED,   ST_BTN_RELEASED, HIGH, 0},
    {5, EV_BTN_V4_PRESSED,   EV_BTN_V4_RELEASED,   ST_BTN_RELEASED, HIGH, 0},
    {6, EV_BTN_PUMP_PRESSED, EV_BTN_PUMP_RELEASED, ST_BTN_RELEASED, HIGH, 0}
};

actuator_t actuators[5] = {
    {7,  ST_ACT_OFF, EV_ACT_NONE}, // Válvula 1
    {8,  ST_ACT_OFF, EV_ACT_NONE}, // Válvula 2
    {9,  ST_ACT_OFF, EV_ACT_NONE}, // Válvula 3
    {10, ST_ACT_OFF, EV_ACT_NONE}, // Válvula 4
    {11, ST_ACT_OFF, EV_ACT_NONE}  // Bomba
};

void setup() {
    for (int i = 0; i < 5; i++) {
        pinMode(buttons[i].pin, INPUT_PULLUP);
        pinMode(actuators[i].pin, OUTPUT);
        digitalWrite(actuators[i].pin, RELAY_OFF);
    }
}

// 1. Escrutar: Máquina de estados de los Botones
void task_button_update() {
    uint32_t now = millis();
    for (int i = 0; i < 5; i++) {
        bool reading = digitalRead(buttons[i].pin);
        
        // Reinicio de temporizador si hay rebote mecánico
        if (reading != buttons[i].last_reading) {
            buttons[i].last_debounce = now;
        }
        
        // Evaluación una vez superado el tiempo de debounce
        if ((now - buttons[i].last_debounce) > DEBOUNCE_MS) {
            // Transición a PRESIONADO
            if (reading == LOW && buttons[i].state == ST_BTN_RELEASED) {
                buttons[i].state = ST_BTN_PRESSED;
                put_event(buttons[i].ev_pressed);
            } 
            // Transición a SOLTADO
            else if (reading == HIGH && buttons[i].state == ST_BTN_PRESSED) {
                buttons[i].state = ST_BTN_RELEASED;
                put_event(buttons[i].ev_released);
            }
        }
        buttons[i].last_reading = reading;
    }
}

// 2. Procesar: Lógica Central
void task_system_update() {
    system_ev_t ev = get_event();
    if (ev != EV_NONE) {
        int act_index = -1;
        actuator_ev_t act_ev = EV_ACT_NONE;

        // Decodificación de eventos y asignación al actuador correspondiente
        switch (ev) {
            case EV_BTN_V1_PRESSED:    act_index = 0; act_ev = EV_ACT_ON;  break;
            case EV_BTN_V1_RELEASED:   act_index = 0; act_ev = EV_ACT_OFF; break;
            case EV_BTN_V2_PRESSED:    act_index = 1; act_ev = EV_ACT_ON;  break;
            case EV_BTN_V2_RELEASED:   act_index = 1; act_ev = EV_ACT_OFF; break;
            case EV_BTN_V3_PRESSED:    act_index = 2; act_ev = EV_ACT_ON;  break;
            case EV_BTN_V3_RELEASED:   act_index = 2; act_ev = EV_ACT_OFF; break;
            case EV_BTN_V4_PRESSED:    act_index = 3; act_ev = EV_ACT_ON;  break;
            case EV_BTN_V4_RELEASED:   act_index = 3; act_ev = EV_ACT_OFF; break;
            case EV_BTN_PUMP_PRESSED:  act_index = 4; act_ev = EV_ACT_ON;  break;
            case EV_BTN_PUMP_RELEASED: act_index = 4; act_ev = EV_ACT_OFF; break;
            default: break;
        }

        // Si el evento era válido, se delega al buzón del actuador
        if (act_index != -1) {
            actuators[act_index].event = act_ev;
        }
    }
}

// 3. Actuar: Máquina de estados de los Actuadores
void task_actuator_update() {
    for (int i = 0; i < 5; i++) {
        switch (actuators[i].state) {
            case ST_ACT_OFF:
                if (actuators[i].event == EV_ACT_ON) {
                    digitalWrite(actuators[i].pin, RELAY_ON);
                    actuators[i].state = ST_ACT_ON;
                }
                break;
                
            case ST_ACT_ON:
                if (actuators[i].event == EV_ACT_OFF) {
                    digitalWrite(actuators[i].pin, RELAY_OFF);
                    actuators[i].state = ST_ACT_OFF;
                }
                break;
        }
        
        // Consumir el evento una vez evaluado
        actuators[i].event = EV_ACT_NONE;
    }
}

void loop() {
    task_button_update();
    task_system_update();
    task_actuator_update();
}
