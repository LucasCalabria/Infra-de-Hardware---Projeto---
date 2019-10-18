`timescale 1ps/1ps
module simulation;
    localparam CLK = 100;
    localparam HALF_CLK = CLK/2;
    logic clk;
    logic rst;

    PU pu(.CLK(clk), .RST(rst));
    
    initial begin
        clk = 1'd1;
        rst = 1'd1;
        #CLK
        #CLK
        rst = 0;   
    end

    always #(HALF_CLK)
    clk = ~clk;

endmodule