--------------------------------------------------------------------------------
-- Title		: Registrador de Intru��es
-- Project		: CPU multi-ciclo
--------------------------------------------------------------------------------
-- File			: instr_reg.vhd
-- Author		: Marcus Vinicius Lima e Machado (mvlm@cin.ufpe.br)
--				  Paulo Roberto Santana Oliveira Filho (prsof@cin.ufpe.br)
--				  Viviane Cristina Oliveira Aureliano (vcoa@cin.ufpe.br)
-- Organization : Universidade Federal de Pernambuco
-- Created		: 29/07/2002
-- Last update	: 21/11/2002
-- Plataform	: Flex10K
-- Simulators	: Altera Max+plus II
-- Synthesizers	: 
-- Targets		: 
-- Dependency	: 
--------------------------------------------------------------------------------
-- Description	: Entidade que registra a instru��o a ser executada, modulando 
-- corretamente a sa�da de acordo com o layout padr�o das intru��es do Mips.
--------------------------------------------------------------------------------
-- Copyright (c) notice
--		Universidade Federal de Pernambuco (UFPE).
--		CIn - Centro de Informatica.
--		Developed by computer science undergraduate students.
--		This code may be used for educational and non-educational purposes as 
--		long as its copyright notice remains unchanged. 
--------------------------------------------------------------------------------
-- Revisions		: 
-- Revision Number	: 
-- Version			: 
-- Date				: 29/07/2008 
-- Modifier			: Jo�o Paulo Fernandes Barbosa (jpfb@cin.ufpe.br)
-- Description		: Os sinais de entrada e sa�da e internos passam a ser do 
-- tipo std_logic. 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Revisions		: 2
-- Revision Number	: 
-- Version			: 
-- Date				: 03/10/2018 
-- Modifier			: Lucas Eliseu de Amorim (jpfb@cin.ufpe.br)
-- Description		: Mudan�a para o RISC-V
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


-- Short name: ir
ENTITY Instr_Reg_RISC_V IS
	PORT( 
		Clk			: IN  STD_LOGIC;					 -- Clock do sistema
		Reset		: IN  STD_LOGIC;					 -- Reset
		Load_ir		: IN  STD_LOGIC;					 -- Bit para ativar carga do registrador de intru��es
		Entrada		: IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Intru��o a ser carregada
		Instr19_15	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);	 -- Bits 19 a 15 da instru��o referente ao rs1
		Instr24_20	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);	 -- Bits 24 a 20 da instru��o referente ao rs2
		Instr11_7	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);  -- Bits 11 a 7 da instru��o referente ao rd
		Instr6_0	: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- Bits 6 a 0 referente ao opcode da instru��o 
		Instr31_0	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  -- Sai toda a instru��o para ser usada nos casos do immediate e para pegar o funct7
		
	);
END Instr_Reg_RISC_V;


ARCHITECTURE behavioral_arch OF Instr_Reg_RISC_V IS

	
	BEGIN
	
	PROCESS(clk, reset)

		BEGIN
			
			IF( reset = '1' )THEN
			  
				Instr19_15 <= (OTHERS => '0');  
				Instr24_20 <= (OTHERS => '0');  
				Instr11_7  <= (OTHERS => '0');
				Instr6_0  <= (OTHERS => '0');
				Instr31_0  <= (OTHERS => '0');
				
			ELSIF( clk = '1' and clk'event )THEN
			
				IF( load_ir = '1' )THEN
	
					Instr19_15 <= entrada(19 DOWNTO 15); -- Modula instru��o (19 a 15)  
					Instr24_20 <= entrada(24 DOWNTO 20); -- Modula instru��o (24 a 20)  
					Instr11_7  <= entrada(11 DOWNTO 7);  -- Modula instru��o (11 a 7)
					Instr6_0  <= entrada(6 DOWNTO 0);  -- Modula instru��o (6 a 0)
					Instr31_0  <= entrada(31 DOWNTO 0);  -- Modula instru��o (31 a 0)  
				
				END IF;
			
			END IF;
	
	END PROCESS;
 
END behavioral_arch; 