
module ENILA (
            input logic [63:0] IN_1,
            input logic [63:0] IN_2,
            input logic [1:0] SELECTOR,
            output logic [63:0] OUT
        );

always_comb
begin
    case(SELECTOR)
        0:
        begin
            assign OUT = IN_2;
        end
        1:
        begin
            assign OUT = {IN_1[63:32], IN_2[31:0]};
        end
        2:
        begin
            assign OUT = {IN_1[63:16], IN_2[15:0]};
        end
        3:
        begin
            assign OUT = {IN_1[63:8], IN_2[7:0]};
        end
    endcase
end 

endmodule