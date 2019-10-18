module SIGN_EXTEND (
        input logic [31:0] IN,
        input logic [2:0] SELECTOR,
        output logic [63:0] OUT
        );
////////// para cada immediate fazer um tratamento diferente


always_comb 
begin
        case(SELECTOR)
                0:              // IMMEDIATE I
                begin
                        assign OUT = IN[31] ? ({52'hFFFFFFFFFFFFF, IN[31:20]}) : ({52'b0, IN[31:20]});
                end

                1:              // IMMEDIATE S
                begin
                        assign OUT = IN[31] ? ({52'hFFFFFFFFFFFFF, IN[31:25], IN[11:7]}) : ({52'b0, IN[31:25], IN[11:7]});
                end

                2:              // IMMEDIATE SB
                begin
                        assign OUT = IN[31] ? ({51'h7FFFFFFFFFFFF, IN[31], IN[7], IN[30:25], IN[11:8], 1'b0}) : ({51'b0, IN[31], IN[7], IN[30:25], IN[11:8], 1'b0});
                end

                3:              // IMMEDIATE U
                begin
                        assign OUT = IN[31] ? ({32'hFFFFFFFF, IN[31:12], 12'b0}) : ({32'b0, IN[31:12], 12'b0});
                end

                4:
                begin
                        assign OUT = IN[31] ? ({43'h7FFFFFFFFFF, IN[31], IN[19:12], IN[20], IN[30:21], 1'b0}) : ({43'b0, IN[31], IN[19:12], IN[20], IN[30:21], 1'b0}); 
                end

                default:              // NO IMMEDIATE
                begin
                        assign OUT = IN[31] ? ({33'h1FFFFFFFF, IN[30:0]}) : ({33'b0, IN[30:0]});
                end
        endcase   
end

endmodule