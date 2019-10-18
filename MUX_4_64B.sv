module MUX_4_64B (  input logic [63:0] A,                 
                    input logic [63:0] B,              
                    input logic [63:0] C,        
                    input logic [63:0] D,               
                    input logic [1:0] SELECTOR,             
                    output logic [63:0] F);          
 
   assign F = SELECTOR[1] ? (SELECTOR[0] ? D : C) : (SELECTOR[0] ? B : A); 

endmodule