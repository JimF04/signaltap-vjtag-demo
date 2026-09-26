module vjtag_top (
    input logic clk,
	 input logic rst_n,
	 output logic [7:0] leds
);

    // Señales de interfaz del IP vJTAG
	 logic tdi;                 // JTAG Test Data Input
    logic tdo;                 // JTAG Test Data Output
    logic [0:0] ir_in;         // Instruction Register
    logic [0:0] ir_out;        // Instruction Register Output
    logic virtual_state_cdr;   // Virtual Capture Data Register
    logic virtual_state_sdr;   // Virtual Shift Data Register  
    logic virtual_state_e1dr;  // Virtual Exit1 Data Register
    logic virtual_state_pdr;   // Virtual Pause Data Register
    logic virtual_state_e2dr;  // Virtual Exit2 Data Register
    logic virtual_state_udr;   // Virtual Update Data Register
    logic virtual_state_cir;   // Virtual Capture Instruction Register
    logic virtual_state_uir;   // Virtual Update Instruction Register
    logic tck;                 // JTAG Test Clock

    // Registro interno donde guardaremos los datos que entren por JTAG
    reg [7:0] rx_shift_reg;
	 
	 // Instancia del IP vJTAG generado por Quartus
	 
    vjtag u0 (
       .tdi                (tdi),                // jtag.tdi
       .tdo                (tdo),                // .tdo
       .ir_in              (ir_in),              // .ir_in
       .ir_out             (ir_out),             // .ir_out
       .virtual_state_cdr  (virtual_state_cdr),  // .virtual_state_cdr
       .virtual_state_sdr  (virtual_state_sdr),  // .virtual_state_sdr
       .virtual_state_e1dr (virtual_state_e1dr), // .virtual_state_e1dr
       .virtual_state_pdr  (virtual_state_pdr),  // .virtual_state_pdr
       .virtual_state_e2dr (virtual_state_e2dr), // .virtual_state_e2dr
       .virtual_state_udr  (virtual_state_udr),  // .virtual_state_udr
       .virtual_state_cir  (virtual_state_cir),  // .virtual_state_cir
       .virtual_state_uir  (virtual_state_uir),  // .virtual_state_uir
       .tck                (tck)                 // tck.clk
    );

	 // Lógica para desplazar bits cuando se activa SDR (Shift DR)
    always @(posedge tck or negedge rst_n) begin
        if (!rst_n) begin
            rx_shift_reg <= 8'h00;
        end else if (virtual_state_sdr) begin
            // Desplazamiento de datos provenientes de la PC (TDI)
            rx_shift_reg <= {tdi, rx_shift_reg[7:1]};
        end
    end 
	 
    // Mantenemos TDO conectado al LSB para cerrar el lazo de comunicación
    assign tdo = rx_shift_reg[0];
	 
	 
    reg [7:0] led_reg;
 
    always @(posedge tck or negedge rst_n) begin
        if (!rst_n)                led_reg <= 8'h00;
        else if (virtual_state_udr) led_reg <= rx_shift_reg;
    end
 
    assign leds = led_reg;

endmodule 
