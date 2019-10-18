module PU  (input logic CLK, input logic RST);

//----------------------------------------------------------------------------------------------------------//
//                                               MAIN WIRES                                                 //
//----------------------------------------------------------------------------------------------------------//
   
    wire [63:0]     A_OUT, B_OUT, WriteDataMem, WriteDataReg, ENILA_OUT, FIX_OUT;                                                                           //SAIDA DOS REGS A E B
    wire [63:0]     ALU, MDR, MDR_IN, MUX_MDR_OUT, MUX_JOKER_OUT, MUX_PC_OUT, MUX_SHIFT_OUT, MUX_EXP_OUT, EXTENDED, EPC;                             //ENTRA NO PC, SAI DO PC
    wire [63:0]     AluOut, DeslocValue, rAddressInst, rAddressData, PC;

    wire           ZERO, EQUAL, GREATER, LESS, OVERFLOW;                                                                    //ALU COMPARISONS
    wire [63:0]    WIRE_A, WIRE_B;       
    wire [63:0]    ALU_A, ALU_B, ALU_S;                                                                     //USADO PARA A ULA 
    wire [4:0]     WriteRegister, INSTR19_15, INSTR24_20;
    wire [6:0]     INSTR6_0;
    wire [31:0]    MemOutInst, INSTR31_0;                                                                   //ENTRA NA MEMORIA, SAI DA MEMORIA
    
//----------------------------------------------------------------------------------------------------------//
//                                          STATE MACHINE WIRES                                             //
//----------------------------------------------------------------------------------------------------------//
    
    wire            IRWrite;                                                                                //LOAD INSTRUCTIONS
    wire            RST_A, RST_B, RST_SM;                                                                   //RESETS ALL
    wire            WR_PC, WR_EPC, WR_A, WR_B, WR_ALU_OUT, wrInstMem, WR_MDR_REG, wrDataMem, regWrite;        //WRITE TO REGISTERS AND MEMORY
    wire            SELECTOR_A, SELECTOR_SHIFT, SELECTOR_MUX_JOKER, SELECTOR_MUX_PC, SELECTOR_MUX_ENILA;                                        //2x1 MUX SELECTORS
    wire [1:0]      SELECTOR_MDR, SELECTOR_B, SELECTOR_SHIFT_TYPE, SELECTOR_MUX_EXP, SELECTOR_ENILA;                                                               //4x1 MUX SELECTOR
    wire [2:0]      SELECTOR_ULA, SELECTOR_SE, SELECTOR_LANA;                                                              //ULA OPERATION SELECTOR
    wire [5:0]      SELECTOR_SHIFT_N;

