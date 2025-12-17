library IEEE;
use IEEE.STD_LOGIC_1164.all;		
use IEEE.numeric_std.all;

library work;
use work.records_pkg.all;
use work.segm_mips_const_pkg.all;

entity EXECUTION is
	port( 
		
     		CLK			: in STD_LOGIC;					
		RESET			: in STD_LOGIC;					
     		WB_CR			: in WB_CTRL_REG; 				
		MEM_CR			: in MEM_CTRL_REG;				
		EX_CR			: in EX_CTRL_REG;					     	
		NEW_PC_ADDR_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RS	 		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
	    	RT 			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		OFFSET			: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_ADDR			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);	
		RD_ADDR			: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);				 				
				     	      
	
		WB_CR_OUT		: out WB_CTRL_REG;				
		MEM_CR_OUT		: out MEM_CTRL_REG;				
		NEW_PC_ADDR_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		ALU_FLAGS_OUT		: out ALU_FLAGS;				
		ALU_RES_OUT		: out STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
		RT_OUT			: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
		RT_RD_ADDR_OUT		: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)				
	);
end EXECUTION;

architecture EXECUTION_ARC of EXECUTION is	


	component ALU_CONTROL is
		port(
			
			CLK		: in STD_LOGIC;				
			FUNCT		: in STD_LOGIC_VECTOR(5 downto 0);	
			ALU_OP_IN	: in ALU_OP_INPUT;			
			
		     	ALU_IN		: out ALU_INPUT				
		);
	end component ALU_CONTROL;
	
	component ALU is 
		generic (N:INTEGER := INST_SIZE);
		port(
			X		: in STD_LOGIC_VECTOR(N-1 downto 0);
			Y		: in STD_LOGIC_VECTOR(N-1 downto 0);
			ALU_IN		: in ALU_INPUT;
			R		: out STD_LOGIC_VECTOR(N-1 downto 0);
			FLAGS		: out ALU_FLAGS	
		);
	end component ALU;
	
	component ADDER is 
		generic (N:INTEGER := INST_SIZE);    
		port(
			X	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			Y	: in	STD_LOGIC_VECTOR(N-1 downto 0);
			CIN	: in	STD_LOGIC;
			COUT	: out	STD_LOGIC;
			R	: out	STD_LOGIC_VECTOR(N-1 downto 0)
		);
	end component ADDER;
	
	component EX_MEM_REGISTERS is  
	    port(
			CLK		: in STD_LOGIC;					
			RESET		: in STD_LOGIC;					
			WB_CR_IN	: in WB_CTRL_REG; 				
			MEM_CR_IN	: in MEM_CTRL_REG;				
			NEW_PC_ADDR_IN	: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
			ALU_FLAGS_IN	: in ALU_FLAGS;					
			ALU_RES_IN	: in STD_LOGIC_VECTOR(INST_SIZE-1 downto 0);	
			RT_IN		: in STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
			RT_RD_ADDR_IN	: in STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);		
			 						     	      
			WB_CR_OUT	: out WB_CTRL_REG; 				
			MEM_CR_OUT	: out MEM_CTRL_REG;				
			NEW_PC_ADDR_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
			ALU_FLAGS_OUT	: out ALU_FLAGS;				
			ALU_RES_OUT	: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
			RT_OUT		: out STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);	
			RT_RD_ADDR_OUT	: out STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0)	
			
		);
	end component EX_MEM_REGISTERS;
	

	signal CARRY_AUX	: STD_LOGIC;
	signal ALU_IN_AUX	: ALU_INPUT;
	signal PC_ADDR_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal RT_RD_ADDR_AUX	: STD_LOGIC_VECTOR (ADDR_SIZE-1 downto 0);
	signal OFFSET_SHIFT2	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0);
	signal ALU_REG_IN	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal ALU_RES_AUX	: STD_LOGIC_VECTOR (INST_SIZE-1 downto 0); 
	signal ALU_FLAGS_AUX	: ALU_FLAGS;
	 
begin
	OFFSET_SHIFT2 <= OFFSET(29 downto 0) & "00";

	ALU_CTRL:
		ALU_CONTROL port map(
			CLK		=> CLK,
			FUNCT		=> OFFSET(5 downto 0),
			ALU_OP_IN	=> EX_CR.ALUOp,
		     	ALU_IN		=> ALU_IN_AUX
		);
	
	ADDER_MIPS: 
		ADDER generic map (N => INST_SIZE) 
		port map(
			X	 => NEW_PC_ADDR_IN,
			Y	 => OFFSET_SHIFT2,
			CIN	 => '0',
			COUT	 => CARRY_AUX,
			R	 => PC_ADDR_AUX
		);
        
	MUX_RT_RD:
		process(EX_CR.RegDst,RT_ADDR,RD_ADDR) is
    		begin
    	 		if( EX_CR.RegDst = '0') then
    	 			RT_RD_ADDR_AUX <= RT_ADDR; 
	    	 	else
    		 		RT_RD_ADDR_AUX <= RD_ADDR;
    		 	end if;
    	 	end process MUX_RT_RD;
	 
	MUX_ALU:
		process(EX_CR.AluSrc,ALU_REG_IN,RT,OFFSET)
		begin
			if( EX_CR.AluSrc = '0') then
				ALU_REG_IN <= RT; 
			else
				ALU_REG_IN <= OFFSET;
			end if;
		end process MUX_ALU;
	 
	ALU_MIPS: 
		ALU generic map (N => INST_SIZE)
		port map(
			X	=> RS,
			Y	=> ALU_REG_IN,
			ALU_IN	=> ALU_IN_AUX,
			R	=> ALU_RES_AUX,
			FLAGS	=> ALU_FLAGS_AUX
		);

	EX_MEM_REGS:
		 EX_MEM_REGISTERS port map(
		
			CLK		=> CLK,
			RESET		=> RESET,
			WB_CR_IN	=> WB_CR,
			MEM_CR_IN	=> MEM_CR,
			NEW_PC_ADDR_IN	=> PC_ADDR_AUX,
			ALU_FLAGS_IN	=> ALU_FLAGS_AUX,
			ALU_RES_IN	=> ALU_RES_AUX,
			RT_IN		=> RT,
			RT_RD_ADDR_IN	=> RT_RD_ADDR_AUX,	

			WB_CR_OUT	=> WB_CR_OUT,
			MEM_CR_OUT	=> MEM_CR_OUT,
			NEW_PC_ADDR_OUT	=> NEW_PC_ADDR_OUT,
			ALU_FLAGS_OUT	=> ALU_FLAGS_OUT,
			ALU_RES_OUT	=> ALU_RES_OUT,
			RT_OUT		=> RT_OUT,
			RT_RD_ADDR_OUT	=> RT_RD_ADDR_OUT	
		);

end EXECUTION_ARC;

