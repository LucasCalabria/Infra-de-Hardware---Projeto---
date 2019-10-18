
module EXP_FIX (
            input logic [63:0] IN,
            output logic [63:0] OUT
        );

always_comb
begin
    OUT = {56'b0, IN[7:0]};
end 

endmodule