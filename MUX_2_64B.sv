module MUX_2_64B (input logic[63:0] A, B, input logic SELECTOR, output logic [63:0] F);

assign F = SELECTOR ? B : A; 

endmodule
