module debounce (
    input clk,
    input rst,
    input ent,         
    output logic out   
);

    parameter N = 800000;  

    logic [2:0] state, next_state;
    logic [19:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= 3'b000;
        else
            state <= next_state;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 20'b0;
        else begin
            case (state)
                3'b000: counter <= 20'b0;
                3'b001: begin
                    if (ent == 0 && counter < N)
                        counter <= counter + 1;
                end
                default: counter <= counter; 
            endcase
        end
    end


    always_comb begin
        next_state = 3'b000;
        case (state)
            3'b000: begin
                if (ent == 0)
                    next_state = 3'b001;
                else
                    next_state = 3'b000;
            end

            3'b001: begin
                if (ent == 1)
                    next_state = 3'b000;
                else if (counter >= N)
                    next_state = 3'b010;
                else
                    next_state = 3'b001;
            end

            3'b010: next_state = 3'b011;

            3'b011: begin
                if (ent == 1)
                    next_state = 3'b000;
                else
                    next_state = 3'b011;
            end

            default: next_state = 3'b000;
        endcase
    end


    assign out = (state == 3'b010);

endmodule 