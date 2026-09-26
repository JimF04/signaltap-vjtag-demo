# Tutorial — Signal Tap & vJTAG

Repositorio de ejemplos para aprender a usar **Signal Tap Logic Analyzer** y **Virtual JTAG (vJTAG)** en Quartus Prime, utilizando una FPGA Cyclone V como plataforma de prueba.

| | |
|---|---|
| **FPGA** | Intel Cyclone V — `5CSXFC6D6F31C6N` (DE-SoC / DE10-Standard) |
| **Quartus Prime** | 18.1 Standard Edition |
| **Herramientas** | Signal Tap Logic Analyzer, System Console, Tcl/Tk |

---

## Estructura del repositorio

```
.
├── README.md                  
├── simple_example/            <- Ejemplo introductorio: contador con botón
│   ├── README_signaltap.md    <- Tutorial de Signal Tap
│   ├── debounce.sv
│   ├── top_counter.sv
│   └── counter.stp            <- Archivo Signal Tap preconfigurado
│
└── vjtag_example/             <- Ejemplo avanzado: control de LEDs por vJTAG
    ├── README_vjtag.md        <- Tutorial de vJTAG + verificación con Signal Tap
    ├── vjtag_top.sv
    ├── fpga_led_console.tcl
    └── vjtag.stp              <- Archivo Signal Tap preconfigurado
```

---

## ¿Por dónde empezar?

### 1 -> `simple_example` + `README_signaltap.md`

Si nunca has usado Signal Tap, empieza aquí. El diseño es un contador de 8 bits que incrementa con un botón físico. El objetivo es aprender el flujo completo del analizador: agregar señales, configurar un trigger y leer una captura.

### 2 -> `vjtag_example` + `README_vjtag.md`

Una vez familiarizado con Signal Tap, este ejemplo muestra cómo la FPGA puede comunicarse con la PC a través de JTAG sin pines adicionales. Un script Tcl/Tk controla 8 LEDs físicos desde la PC, y Signal Tap verifica en tiempo real que los datos llegan correctamente al hardware.