//----------------------------------------------------------------------------------------------------------//
    
    register pc (
        .clk(CLK),
        .reset(RST_SM),
        .regWrite(WR_PC),
        .DadoIn(MUX_PC_OUT),
        .DadoOut(rAddressInst));

    register epc (
        .clk(CLK),
        .reset(RST_SM),
        .regWrite(WR_EPC),
        .DadoIn(ALU),
        .DadoOut(EPC));

    register A (
        .clk(CLK),
        .reset(RST_A),
        .regWrite(WR_A),                        // lembrar de mandar para a maquina de estados
        .DadoIn(WIRE_A),
        .DadoOut(A_OUT));

    register B (
        .clk(CLK),
        .reset(RST_B),
        .regWrite(WR_B),                       // lembrar de mandar para a maquina de estados
        .DadoIn(WIRE_B),
        .DadoOut(B_OUT));

    register ALU_OUT (
        .clk(CLK),
        .reset(RST_SM),
        .regWrite(WR_ALU_OUT),
        .DadoIn(ALU),
        .DadoOut(AluOut));

    register MDR_REG (
        .clk(CLK),
        .reset(RST_SM),
        .regWrite(WR_MDR_REG),
        .DadoIn(MDR_IN),
        .DadoOut(MDR));
    
    Instr_Reg_Risc_V INST_REG ( 
        .Instr31_0(INSTR31_0), 
        .Clk(CLK),
        .Entrada(MemOutInst),
        .Reset(RST_SM),
        .Instr11_7(WriteRegister),
        .Instr19_15(INSTR19_15),
        .Instr24_20(INSTR24_20),
        .Instr6_0(INSTR6_0),
        .Load_ir(IRWrite));
    
    ula64 ULA ( 
        .A(ALU_A),
        .B(ALU_B),
        .S(ALU),
        .Seletor(SELECTOR_ULA),
        .z(ZERO),
        .Overflow(OVERFLOW),
        .Igual(EQUAL),
        .Maior(GREATER),
        .Menor(LESS));

    STATE_MACHINE SM (
        .ADDRESS(rAddressInst),
        .PC(PC),

        .CLK(CLK),
        .RST(RST),
        .ZERO(ZERO),
        .OVERFLOW(OVERFLOW),
        .EQUAL(EQUAL),
        .GREATER(GREATER),
        .LESS(LESS),
        .INSTR31_0(INSTR31_0),

        .RST_SM(RST_SM),
        .RST_A(RST_A),
        .RST_B(RST_B),
        
        .WR_PC(WR_PC),
        .WR_EPC(WR_EPC),
        .WR_A(WR_A),
        .WR_B(WR_B),
        .WR_ALU_OUT(WR_ALU_OUT),
        .WR_OP_M(wrInstMem),
        .WR_MDR_REG(WR_MDR_REG),
        .WR_DATA_MEM(wrDataMem),
        .WR_REGISTERS(regWrite),

        .SELECTOR_MDR(SELECTOR_MDR),
        .SELECTOR_A(SELECTOR_A),
        .SELECTOR_B(SELECTOR_B),
        .SELECTOR_ULA(SELECTOR_ULA),
        .SELECTOR_SE(SELECTOR_SE),
        .SELECTOR_MUX_JOKER(SELECTOR_MUX_JOKER),
        .SELECTOR_MUX_PC(SELECTOR_MUX_PC),
        .SELECTOR_MUX_EXP(SELECTOR_MUX_EXP),
        .SELECTOR_MUX_ENILA(SELECTOR_MUX_ENILA),
        .SELECTOR_LANA(SELECTOR_LANA),
        .SELECTOR_ENILA(SELECTOR_ENILA),
        .SELECTOR_SHIFT(SELECTOR_SHIFT),
        .SELECTOR_SHIFT_N(SELECTOR_SHIFT_N),
        .SELECTOR_SHIFT_TYPE(SELECTOR_SHIFT_TYPE),

        .LOAD(IRWrite));
    
    Memoria32 OP_MEM ( 
        .Clk(CLK),
        .raddress(rAddressInst),
        .waddress(64'd0),
        .Datain(64'd0),
        .Dataout(MemOutInst),
        .Wr(wrInstMem));
    
    Memoria64 DATA_MEM (
        .Clk(CLK),  
        .raddress(MUX_EXP_OUT),
        .waddress(AluOut),       
        .Datain(WriteDataMem),
        .Dataout(MDR_IN),
        .Wr(wrDataMem));                                         // TO BE DECIDED
    
    bancoReg REGISTERS (
        .write(regWrite),
        .clock(CLK),
        .reset(RST_SM),
        .regreader1(INSTR19_15),
        .regreader2(INSTR24_20),
        .regwriteaddress(WriteRegister),
        .datain(WriteDataReg),                                      
        .dataout1(WIRE_A),
        .dataout2(WIRE_B));

    MUX_2_64B MUX_SHIFT (
        .A(EXTENDED),
        .B(AluOut),
        .SELECTOR(SELECTOR_SHIFT),
        .F(MUX_SHIFT_OUT));

    MUX_2_64B MUX_JOKER (
        .A(AluOut),
        .B(DeslocValue),
        .SELECTOR(SELECTOR_MUX_JOKER),
        .F(MUX_JOKER_OUT));

    MUX_2_64B MUX_ENILA (
        .A(wrDataMem),
        .B(ENILA_OUT),
        .SELECTOR(SELECTOR_MUX_ENILA),
        .F(WriteDataMem));

    MUX_2_64B MUX_PC (
        .A(ALU),
        .B(FIX_OUT),
        .SELECTOR(SELECTOR_MUX_PC),
        .F(MUX_PC_OUT));

    MUX_2_64B MUX_A (
        .A(rAddressInst),
        .B(A_OUT),
        .SELECTOR(SELECTOR_A),                                  
        .F(ALU_A));

    MUX_4_64B MUX_B (
        .A(B_OUT),
        .B(64'd4),
        .C(EXTENDED),                                      
        .D(DeslocValue),                                  
        .SELECTOR(SELECTOR_B),                                 
        .F(ALU_B));

    MUX_4_64B MUX_MDR (
        .A(MUX_JOKER_OUT),
        .B(MDR),
        .C(64'd0),
        .D(64'd1),   
        .SELECTOR(SELECTOR_MDR),                                    
        .F(MUX_MDR_OUT));
        
    MUX_4_64B MUX_EXP (
        .A(AluOut),
        .B(64'd254),
        .C(64'd255),
        .D(64'd0),   
        .SELECTOR(SELECTOR_MUX_EXP),                                    
        .F(MUX_EXP_OUT));
        
    SIGN_EXTEND EXTEND (
        .IN(INSTR31_0),
        .OUT(EXTENDED),
        .SELECTOR(SELECTOR_SE));

    Deslocamento SHIFT (
        .Shift(SELECTOR_SHIFT_TYPE),
		.Entrada(MUX_SHIFT_OUT),
		.N(SELECTOR_SHIFT_N),
		.Saida(DeslocValue));

    LANA LIN (
        .IN(MUX_MDR_OUT),
        .OUT(WriteDataReg),
        .SELECTOR(SELECTOR_LANA));
    
    ENILA NIL (
        .IN_1(MDR),
        .IN_2(B_OUT),
        .OUT(ENILA_OUT),
        .SELECTOR(SELECTOR_ENILA));

    EXP_FIX FIX (
        .IN(MDR_IN),
        .OUT(FIX_OUT));
    
endmodule