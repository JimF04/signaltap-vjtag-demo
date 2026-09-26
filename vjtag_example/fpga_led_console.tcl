# =====================================================================
# fpga_led_console.tcl
# -----------------------------------------------------------------------
# GUI visual (System Console + Tk) para controlar los 8 LEDs fisicos
# de la placa a traves del vJTAG. Cada circulo en pantalla representa
# un LED real: click para prender/apagar, y se manda al instante por
# JTAG hacia "led_reg" en vjtag_top.sv.
#
# Tambien incluye botones de patrones automaticos (Todos ON/OFF,
# Chaser) para un demo mas vistoso frente a la clase.
#
# REQUIERE:
#   - vjtag_top.sv con el puerto "led[7:0]" agregado y mapeado a los
#     LEDs fisicos de la placa en Pin Planner.
#   - El .sof correspondiente ya programado en la FPGA.
#
# COMO USARLO:
#   Tools -> System Console -> en la consola Tcl:
#       source {ruta}/fpga_led_console.tcl
#
# Dejar SignalTap con Autorun Analysis corriendo en paralelo: cada
# click deberia disparar el trigger en virtual_state_udr y mostrarse
# en la forma de onda, ademas de verse en los LEDs reales de la placa.
# =====================================================================

package require Tk
init_tk

wm state . normal
wm title . "vJTAG LED Console"

set usbblaster_name ""
set test_device     ""
set displayConnect  "Presiona Connect"

array set led_state {0 0 1 0 2 0 3 0 4 0 5 0 6 0 7 0}

# ---------------------------------------------------------------------
# Conexion JTAG
# ---------------------------------------------------------------------
proc connect_jtag {} {
    global usbblaster_name test_device displayConnect

    set usbblaster_name ""
    set test_device     ""

    foreach hw [get_hardware_names] {
        if { [string match "USB-Blaster*" $hw] || [string match "*DE-SoC*" $hw] } {
            set usbblaster_name $hw
            break
        }
    }
    if { $usbblaster_name eq "" } {
        set displayConnect "Error: no se encontro cable JTAG"
        return
    }

    # En placas SoC, @1 = HPS, @2 = FPGA (donde vive el vJTAG).
    # Si tu placa no es SoC y no aparece nada con "@2*", probar "@1*".
    foreach dev [get_device_names -hardware_name $usbblaster_name] {
        if { [string match "@2*" $dev] } {
            set test_device $dev
            break
        }
    }
    if { $test_device eq "" } {
        set displayConnect "Error: no se encontro dispositivo @2 en $usbblaster_name"
        return
    }

    set displayConnect "Conectado: $usbblaster_name / $test_device"
    .btnConn configure -state disabled
    foreach b {.btnAllOn .btnAllOff} { $b configure -state normal }
}

proc open_port  {} { global usbblaster_name test_device
                     open_device -hardware_name $usbblaster_name -device_name $test_device }
proc close_port {} { catch {device_unlock}; catch {close_device} }

# ---------------------------------------------------------------------
# Mandar el estado actual de led_state(0..7) al vJTAG
# ---------------------------------------------------------------------
proc send_leds {} {
    global led_state

    # led_state(7) es el MSB, led_state(0) el LSB -> armar el string
    # en ese orden para que coincida con led_reg[7:0] en el RTL.
    set data ""
    for {set i 7} {$i >= 0} {incr i -1} {
        append data $led_state($i)
    }

    open_port
    device_lock -timeout 5000
    device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
    device_virtual_dr_shift -dr_value $data -instance_index 0 -length 8
    close_port
}

# ---------------------------------------------------------------------
# Dibujar el color del LED i segun su estado (verde = on, gris = off)
# ---------------------------------------------------------------------
proc redraw_led {i} {
    global led_state
    set color [expr { $led_state($i) ? "#00ff40" : "#333333" }]
    .cv itemconfigure led$i -fill $color
}

# ---------------------------------------------------------------------
# Click sobre un LED: togglea su estado y lo manda al instante
# ---------------------------------------------------------------------
proc toggle_led {i} {
    global led_state
    set led_state($i) [expr { 1 - $led_state($i) }]
    redraw_led $i
    send_leds
}

proc all_on {} {
    global led_state
    for {set i 0} {$i < 8} {incr i} { set led_state($i) 1; redraw_led $i }
    send_leds
}

proc all_off {} {
    global led_state
    for {set i 0} {$i < 8} {incr i} { set led_state($i) 0; redraw_led $i }
    send_leds
}

# ---------------------------------------------------------------------
# Interfaz gráfica
# ---------------------------------------------------------------------
frame .frmConn
label  .lblConn -textvariable displayConnect
button .btnConn -text "Connect" -command connect_jtag
grid .btnConn -in .frmConn -row 1 -column 1 -padx 5
grid .lblConn -in .frmConn -row 2 -column 1 -padx 5

canvas .cv -width 340 -height 80 -bg white -highlightthickness 0
for {set i 7} {$i >= 0} {incr i -1} {
    set col [expr {7 - $i}]
    set x [expr {20 + $col*40}]
    .cv create oval $x 15 [expr {$x+30}] 45 -fill #333333 -outline black -width 2 -tags led$i
    .cv create text  [expr {$x+15}] 60 -text "D$i"
    .cv bind led$i <Button-1> "toggle_led $i"
}

frame .frmBtns
button .btnAllOn  -text "Todos ON"  -command all_on  -state disabled
button .btnAllOff -text "Todos OFF" -command all_off -state disabled
grid .btnAllOn  -in .frmBtns -row 1 -column 1 -padx 5
grid .btnAllOff -in .frmBtns -row 1 -column 2 -padx 5

grid .frmConn -row 1 -column 1 -pady 5
grid .cv      -row 2 -column 1 -pady 5
grid .frmBtns -row 3 -column 1 -pady 10

tkwait window .