module LANA (
            input logic [63:0] IN,
            input logic [2:0] SELECTOR,
            output logic [63:0] OUT
        );

always_comb
begin
    case(SELECTOR)
        0:
        begin
            assign OUT = IN;
        end
        1:
        begin
            assign OUT = IN[63] ? ({56'hFFFFFFFFFFFFFF, IN[7:0]}) : ({56'h0, IN[7:0]});
        end
        2:
        begin
            assign OUT = IN[63] ? ({48'hFFFFFFFFFFFF, IN[15:0]}) : ({48'h0, IN[15:0]});
        end
        3:
        begin
            assign OUT = IN[63] ? ({32'hFFFFFFFF, IN[31:0]}) : ({32'h0, IN[31:0]});
        end
        4:
        begin
            assign OUT = ({56'h0, IN[7:0]});
        end
        5:
        begin
            assign OUT = ({48'h0, IN[15:0]});
        end
        6:
        begin
            assign OUT = ({32'h0, IN[31:0]});
        end
        default:
        begin
        end
    endcase
end 

endmodule