library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.segm_mips_const_pkg.all;


entity CONTROL_UNIT is
	port( 
	
		OP			: in	STD_LOGIC_VECTOR (5 downto 0); 		

		RegWrite		: out	STD_LOGIC; 				
		MemtoReg		: out	STD_LOGIC;  				
		Brach			: out	STD_LOGIC; 				
		MemRead			: out	STD_LOGIC; 				
		MemWrite		: out	STD_LOGIC; 				
		RegDst			: out	STD_LOGIC; 				
		ALUSrc			: out	STD_LOGIC;				
		ALUOp0			: out	STD_LOGIC; 				
		ALUOp1			: out	STD_LOGIC; 				
		ALUOp2			: out	STD_LOGIC 				

	);
end CONTROL_UNIT;


architecture CONTROL_UNIT_ARC of CONTROL_UNIT is  

--Decaración de señales
	signal R_TYPE		: STD_LOGIC;
	signal LW		: STD_LOGIC;
	signal SW		: STD_LOGIC;
	signal BEQ		: STD_LOGIC;
	signal LUI		: STD_LOGIC;
	
begin	

	R_TYPE		<=	not OP(5) and not OP(4) and not OP(3) and 
				not OP(2) and not OP(1) and not OP(0);
		
	LW		<=	OP(5) and not OP(4) and not OP(3) and 
				not OP(2) and    OP(1) and     OP(0);
		
	SW		<=	OP(5) and not OP(4) and 	OP(3) and 
				not OP(2) and     OP(1) and     OP(0);

	BEQ		<=	not OP(5) and not OP(4) and not OP(3) and 
				    OP(2) and not OP(1) and not OP(0);

	LUI		<=	not OP(5) and not OP(4) and OP(3) and 
				OP(2) and  OP(1) and OP(0);
	
	RegWrite	<= R_TYPE or LW or LUI;		
	MemtoReg	<= LW;		
	Brach		<= BEQ;	
	MemRead		<= LW or LUI;
	MemWrite	<= SW;
	RegDst		<= R_TYPE;
	ALUSrc		<= LW or SW or LUI;
	ALUOp0		<= BEQ;
	ALUOp1		<= R_TYPE;
	ALUOp2		<= LUI;
			
end CONTROL_UNIT_ARC;
