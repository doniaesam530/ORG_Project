


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity INSTRUCTION_DECODING is
	port(
			CLK			:	in	STD_LOGIC;				
			RESET			:	in	STD_LOGIC;				
			
			INSTRUCTION		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			NEW_PC_ADDR_IN		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
				  
			RegWrite		:	in	STD_LOGIC;						 
			WRITE_DATA		:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			WRITE_REG 		:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
			NEW_PC_ADDR_OUT		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			
			OFFSET			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);--Offset  [15-0]
			RT_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);--RT [20-16]
			RD_ADDR			:	out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);-- RD [15-11]
			
			RS	 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			RT 			:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
			
			WB_CR			:	out	WB_CTRL_REG;				
			MEM_CR			:	out	MEM_CTRL_REG;				
			EX_CR			:	out	EX_CTRL_REG				  
	);
end INSTRUCTION_DECODING;

architecture INSTRUCTION_DECODING_ARC of INSTRUCTION_DECODING is	

--Declaración de componentes

	component REGISTERS is 
	port(
		CLK 		:	in	STD_LOGIC;				
		RESET		:	in	STD_LOGIC;				
		RW		:	in	STD_LOGIC;				
		RS_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RT_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RD_ADDR 	:	in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		WRITE_DATA	:	in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RS 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT 		:	out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0)	    
	);
	end component REGISTERS;


	component CONTROL_UNIT is
	port( 
		OP			:	in	STD_LOGIC_VECTOR (5 downto 0); 		
		RegWrite		:	out	STD_LOGIC; 				
		MemtoReg		:	out	STD_LOGIC;  				
		Brach			:	out	STD_LOGIC; 				
		MemRead			:	out	STD_LOGIC; 				
		MemWrite		:	out	STD_LOGIC; 				
		RegDst			:	out	STD_LOGIC; 				
		ALUSrc			:	out	STD_LOGIC;				
	  	ALUOp0			:	out	STD_LOGIC; 			
		ALUOp1			:	out	STD_LOGIC; 				
		ALUOp2			:	out	STD_LOGIC 				
	);
	end component CONTROL_UNIT;


	component ID_EX_REGISTERS is     
	port(
		

		CLK				: in	STD_LOGIC;				
		RESET				: in	STD_LOGIC;				
      	
		NEW_PC_ADDR_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		OFFSET_IN			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RD_ADDR_IN			: in	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		RS_IN	 			: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_IN 				: in	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		WB_IN				: in	WB_CTRL_REG;				
		M_IN				: in	MEM_CTRL_REG;				
		EX_IN				: in	EX_CTRL_REG;			
	
		
		NEW_PC_ADDR_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	
		OFFSET_OUT			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		RD_ADDR_OUT			: out	STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
		
		RS_OUT	 			: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		RT_OUT				: out	STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
		
		WB_OUT				: out	WB_CTRL_REG;				
		M_OUT				: out	MEM_CTRL_REG;				
		EX_OUT				: out	EX_CTRL_REG			
	);
	end component ID_EX_REGISTERS;


	signal OFFSET_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal RS_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal RT_AUX		: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal WB_AUX		: WB_CTRL_REG;
	signal MEM_AUX		: MEM_CTRL_REG;
	signal EX_AUX		: EX_CTRL_REG;


		
begin

	--Port maps
	REGS: 
		REGISTERS port map(
			CLK 		=> CLK,
			RESET		=> RESET,
			RW		=> RegWrite,
			RS_ADDR 	=> INSTRUCTION(25 downto 21),--RS_ADDR_A,
			RT_ADDR 	=> INSTRUCTION(20 downto 16),--RT_ADDR_A,
			RD_ADDR 	=> WRITE_REG,
			WRITE_DATA	=> WRITE_DATA,
			RS 		=> RS_AUX,
			RT 		=> RT_AUX
		);
        
	CTRL : 
		CONTROL_UNIT port map(
			 	
			OP		=> INSTRUCTION(INST_SIZE-1 downto 26),--OP_A,
			
			RegWrite	=> WB_AUX.RegWrite,
			MemtoReg	=> WB_AUX.MemtoReg,
			Brach		=> MEM_AUX.Branch,
			MemRead		=> MEM_AUX.MemRead,
			MemWrite	=> MEM_AUX.MemWrite,
			RegDst		=> EX_AUX.RegDst,
			ALUSrc		=> EX_AUX.ALUSrc,
		  	ALUOp0		=> EX_AUX.ALUOp.Op0,
			ALUOp1		=> EX_AUX.ALUOp.Op1,
			ALUOp2		=> EX_AUX.ALUOp.Op2
		);
	
	

	OFFSET_AUX	<=  ZERO16b & INSTRUCTION(15 downto 0)
				when INSTRUCTION(15) = '0'
					else  ONE16b & INSTRUCTION(15 downto 0);


	ID_EX_REGS:
		ID_EX_REGISTERS port map(
			
			CLK			=> CLK,
			RESET			=> RESET,
			NEW_PC_ADDR_IN		=> NEW_PC_ADDR_IN,
			OFFSET_IN		=> OFFSET_AUX,
			RT_ADDR_IN		=> INSTRUCTION(20 downto 16),--RT_ADDR_A,
			RD_ADDR_IN		=> INSTRUCTION(15 downto 11),--RD_ADDR_A,
			RS_IN			=> RS_AUX,
			RT_IN			=> RT_AUX,
			WB_IN			=> WB_AUX,
			M_IN			=> MEM_AUX,
			EX_IN			=> EX_AUX,
			
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			OFFSET_OUT	=> OFFSET,
			RT_ADDR_OUT	=> RT_ADDR,
			RD_ADDR_OUT	=> RD_ADDR,
			RS_OUT		=> RS,
			RT_OUT		=> RT,
			WB_OUT		=> WB_CR,
			M_OUT		=> MEM_CR,
			EX_OUT		=> EX_CR
		);	

end INSTRUCTION_DECODING_ARC;
