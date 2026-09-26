module vjatg_top (
    input logic clk,
	 input logic rst_n
);

    // Señales de interfaz del IP vJTAG
    logic vjtag_tck;
	 logic tdi;
    logic tdo;
    logic [0:0] ir_in;
    logic [0:0] ir_out;
    logic virtual_state_cdr;
    logic virtual_state_sdr;
    logic virtual_state_e1dr;
    logic virtual_state_pdr;
    logic virtual_state_e2dr;
    logic virtual_state_udr;
    logic virtual_state_cir;
    logic virtual_state_uir;
    logic tck;

    // Registro interno donde guardaremos los datos que entren por JTAG
    reg [7:0] rx_shift_reg;
	 
	 // Instancia del IP vJTAG generado por Quartus
	 
    vjatg u0 (
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
    always @(posedge vjtag_tck or negedge rst_n) begin
        if (!rst_n) begin
            rx_shift_reg <= 8'h00;
        end else if (vjtag_sdr) begin
            // Desplazamiento de datos provenientes de la PC (TDI)
            rx_shift_reg <= {vjtag_tdi, rx_shift_reg[7:1]};
        end
    end 
	 
    // Mantenemos TDO conectado al LSB para cerrar el lazo de comunicación
    assign vjtag_tdo = rx_shift_reg[0];

endmodule 