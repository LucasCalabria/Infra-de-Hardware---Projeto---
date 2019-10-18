module STATE_MACHINE (
    input CLK, 
    input RST, 
    input ZERO,
    input OVERFLOW,
    input EQUAL,
    input GREATER,
    input LESS,
    input [31:0] INSTR31_0,
    input [63:0] ADDRESS,
    output logic RST_SM, 
    output logic RST_A,
    output logic RST_B,
    output logic WR_PC, 
    output logic WR_EPC,
    output logic WR_OP_M,
    output logic WR_A,
    output logic WR_B,
    output logic WR_ALU_OUT,
    output logic WR_MDR_REG,
    output logic WR_DATA_MEM,
    output logic WR_REGISTERS,
    output logic SELECTOR_A,
    output logic SELECTOR_SHIFT,
    output logic SELECTOR_MUX_JOKER,
    output logic SELECTOR_MUX_PC,
    output logic SELECTOR_MUX_ENILA,
    output logic [1:0] SELECTOR_ENILA,
    output logic [1:0] SELECTOR_MUX_EXP,
    output logic [1:0] SELECTOR_MDR,
    output logic [1:0] SELECTOR_SHIFT_TYPE,
    output logic [1:0] SELECTOR_B,
    output logic [2:0] SELECTOR_ULA,
    output logic [2:0] SELECTOR_SE,
    output logic [2:0] SELECTOR_LANA,
    output logic [5:0] SELECTOR_SHIFT_N,
    output logic [63:0] PC,
    output logic LOAD
    );
    
    logic [6:0] OPCODE;
    logic [2:0] FUNCT3;
    logic [5:0] FUNCT6, SHAMT;
    logic [6:0] FUNCT7;
    logic [11:0] IM_I;
    logic [6:0] IM_S, IM_SB;
    logic [19:0] IM_U;
    logic [4:0] RS_1, RS_2, RD;

    enum bit[6:0] { rst, load, inc_PC, decoder,
                    type_R, type_I_1, type_I_2, type_I_3, type_S, type_SB, type_U, type_UJ,
                    add, sub, _and, slt,
                    addi, slti, jalr, lb, lh, lw, ld, lbu, lhu, lwu, nop, _break,
                    srli, srai, slli,
                    sd, sw, sh, sb,
                    beq, bne, bge, blt,
                    lui, jal,
                    jump, write_shift, write_bank, load_mdr,
                    write_bank_pc, jump_i,
                    write_data_mem, read_data_mem, non_existent, write_pc, overflow, biribam,
                    read_enila, load_enila, write_enila
            } Estado, next_state;

    always_ff @(posedge CLK, posedge RST) begin
        if(RST) Estado  <= rst;          //RECOMECA A MAQUINA DE ESTADOS QUANDO RST E ATIVADO
        else Estado     <= next_state;
    end
    
    always_comb 
    begin

        PC      = ADDRESS;
        OPCODE  = INSTR31_0[6:0];
        FUNCT3  = INSTR31_0[14:12];
        FUNCT6  = INSTR31_0[31:26];
        FUNCT7  = INSTR31_0[31:25];

        SHAMT   = INSTR31_0[25:20];

        IM_I    = INSTR31_0[31:20];
        IM_S    = INSTR31_0[31:25];
        IM_SB   = {INSTR31_0[12], INSTR31_0[10:5]};     //RE-ANALYZE
        IM_U    = INSTR31_0[31:12];

        RS_1    = INSTR31_0[19:15];
        RS_2    = INSTR31_0[24:20];
        RD      = INSTR31_0[11:7];


        case(Estado)
            rst:                        //ESTADO QUE ATIVA rst_wire
            begin
                RST_SM                  = 1;
                RST_A                   = 1;
                RST_B                   = 1; 
                WR_PC                   = 0;
                WR_EPC                  = 0; 
                WR_OP_M                 = 0;
                WR_A                    = 0;
                WR_B                    = 0;
                WR_ALU_OUT              = 0;
                WR_MDR_REG              = 0;
                WR_DATA_MEM             = 0;
                WR_REGISTERS            = 0;
                SELECTOR_MDR            = 0;
                SELECTOR_A              = 0;     
                SELECTOR_B              = 0;
                SELECTOR_ULA            = 0;
                SELECTOR_SE             = 0;
                SELECTOR_SHIFT_N        = 0;
                SELECTOR_SHIFT_TYPE     = 0;
                SELECTOR_SHIFT          = 0;
                SELECTOR_MUX_JOKER      = 0;
                SELECTOR_MUX_PC         = 0;
                SELECTOR_MUX_EXP        = 0;
                LOAD                    = 0;
                next_state              = inc_PC;
            end

            load:                        //ESTADO QUE CARREGA DADOS 
            begin                        //carrega os dados das instrucoes no banco de dados
                RST_SM          = 0; 
                RST_A           = 0;
                RST_B           = 0;
                WR_PC           = 0; 
                WR_EPC          = 0;
                WR_OP_M         = 0;
                WR_A            = 0;
                WR_B            = 0;
                WR_ALU_OUT      = 0;
                WR_MDR_REG      = 0;
                WR_DATA_MEM     = 0;
                WR_REGISTERS    = 0;
                //SELECTOR_MDR;
                //SELECTOR_A;     
                //SELECTOR_B;
                SELECTOR_SE     = 0;
                //SELECTOR_ULA;
                SELECTOR_MUX_JOKER = 0;
                SELECTOR_MUX_PC = 0;
                SELECTOR_MUX_EXP = 0;
                SELECTOR_MUX_ENILA = 0;
                SELECTOR_SHIFT_N = 0;
                SELECTOR_SHIFT_TYPE = 6'd2;
                SELECTOR_SHIFT = 0;
                SELECTOR_LANA   = 0;
                SELECTOR_ENILA  = 0;
                LOAD            = 1;
                next_state    = decoder;
            end

            inc_PC:                        //ESTADO QUE CARREGA DADOS 
            begin                        //carrega os dados das instrucoes no banco de dados
                RST_SM          = 0; 
                RST_A           = 1;
                RST_B           = 1;
                WR_PC           = 1; 
                WR_OP_M         = 0;
                WR_A            = 0;
                WR_B            = 0;
                WR_ALU_OUT      = 0;
                WR_MDR_REG      = 0;
                WR_DATA_MEM     = 0;
                WR_REGISTERS    = 0;
                //SELECTOR_MDR;
                SELECTOR_A      = 0;     
                SELECTOR_B      = 2'd1;
                SELECTOR_ULA    = 1;
                SELECTOR_SE     = 0;
                LOAD            = 0;
                next_state      = load;
            end

            decoder:
            begin
                LOAD = 0;
                case(OPCODE)
                    7'b0110011:                         // TYPE R
                    begin
                        next_state = type_R;
                    end

                    7'b0010011:                         // TYPE I
                    begin
                        next_state = type_I_1;
                    end

                    7'b0000011:                         // TYPE I
                    begin
                        next_state = type_I_2;
                    end

                    7'b1110011:
                    begin
                        next_state = _break;
                    end

                    7'b1100111:
                    begin
                        case(FUNCT3)
                            3'b000:
                            begin
                                WR_A = 1;
                                next_state = jalr;
                            end
                            default:
                                next_state = type_SB;
                        endcase
                    end

                    7'b0100011:                         // TYPE S
                    begin
                        next_state = type_S;
                    end

                    7'b1100011:                         // TYPE SB
                    begin
                        next_state = type_SB;
                    end

                    7'b0110111:                         // TYPE U
                    begin
                        next_state = type_U;
                    end

                    7'b1101111:                         // TYPE UJ -- jal
                    begin
                        next_state = jal;
                    end

                    default:
                    begin
                        next_state = non_existent;
                    end
                endcase
            end

            type_R:
            begin
                WR_A    = 1;
                WR_B    = 1;

                case(FUNCT7)
                    7'b0000000:
                    begin
                        case(FUNCT3)
                            3'b000:
                                next_state = add;
                            3'b111:
                                next_state = _and;
                            3'b010:
                                next_state = slt;
                        endcase
                    end

                    7'b0100000:
                    begin
                        next_state = sub;
                    end
                        
                endcase
            end

            type_I_1:
            begin
                WR_A            = 1;

                case(FUNCT3)
                    3'b000:
                    begin   
                        if(RD == 0 && RS_1 == 0 && IM_I == 0)  // NO OPERATION (nop)
                        begin
                            next_state = nop;
                        end
                        else 
                            next_state = addi;
                    end
                    3'b001:
                    begin
                        next_state = slli;
                    end
                    3'b010:
                    begin
                        next_state = slti;
                    end
                    3'b101:
                    begin
                        case(FUNCT6)
                            6'b000000:
                            begin
                                next_state = srli;
                            end
                            6'b010000:
                            begin
                                next_state = srai;
                            end
                        endcase
                    end

                endcase
            end

            type_I_2:
            begin
                WR_A            = 1;

                case(FUNCT3)
                    3'b000:
                    begin   
                        next_state = lb;
                    end
                    3'b001:
                    begin
                        next_state = lh;
                    end
                    3'b010:
                    begin
                        next_state = lw;
                    end
                    3'b011:
                    begin
                        next_state = ld;
                    end
                    3'b100:
                    begin
                        next_state = lbu;
                    end
                    3'b101:
                    begin
                        next_state = lhu;
                    end
                    3'b110:
                    begin
                        next_state = lwu;
                    end

                endcase
            end

            type_S:
            begin
                SELECTOR_MUX_ENILA = 1;
                case(FUNCT3)
                    3'b111:
                    begin
                        WR_A       = 1;
                        WR_B       = 1;   
                        next_state = sd;
                    end
                    3'b010:
                    begin
                        WR_A       = 1;
                        WR_B       = 1;   
                        next_state = sw;
                    end
                    3'b001:
                    begin
                        WR_A       = 1;
                        WR_B       = 1;   
                        next_state = sh;
                    end
                    3'b000:
                    begin
                        WR_A       = 1;
                        WR_B       = 1;   
                        next_state = sb;
                    end

                endcase
            end

            type_SB:
            begin
                WR_A                = 1;
                WR_B                = 1;
                SELECTOR_SHIFT      = 0;
                SELECTOR_SHIFT_N    = 1;
                SELECTOR_SHIFT_TYPE = 0;

                case(FUNCT3)
                    3'b000:
                    begin   
                        next_state = beq;
                    end
                    3'b001:
                    begin   
                        next_state = bne;
                    end
                    3'b101:
                    begin   
                        next_state = bge;
                    end
                     3'b100:
                    begin   
                        next_state = blt;
                    end

                endcase
            end

            type_U:
            begin
                RST_A = 1;
                next_state = lui;
            end

            add:
            begin
                WR_A            = 0;
                WR_B            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 0;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_MDR    = 0;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = write_bank;
            end

            sub:
            begin
                WR_A            = 0;
                WR_B            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 0;
                SELECTOR_ULA    = 3'b010;
                SELECTOR_MDR    = 0;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = write_bank;
            end

            _and:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 0;
                SELECTOR_MDR = 0;
                SELECTOR_ULA = 3'b011;
                WR_ALU_OUT = 1;
                next_state = write_bank;
            end

            slt:
            begin
                WR_A                = 0;
                WR_B                = 0;
                SELECTOR_A          = 1;
                SELECTOR_B          = 0;
                SELECTOR_ULA        = 3'b111;

                if(LESS)
                    SELECTOR_MDR    = 2'd3;
                else
                    SELECTOR_MDR    = 2'd2;

                next_state = write_bank;
            end

            addi:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 1;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 0;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = write_bank;
            end

            slti:
            begin
                WR_A                = 0;
                WR_B                = 0;
                SELECTOR_A          = 1;
                SELECTOR_B          = 2;
                SELECTOR_ULA        = 3'b111;
                SELECTOR_SE         = 0;

                if(LESS)
                    SELECTOR_MDR    = 2'd3;
                else
                    SELECTOR_MDR    = 2'd2;

                next_state = write_bank;
            end

            jalr:
            begin
                WR_A            = 0;
                SELECTOR_A      = 0;
                SELECTOR_ULA    = 3'b000;
                SELECTOR_SE     = 0;
                WR_ALU_OUT      = 1;
                next_state      = write_bank_pc;
            end

            lb:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 1;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            lh:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 2;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            lw:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 3;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            ld:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end

            lbu:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 4;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            lhu:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 5;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            lwu:
            begin
                WR_A            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_SE     = 2'b00;
                SELECTOR_MDR    = 1;
                SELECTOR_LANA   = 6;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_data_mem;
            end 

            srli:
            begin
                WR_A = 0;
                WR_ALU_OUT = 1;

                SELECTOR_A = 1;
                SELECTOR_ULA = 3'b000;
                SELECTOR_SHIFT = 1;

                SELECTOR_SHIFT_N = SHAMT;
                SELECTOR_SHIFT_TYPE = 2'b01;
                next_state = write_shift;
            end

            srai:
            begin
                WR_A = 0;
                WR_ALU_OUT = 1;

                SELECTOR_A = 1;
                SELECTOR_ULA = 3'b000;
                SELECTOR_SHIFT = 1;

                SELECTOR_SHIFT_N = SHAMT;
                SELECTOR_SHIFT_TYPE = 2'b10;
                next_state = write_shift;
            end

            slli:
            begin
                WR_A = 0;
                WR_ALU_OUT = 1;

                SELECTOR_A = 1;
                SELECTOR_ULA = 3'b000;
                SELECTOR_SHIFT = 1;

                SELECTOR_SHIFT_N = SHAMT;
                SELECTOR_SHIFT_TYPE = 2'b00;
                next_state = write_shift;
            end

            sd:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 2;
                SELECTOR_ULA = 1;
                SELECTOR_SE = 1;
                SELECTOR_ENILA = 0;
                WR_ALU_OUT = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = write_data_mem;
            end

            sw:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 2;
                SELECTOR_ULA = 1;
                SELECTOR_SE = 1;
                SELECTOR_ENILA = 1;
                WR_ALU_OUT = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_enila;
            end

            sh:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 2;
                SELECTOR_ULA = 1;
                SELECTOR_SE = 1;
                SELECTOR_ENILA = 2;
                WR_ALU_OUT = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_enila;
            end

            sb:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 2;
                SELECTOR_ULA = 1;
                SELECTOR_SE = 1;
                SELECTOR_ENILA = 3;
                WR_ALU_OUT = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = read_enila;
            end

            beq:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A = 1;
                SELECTOR_B = 0;
                SELECTOR_ULA = 3'b010;
                if(ZERO)
                begin
                    next_state = jump;
                end
                else
                begin
                    if(OVERFLOW) next_state = overflow;
                    else next_state = inc_PC;
                end
            end

            bne:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A =1;
                SELECTOR_B =0;
                SELECTOR_ULA = 3'b010;
                if(~ZERO)
                begin
                    next_state = jump;
                end
                else
                begin
                    if(OVERFLOW) next_state = overflow;
                    else next_state = inc_PC;
                end
            end

            bge:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A =1;
                SELECTOR_B =0;
                SELECTOR_ULA = 3'b111;
                if(EQUAL || GREATER)
                begin
                    next_state = jump;
                end
                else
                begin
                    next_state = inc_PC;
                end
            end

            blt:
            begin
                WR_A = 0;
                WR_B = 0;
                SELECTOR_A =1;
                SELECTOR_B =0;
                SELECTOR_ULA = 3'b111;
                if(LESS)
                begin
                    next_state = jump;
                end
                else
                begin
                    next_state = inc_PC;
                end
            end

            lui:
            begin
                WR_A            = 0;
                WR_B            = 0;
                SELECTOR_A      = 1;
                SELECTOR_B      = 2;
                SELECTOR_ULA    = 3'b001;
                SELECTOR_MDR    = 0;
                SELECTOR_SE     = 3;
                WR_ALU_OUT      = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = write_bank;
            end

            jal:
            begin
                SELECTOR_A      = 0;
                SELECTOR_ULA    = 3'b000;
                SELECTOR_SE     = 4;
                WR_ALU_OUT      = 1;
                next_state      = write_bank_pc;
            end

            jump:
            begin
                SELECTOR_A = 0;
                SELECTOR_B = 3;
                SELECTOR_ULA = 1;
                SELECTOR_SE = 2;
                WR_PC = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = inc_PC;
            end

            jump_i:
            begin
                if(OPCODE == 7'b1101111) 
                begin
                    SELECTOR_A          = 0;
                    SELECTOR_B          = 3;

                    SELECTOR_SHIFT      = 0;
                    SELECTOR_SHIFT_N    = 1;
                    SELECTOR_SHIFT_TYPE = 0;
                end
                else 
                begin
                    SELECTOR_A = 1;
                    SELECTOR_B = 2;
                end
                SELECTOR_ULA    = 3'b001;
                WR_PC           = 1;
                if(OVERFLOW) next_state = overflow;
                else next_state = inc_PC;
            end

            write_shift:
            begin
                WR_ALU_OUT = 0;
                SELECTOR_MUX_JOKER = 1;
                SELECTOR_MDR = 0;
                WR_REGISTERS = 1;
                next_state = inc_PC;
            end

            write_data_mem:
            begin
                WR_ALU_OUT      = 0;
                WR_DATA_MEM     = 1; 
                next_state      = inc_PC;
            end

            read_data_mem:
            begin
                SELECTOR_MDR    = 1;
                WR_ALU_OUT      = 0;
                next_state      = load_mdr;
            end

            load_mdr:
            begin
                WR_MDR_REG      = 1; 
                next_state      = write_bank;
            end

            write_bank:
            begin
                WR_A            = 0;
                WR_B            = 0;
                WR_REGISTERS    = 1;
                WR_ALU_OUT      = 0;
                WR_MDR_REG      = 0;
                next_state      = inc_PC;
            end

            write_bank_pc:
            begin
                WR_ALU_OUT      = 0;
                WR_REGISTERS    = 1;
                SELECTOR_MDR    = 0;
                next_state      = jump_i;
            end

            nop:
            begin
                next_state = inc_PC;
            end

            _break:
            begin
                next_state = _break;
            end

            non_existent:
            begin
                SELECTOR_A = 0;
                SELECTOR_B = 1;
                SELECTOR_ULA = 3'b010;
                
                WR_EPC = 1;
                SELECTOR_MUX_EXP = 1;
                next_state = write_pc;
            end

            overflow:
            begin
                SELECTOR_A = 0;
                SELECTOR_B = 1;
                SELECTOR_ULA = 3'b010;
                
                WR_EPC = 1;
                SELECTOR_MUX_EXP = 2;
                next_state = write_pc;
            end

            write_pc:
            begin
                WR_PC = 1;
                WR_EPC = 0;
                SELECTOR_MUX_PC = 1;
                next_state = biribam;
            end

            biribam:
            begin
                WR_PC = 0;
                next_state = load;
            end

            read_enila:
            begin
                WR_ALU_OUT      = 0;
                next_state      = load_enila;
            end

            load_enila:
            begin
                WR_MDR_REG      = 1; 
                next_state      = write_enila;
            end

            write_enila:
            begin
                WR_MDR_REG      = 0;
                WR_DATA_MEM     = 1; 
                SELECTOR_MUX_ENILA = 1;
                next_state      = inc_PC;
            end

            default:
            begin


            end

        endcase
    end
endmodule