module top_counter (
    input  logic       clk,     // Reloj de la FPGA (50 MHz)
    input  logic       rst,     // Reset
	 input  logic       btn_inc, // Botón de incremento
    output logic [7:0] led    // Contador binario de 8 bits 
);

    // btn_pulse: pulso de 1 ciclo cuando el botón se presiona de forma válida
    logic btn_pulse;
 
    debounce #(.N(800000)) u_debounce (
        .clk (clk),
        .rst (!rst),
        .ent (btn_inc),
        .out (btn_pulse)
    );
	 
    // Contador de 8 bits
    logic [7:0] count;
 
    always_ff @(posedge clk or negedge rst) begin
        if (!rst)
            count <= 8'd0;
        else if (btn_pulse)
            count <= count + 1'b1;
    end
 
    assign led = count;

endmodule 