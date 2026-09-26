module vjtag_top (
    input logic clk,
	 input logic rst_n
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

endmodule 


	 // ===================================================================
    // Stream de datos representativo (dominio "clk", independiente del
    // JTAG). Esto es lo que corre solo y se ve continuamente en la
    // captura de SignalTap, junto a los pulsos del vJTAG cuando se lo
    // ejercita desde la PC.
    // ===================================================================
    logic [23:0] clk_div;
    logic [7:0]  data_counter;
    logic [15:0] lfsr;
    logic        tick;
 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_div <= 24'd0;
        else        clk_div <= clk_div + 1'b1;
    end
 
    assign tick = clk_div[19];   // ~190 Hz con clk = 50 MHz; 
	 
	 // Contador incremental
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      data_counter <= 8'h00;
        else if (tick)   data_counter <= data_counter + 1'b1;
    end
	 
    // Generador Pseudoaleatorio (LFSR)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)      lfsr <= 16'hACE1;                 // semilla != 0
        else if (tick)   lfsr <= {lfsr[14:0],
                                   lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end