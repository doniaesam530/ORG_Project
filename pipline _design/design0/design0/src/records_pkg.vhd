


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
package RECORDS_PKG is


	
	
	type WB_CTRL_REG is
	record
		RegWrite	:	STD_LOGIC;	
		MemtoReg	:	STD_LOGIC;	 
    	end record;
    
	type MEM_CTRL_REG is
    	record
	      	Branch		:	STD_LOGIC;	
		MemRead		:	STD_LOGIC;	
		MemWrite	:	STD_LOGIC;	
    	end record;

	type ALU_OP_INPUT is
    	record
       		Op0		:	STD_LOGIC;
       		Op1		:	STD_LOGIC;
		Op2		:	STD_LOGIC;
    	end record;
    
	type EX_CTRL_REG is
    	record
       		RegDst		:	STD_LOGIC;	
       		ALUOp		:	ALU_OP_INPUT;
		ALUSrc		:	STD_LOGIC;	
    	end record;
	

 

	type ALU_INPUT is
	record
		Op0		:	STD_LOGIC;
		Op1		:	STD_LOGIC;
		Op2		:	STD_LOGIC;
		Op3		:	STD_LOGIC;
	end record;

	
    	
	type ALU_FLAGS is
    	record
       		Carry		:	STD_LOGIC;
       		Overflow	:	STD_LOGIC;
       		Zero		:	STD_LOGIC;
       		Negative	:	STD_LOGIC;
    	end record;
    	    	

end RECORDS_PKG;
